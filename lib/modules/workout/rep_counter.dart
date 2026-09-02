import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:pose_detection/pose_detection.dart';
import 'package:moodie/modules/workout/exercise_types.dart';

/// Which phase of a rep the user is currently in.
enum RepPhase { up, down, holding, resting, unknown }

extension RepPhaseExtension on RepPhase {
  String get label {
    switch (this) {
      case RepPhase.up:
        return 'UP PHASE';
      case RepPhase.down:
        return 'DOWN PHASE';
      case RepPhase.holding:
        return 'HOLDING FORM';
      case RepPhase.resting:
        return 'RESTING';
      case RepPhase.unknown:
        return 'Get in position';
    }
  }
}

/// Result of feeding one frame's pose into the counter.
class RepUpdate {
  final int count;
  final RepPhase phase;
  final double? angle;
  final bool repJustCompleted;
  final bool formWarning;
  final String? feedbackMessage;

  const RepUpdate({
    required this.count,
    required this.phase,
    required this.angle,
    required this.repJustCompleted,
    required this.formWarning,
    this.feedbackMessage,
  });

  // Backward compatibility alias for repCount
  int get repCount => count;
}

/// Abstract base class for all exercise trackers.
abstract class ExerciseCounter {
  int get count;
  RepPhase get phase;
  ExerciseType get exerciseType;
  void reset();
  RepUpdate? update(Pose pose);

  factory ExerciseCounter.create(ExerciseType type) {
    switch (type) {
      case ExerciseType.pushUps:
        return PushUpRepCounter();
      case ExerciseType.squats:
        return SquatRepCounter();
      case ExerciseType.bicepCurls:
        return BicepCurlRepCounter();
      case ExerciseType.jumpingJacks:
        return JumpingJackRepCounter();
      case ExerciseType.plank:
        return PlankHoldCounter();
      case ExerciseType.general:
        return GeneralRepCounter();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. PUSH-UP COUNTER
// ─────────────────────────────────────────────────────────────────────────────

class PushUpRepCounter implements ExerciseCounter {
  @override
  final ExerciseType exerciseType = ExerciseType.pushUps;

  final double downThreshold;
  final double upThreshold;
  final double minVisibility;

  int _count = 0;
  RepPhase _phase = RepPhase.unknown;
  bool? _preferLeftArm;

  final List<double> _angleWindow = [];
  final int _smoothingWindow;

  PushUpRepCounter({
    this.downThreshold = 95,
    this.upThreshold = 145,
    this.minVisibility = 0.45,
    int smoothingWindow = 3,
  }) : _smoothingWindow = smoothingWindow;

  @override
  int get count => _count;
  int get repCount => _count; // Backward compatibility

  @override
  RepPhase get phase => _phase;

  @override
  void reset() {
    _count = 0;
    _phase = RepPhase.unknown;
    _angleWindow.clear();
    _preferLeftArm = null;
  }

  @override
  RepUpdate? update(Pose pose) {
    // 1. Posture Check: Prevent false counts when user is standing upright
    if (_isStandingUpright(pose)) {
      _phase = RepPhase.unknown;
      _angleWindow.clear();
      return RepUpdate(
        count: _count,
        phase: _phase,
        angle: null,
        repJustCompleted: false,
        formWarning: true,
        feedbackMessage: 'Get into push-up position (plank on hands)',
      );
    }

    // 2. Select the most visible arm with temporal hysteresis
    final side = _pickMoreVisibleArm(pose);
    if (side == null) return null;

    final rawAngle = _elbowAngle(side);
    if (rawAngle == null) return null;

    _angleWindow.add(rawAngle);
    if (_angleWindow.length > _smoothingWindow) _angleWindow.removeAt(0);
    final angle = _angleWindow.reduce((a, b) => a + b) / _angleWindow.length;

    bool repJustCompleted = false;

    if (angle <= downThreshold) {
      _phase = RepPhase.down;
    } else if (angle >= upThreshold) {
      if (_phase == RepPhase.down) {
        _count++;
        repJustCompleted = true;
      }
      _phase = RepPhase.up;
    }

    final formWarning = _hipSagWarning(pose);

    return RepUpdate(
      count: _count,
      phase: _phase,
      angle: angle,
      repJustCompleted: repJustCompleted,
      formWarning: formWarning,
      feedbackMessage: formWarning ? 'Keep your core tight & hips level' : null,
    );
  }

  /// Checks if the person is standing upright (vertical torso with hips significantly below shoulders).
  bool _isStandingUpright(Pose pose) {
    final shoulder = _bestLandmark(
        pose, PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder);
    final hip = _bestLandmark(
        pose, PoseLandmarkType.leftHip, PoseLandmarkType.rightHip);

    if (shoulder == null || hip == null) return false;
    if (shoulder.visibility < minVisibility || hip.visibility < minVisibility) {
      return false;
    }

    final dx = (hip.x - shoulder.x).abs();
    final dy = (hip.y - shoulder.y).abs();
    // Torso inclination from horizontal in degrees (0 = horizontal, 90 = vertical)
    final torsoAngle = math.atan2(dy, dx) * 180 / math.pi;

    // In standing position, shoulders are vertically above hips in image coordinates (shoulder.y < hip.y)
    final hipBelowShoulder = hip.y > shoulder.y;

    // If torso angle is steep (> 55 degrees) and hips are below shoulders
    if (torsoAngle > 55.0 && hipBelowShoulder) {
      return true;
    }

    // Check full-body verticality if ankles/knees are visible
    final ankle = _bestLandmark(
        pose, PoseLandmarkType.leftAnkle, PoseLandmarkType.rightAnkle);
    if (ankle != null && ankle.visibility >= minVisibility) {
      final bodyHeight = ankle.y - shoulder.y;
      final bodyWidth = (ankle.x - shoulder.x).abs();
      if (bodyHeight > 0.40 &&
          bodyWidth < bodyHeight * 0.7 &&
          torsoAngle > 45.0) {
        return true;
      }
    }

    return false;
  }

  _Side? _pickMoreVisibleArm(Pose pose) {
    final left = _sideVisibility(
      pose,
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.leftElbow,
      PoseLandmarkType.leftWrist,
    );
    final right = _sideVisibility(
      pose,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.rightElbow,
      PoseLandmarkType.rightWrist,
    );

    if (left == null && right == null) return null;
    if (right == null) {
      _preferLeftArm = true;
      return _Side.arm(pose, true);
    }
    if (left == null) {
      _preferLeftArm = false;
      return _Side.arm(pose, false);
    }

    // Hysteresis: stick to previously selected arm unless the other arm is noticeably clearer
    if (_preferLeftArm == true && left >= right - 0.15) {
      return _Side.arm(pose, true);
    }
    if (_preferLeftArm == false && right >= left - 0.15) {
      return _Side.arm(pose, false);
    }

    final pickLeft = left >= right;
    _preferLeftArm = pickLeft;
    return _Side.arm(pose, pickLeft);
  }

  double? _sideVisibility(
    Pose pose,
    PoseLandmarkType a,
    PoseLandmarkType b,
    PoseLandmarkType c,
  ) {
    final la = pose.getLandmark(a);
    final lb = pose.getLandmark(b);
    final lc = pose.getLandmark(c);
    if (la == null || lb == null || lc == null) return null;
    if (la.visibility < minVisibility ||
        lb.visibility < minVisibility ||
        lc.visibility < minVisibility) {
      return null;
    }
    return (la.visibility + lb.visibility + lc.visibility) / 3;
  }

  double? _elbowAngle(_Side side) {
    final shoulder = side.pose.getLandmark(side.first);
    final elbow = side.pose.getLandmark(side.mid);
    final wrist = side.pose.getLandmark(side.last);
    if (shoulder == null || elbow == null || wrist == null) return null;
    return _angleBetween(
      Offset(shoulder.x, shoulder.y),
      Offset(elbow.x, elbow.y),
      Offset(wrist.x, wrist.y),
    );
  }

  PoseLandmark? _bestLandmark(
      Pose pose, PoseLandmarkType leftType, PoseLandmarkType rightType) {
    final left = pose.getLandmark(leftType);
    final right = pose.getLandmark(rightType);
    if (left == null && right == null) return null;
    if (right == null) return left;
    if (left == null) return right;
    return left.visibility >= right.visibility ? left : right;
  }

  bool _hipSagWarning(Pose pose) {
    final shoulder = _bestLandmark(
        pose, PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder);
    final hip = _bestLandmark(
        pose, PoseLandmarkType.leftHip, PoseLandmarkType.rightHip);
    final lowerBody = _bestLandmark(
            pose, PoseLandmarkType.leftAnkle, PoseLandmarkType.rightAnkle) ??
        _bestLandmark(
            pose, PoseLandmarkType.leftKnee, PoseLandmarkType.rightKnee);

    if (shoulder == null || hip == null || lowerBody == null) return false;
    if (shoulder.visibility < minVisibility ||
        hip.visibility < minVisibility ||
        lowerBody.visibility < minVisibility) {
      return false;
    }

    final dx = (lowerBody.x - shoulder.x).abs();
    if (dx < 1e-3) return false;

    final t = (hip.x - shoulder.x) / (lowerBody.x - shoulder.x);
    final expectedHipY = shoulder.y + t * (lowerBody.y - shoulder.y);
    final deviation = (hip.y - expectedHipY).abs();

    final torsoLength = math.sqrt(
        math.pow(hip.x - shoulder.x, 2) + math.pow(hip.y - shoulder.y, 2));
    if (torsoLength < 1e-3) return false;

    return (deviation / torsoLength) > 0.28;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. SQUAT COUNTER
// ─────────────────────────────────────────────────────────────────────────────

class SquatRepCounter implements ExerciseCounter {
  @override
  final ExerciseType exerciseType = ExerciseType.squats;

  final double downThreshold;
  final double upThreshold;
  final double minVisibility;

  int _count = 0;
  RepPhase _phase = RepPhase.unknown;

  final List<double> _angleWindow = [];
  final int _smoothingWindow;

  SquatRepCounter({
    this.downThreshold = 100, // Knee flexion <= 100 degrees (parallel squat)
    this.upThreshold = 160, // Knee extension >= 160 degrees (standing)
    this.minVisibility = 0.6,
    int smoothingWindow = 3,
  }) : _smoothingWindow = smoothingWindow;

  @override
  int get count => _count;

  @override
  RepPhase get phase => _phase;

  @override
  void reset() {
    _count = 0;
    _phase = RepPhase.unknown;
    _angleWindow.clear();
  }

  @override
  RepUpdate? update(Pose pose) {
    final side = _pickMoreVisibleLeg(pose);
    if (side == null) return null;

    final hip = side.pose.getLandmark(side.first);
    final knee = side.pose.getLandmark(side.mid);
    final ankle = side.pose.getLandmark(side.last);
    if (hip == null || knee == null || ankle == null) return null;

    final rawAngle = _angleBetween(
      Offset(hip.x, hip.y),
      Offset(knee.x, knee.y),
      Offset(ankle.x, ankle.y),
    );

    _angleWindow.add(rawAngle);
    if (_angleWindow.length > _smoothingWindow) _angleWindow.removeAt(0);
    final angle = _angleWindow.reduce((a, b) => a + b) / _angleWindow.length;

    bool repJustCompleted = false;

    if (angle <= downThreshold) {
      _phase = RepPhase.down;
    } else if (angle >= upThreshold) {
      if (_phase == RepPhase.down) {
        _count++;
        repJustCompleted = true;
      }
      _phase = RepPhase.up;
    }

    // Form warning: check if hips drop significantly below knees (too deep / collapse)
    final formWarning = knee.y - hip.y < -0.05;

    return RepUpdate(
      count: _count,
      phase: _phase,
      angle: angle,
      repJustCompleted: repJustCompleted,
      formWarning: formWarning,
      feedbackMessage:
          formWarning ? 'Control your depth and keep chest upright' : null,
    );
  }

  _Side? _pickMoreVisibleLeg(Pose pose) {
    final leftHip = pose.getLandmark(PoseLandmarkType.leftHip);
    final leftKnee = pose.getLandmark(PoseLandmarkType.leftKnee);
    final leftAnkle = pose.getLandmark(PoseLandmarkType.leftAnkle);

    final rightHip = pose.getLandmark(PoseLandmarkType.rightHip);
    final rightKnee = pose.getLandmark(PoseLandmarkType.rightKnee);
    final rightAnkle = pose.getLandmark(PoseLandmarkType.rightAnkle);

    double leftVis = 0, rightVis = 0;
    if (leftHip != null && leftKnee != null && leftAnkle != null) {
      leftVis =
          (leftHip.visibility + leftKnee.visibility + leftAnkle.visibility) / 3;
    }
    if (rightHip != null && rightKnee != null && rightAnkle != null) {
      rightVis =
          (rightHip.visibility + rightKnee.visibility + rightAnkle.visibility) /
              3;
    }

    if (leftVis < minVisibility && rightVis < minVisibility) return null;
    return leftVis >= rightVis ? _Side.leg(pose, true) : _Side.leg(pose, false);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. BICEP CURL COUNTER
// ─────────────────────────────────────────────────────────────────────────────

class BicepCurlRepCounter implements ExerciseCounter {
  @override
  final ExerciseType exerciseType = ExerciseType.bicepCurls;

  final double curlThreshold;
  final double extendThreshold;
  final double minVisibility;

  int _count = 0;
  RepPhase _phase = RepPhase.unknown;

  final List<double> _angleWindow = [];
  final int _smoothingWindow;

  BicepCurlRepCounter({
    this.curlThreshold = 55, // Elbow curled <= 55°
    this.extendThreshold = 150, // Elbow extended >= 150°
    this.minVisibility = 0.6,
    int smoothingWindow = 3,
  }) : _smoothingWindow = smoothingWindow;

  @override
  int get count => _count;

  @override
  RepPhase get phase => _phase;

  @override
  void reset() {
    _count = 0;
    _phase = RepPhase.unknown;
    _angleWindow.clear();
  }

  @override
  RepUpdate? update(Pose pose) {
    final side = _pickMoreVisibleArm(pose);
    if (side == null) return null;

    final shoulder = side.pose.getLandmark(side.first);
    final elbow = side.pose.getLandmark(side.mid);
    final wrist = side.pose.getLandmark(side.last);
    if (shoulder == null || elbow == null || wrist == null) return null;

    final rawAngle = _angleBetween(
      Offset(shoulder.x, shoulder.y),
      Offset(elbow.x, elbow.y),
      Offset(wrist.x, wrist.y),
    );

    _angleWindow.add(rawAngle);
    if (_angleWindow.length > _smoothingWindow) _angleWindow.removeAt(0);
    final angle = _angleWindow.reduce((a, b) => a + b) / _angleWindow.length;

    bool repJustCompleted = false;

    if (angle <= curlThreshold) {
      _phase = RepPhase.up; // Full curl at top
    } else if (angle >= extendThreshold) {
      if (_phase == RepPhase.up) {
        _count++;
        repJustCompleted = true;
      }
      _phase = RepPhase.down; // Full extension at bottom
    }

    return RepUpdate(
      count: _count,
      phase: _phase,
      angle: angle,
      repJustCompleted: repJustCompleted,
      formWarning: false,
    );
  }

  _Side? _pickMoreVisibleArm(Pose pose) {
    final left = pose.getLandmark(PoseLandmarkType.leftElbow);
    final right = pose.getLandmark(PoseLandmarkType.rightElbow);
    if (left == null && right == null) return null;
    if (right == null) return _Side.arm(pose, true);
    if (left == null) return _Side.arm(pose, false);
    return left.visibility >= right.visibility
        ? _Side.arm(pose, true)
        : _Side.arm(pose, false);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. JUMPING JACK COUNTER
// ─────────────────────────────────────────────────────────────────────────────

class JumpingJackRepCounter implements ExerciseCounter {
  @override
  final ExerciseType exerciseType = ExerciseType.jumpingJacks;

  int _count = 0;
  RepPhase _phase = RepPhase.unknown;

  JumpingJackRepCounter();

  @override
  int get count => _count;

  @override
  RepPhase get phase => _phase;

  @override
  void reset() {
    _count = 0;
    _phase = RepPhase.unknown;
  }

  @override
  RepUpdate? update(Pose pose) {
    final leftWrist = pose.getLandmark(PoseLandmarkType.leftWrist);
    final rightWrist = pose.getLandmark(PoseLandmarkType.rightWrist);
    final leftShoulder = pose.getLandmark(PoseLandmarkType.leftShoulder);
    final rightShoulder = pose.getLandmark(PoseLandmarkType.rightShoulder);
    final leftAnkle = pose.getLandmark(PoseLandmarkType.leftAnkle);
    final rightAnkle = pose.getLandmark(PoseLandmarkType.rightAnkle);
    final leftHip = pose.getLandmark(PoseLandmarkType.leftHip);
    final rightHip = pose.getLandmark(PoseLandmarkType.rightHip);

    if (leftWrist == null ||
        rightWrist == null ||
        leftShoulder == null ||
        rightShoulder == null ||
        leftAnkle == null ||
        rightAnkle == null ||
        leftHip == null ||
        rightHip == null) {
      return null;
    }

    final handsOverhead =
        (leftWrist.y < leftShoulder.y) && (rightWrist.y < rightShoulder.y);
    final handsDown =
        (leftWrist.y > leftShoulder.y) && (rightWrist.y > rightShoulder.y);

    final hipWidth = (rightHip.x - leftHip.x).abs();
    final ankleWidth = (rightAnkle.x - leftAnkle.x).abs();
    final legsSpread = hipWidth > 0 && (ankleWidth / hipWidth) > 1.3;
    final legsTogether = hipWidth > 0 && (ankleWidth / hipWidth) < 1.1;

    bool repJustCompleted = false;

    if (handsOverhead && legsSpread) {
      _phase = RepPhase.up; // Open / Jack position
    } else if (handsDown && legsTogether) {
      if (_phase == RepPhase.up) {
        _count++;
        repJustCompleted = true;
      }
      _phase = RepPhase.down; // Closed / Standing position
    }

    return RepUpdate(
      count: _count,
      phase: _phase,
      angle: null,
      repJustCompleted: repJustCompleted,
      formWarning: false,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. PLANK HOLD COUNTER (Isometric Timer)
// ─────────────────────────────────────────────────────────────────────────────

class PlankHoldCounter implements ExerciseCounter {
  @override
  final ExerciseType exerciseType = ExerciseType.plank;

  int _holdMilliseconds = 0;
  DateTime? _lastGoodFrameTime;
  RepPhase _phase = RepPhase.resting;
  bool _formWarning = false;

  @override
  int get count => _holdMilliseconds ~/ 1000; // Returns total held seconds

  @override
  RepPhase get phase => _phase;

  @override
  void reset() {
    _holdMilliseconds = 0;
    _lastGoodFrameTime = null;
    _phase = RepPhase.resting;
    _formWarning = false;
  }

  @override
  RepUpdate? update(Pose pose) {
    final shoulder = pose.getLandmark(PoseLandmarkType.leftShoulder) ??
        pose.getLandmark(PoseLandmarkType.rightShoulder);
    final hip = pose.getLandmark(PoseLandmarkType.leftHip) ??
        pose.getLandmark(PoseLandmarkType.rightHip);
    final ankle = pose.getLandmark(PoseLandmarkType.leftAnkle) ??
        pose.getLandmark(PoseLandmarkType.rightAnkle);

    if (shoulder == null || hip == null || ankle == null) {
      _phase = RepPhase.unknown;
      _lastGoodFrameTime = null;
      return null;
    }

    final now = DateTime.now();

    // Check straight line torso alignment
    final dx = (ankle.x - shoulder.x).abs();
    if (dx < 1e-3) {
      _phase = RepPhase.unknown;
      return null;
    }

    final t = (hip.x - shoulder.x) / (ankle.x - shoulder.x);
    final expectedHipY = shoulder.y + t * (ankle.y - shoulder.y);
    final deviation = (hip.y - expectedHipY).abs();

    final torsoLength = math.sqrt(
        math.pow(hip.x - shoulder.x, 2) + math.pow(hip.y - shoulder.y, 2));
    final isValidForm = torsoLength > 1e-3 && (deviation / torsoLength) <= 0.22;

    _formWarning = !isValidForm;

    if (isValidForm) {
      _phase = RepPhase.holding;
      if (_lastGoodFrameTime != null) {
        final elapsed = now.difference(_lastGoodFrameTime!).inMilliseconds;
        if (elapsed < 500) {
          _holdMilliseconds += elapsed;
        }
      }
      _lastGoodFrameTime = now;
    } else {
      _phase = RepPhase.resting;
      _lastGoodFrameTime = null;
    }

    return RepUpdate(
      count: count,
      phase: _phase,
      angle: null,
      repJustCompleted: false,
      formWarning: _formWarning,
      feedbackMessage:
          _formWarning ? 'Keep back and hips in a straight line' : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 6. GENERAL REPS / TIME COUNTER
// ─────────────────────────────────────────────────────────────────────────────

class GeneralRepCounter implements ExerciseCounter {
  @override
  final ExerciseType exerciseType = ExerciseType.general;

  int _count = 0;
  RepPhase _phase = RepPhase.unknown;

  @override
  int get count => _count;

  @override
  RepPhase get phase => _phase;

  @override
  void reset() {
    _count = 0;
    _phase = RepPhase.unknown;
  }

  @override
  RepUpdate? update(Pose pose) {
    return RepUpdate(
      count: _count,
      phase: _phase,
      angle: null,
      repJustCompleted: false,
      formWarning: false,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPER GEOMETRY & SIDES
// ─────────────────────────────────────────────────────────────────────────────

double _angleBetween(Offset a, Offset b, Offset c) {
  final abx = a.dx - b.dx, aby = a.dy - b.dy;
  final cbx = c.dx - b.dx, cby = c.dy - b.dy;
  final dot = abx * cbx + aby * cby;
  final magAb = math.sqrt(abx * abx + aby * aby);
  final magCb = math.sqrt(cbx * cbx + cby * cby);
  if (magAb == 0 || magCb == 0) return 180;
  final cosAngle = (dot / (magAb * magCb)).clamp(-1.0, 1.0);
  return math.acos(cosAngle) * 180 / math.pi;
}

class _Side {
  final Pose pose;
  final PoseLandmarkType first;
  final PoseLandmarkType mid;
  final PoseLandmarkType last;

  _Side.arm(this.pose, bool isLeft)
      : first = isLeft
            ? PoseLandmarkType.leftShoulder
            : PoseLandmarkType.rightShoulder,
        mid = isLeft ? PoseLandmarkType.leftElbow : PoseLandmarkType.rightElbow,
        last =
            isLeft ? PoseLandmarkType.leftWrist : PoseLandmarkType.rightWrist;

  _Side.leg(this.pose, bool isLeft)
      : first = isLeft ? PoseLandmarkType.leftHip : PoseLandmarkType.rightHip,
        mid = isLeft ? PoseLandmarkType.leftKnee : PoseLandmarkType.rightKnee,
        last =
            isLeft ? PoseLandmarkType.leftAnkle : PoseLandmarkType.rightAnkle;
}
