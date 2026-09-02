import 'package:flutter_test/flutter_test.dart';
import 'package:pose_detection/pose_detection.dart';
import 'package:moodie/models/workout_log.dart';
import 'package:moodie/modules/workout/rep_counter.dart';

Pose mockPose({
  required double shoulderX,
  required double shoulderY,
  required double elbowX,
  required double elbowY,
  required double wristX,
  required double wristY,
  required double hipX,
  required double hipY,
  double ankleX = 0.5,
  double ankleY = 0.9,
  double visibility = 0.9,
}) {
  return Pose(
    boundingBox: BoundingBox.ltrb(0, 0, 640, 480),
    score: 0.95,
    imageWidth: 640,
    imageHeight: 480,
    landmarks: [
      PoseLandmark(
          type: PoseLandmarkType.leftShoulder,
          x: shoulderX,
          y: shoulderY,
          z: 0,
          visibility: visibility),
      PoseLandmark(
          type: PoseLandmarkType.rightShoulder,
          x: shoulderX,
          y: shoulderY,
          z: 0,
          visibility: visibility),
      PoseLandmark(
          type: PoseLandmarkType.leftElbow,
          x: elbowX,
          y: elbowY,
          z: 0,
          visibility: visibility),
      PoseLandmark(
          type: PoseLandmarkType.rightElbow,
          x: elbowX,
          y: elbowY,
          z: 0,
          visibility: visibility),
      PoseLandmark(
          type: PoseLandmarkType.leftWrist,
          x: wristX,
          y: wristY,
          z: 0,
          visibility: visibility),
      PoseLandmark(
          type: PoseLandmarkType.rightWrist,
          x: wristX,
          y: wristY,
          z: 0,
          visibility: visibility),
      PoseLandmark(
          type: PoseLandmarkType.leftHip,
          x: hipX,
          y: hipY,
          z: 0,
          visibility: visibility),
      PoseLandmark(
          type: PoseLandmarkType.rightHip,
          x: hipX,
          y: hipY,
          z: 0,
          visibility: visibility),
      PoseLandmark(
          type: PoseLandmarkType.leftAnkle,
          x: ankleX,
          y: ankleY,
          z: 0,
          visibility: visibility),
      PoseLandmark(
          type: PoseLandmarkType.rightAnkle,
          x: ankleX,
          y: ankleY,
          z: 0,
          visibility: visibility),
    ],
  );
}

void main() {
  group('WorkoutLog Model Tests', () {
    test('WorkoutLog fromJson and toJson', () {
      final json = {
        'id': 10,
        'user_id': 2,
        'exercise_type': 'push_ups',
        'reps_count': 25,
        'duration_seconds': 60,
        'form_accuracy_score': 95,
        'entry_date': '2026-09-01',
        'notes': 'Great set',
        'created_at': '2026-09-01T10:00:00.000Z',
      };

      final log = WorkoutLog.fromJson(json);

      expect(log.id, 10);
      expect(log.userId, 2);
      expect(log.exerciseType, 'push_ups');
      expect(log.repsCount, 25);
      expect(log.durationSeconds, 60);
      expect(log.formAccuracyScore, 95);
      expect(log.entryDate, '2026-09-01');
      expect(log.notes, 'Great set');

      final serialized = log.toJson();
      expect(serialized['id'], 10);
      expect(serialized['reps_count'], 25);
    });

    test('WorkoutSummary fromJson', () {
      final json = {
        'total_sessions': 5,
        'total_reps': 120,
        'total_duration_seconds': 360,
        'today_sessions': 2,
        'today_reps': 45,
        'by_exercise': [
          {
            'exercise_type': 'push_ups',
            'sessions_count': 5,
            'total_reps': 120,
            'total_duration_seconds': 360,
          }
        ],
      };

      final summary = WorkoutSummary.fromJson(json);

      expect(summary.totalSessions, 5);
      expect(summary.totalReps, 120);
      expect(summary.todayReps, 45);
      expect(summary.byExercise.length, 1);
      expect(summary.byExercise.first.exerciseType, 'push_ups');
    });

    test('RepPhase extension label test', () {
      expect(RepPhase.up.label, 'UP PHASE');
      expect(RepPhase.down.label, 'DOWN PHASE');
      expect(RepPhase.unknown.label, 'Get in position');
    });

    test(
        'PushUpRepCounter ignores standing posture and does not count reps when standing',
        () {
      final counter = PushUpRepCounter();

      // Standing posture with arms bent (elbow ~90°)
      final standingBentPose = mockPose(
        shoulderX: 0.5,
        shoulderY: 0.2,
        elbowX: 0.5,
        elbowY: 0.35,
        wristX: 0.65,
        wristY: 0.35,
        hipX: 0.5,
        hipY: 0.55,
        ankleX: 0.5,
        ankleY: 0.9,
      );

      // Standing posture with arms straight (elbow 180°)
      final standingStraightPose = mockPose(
        shoulderX: 0.5,
        shoulderY: 0.2,
        elbowX: 0.5,
        elbowY: 0.35,
        wristX: 0.5,
        wristY: 0.5,
        hipX: 0.5,
        hipY: 0.55,
        ankleX: 0.5,
        ankleY: 0.9,
      );

      // Updating with standing bent pose
      final update1 = counter.update(standingBentPose);
      expect(update1?.formWarning, isTrue);
      expect(update1?.feedbackMessage, contains('Get into push-up position'));
      expect(counter.count, 0);

      // Straightening arms while standing must NOT trigger a rep!
      final update2 = counter.update(standingStraightPose);
      expect(update2?.formWarning, isTrue);
      expect(update2?.repJustCompleted, isFalse);
      expect(counter.count, 0);
    });

    test(
        'PushUpRepCounter accurately tracks horizontal push-up reps and ignores standing up after',
        () {
      final counter = PushUpRepCounter();

      // Horizontal pushup top position (arms extended ~180°)
      final plankTopPose = mockPose(
        shoulderX: 0.2,
        shoulderY: 0.5,
        elbowX: 0.2,
        elbowY: 0.6,
        wristX: 0.2,
        wristY: 0.7,
        hipX: 0.5,
        hipY: 0.52,
        ankleX: 0.8,
        ankleY: 0.55,
      );

      // Horizontal pushup bottom position (elbow bent ~90°)
      final pushUpBottomPose = mockPose(
        shoulderX: 0.2,
        shoulderY: 0.5,
        elbowX: 0.1,
        elbowY: 0.6,
        wristX: 0.2,
        wristY: 0.6,
        hipX: 0.5,
        hipY: 0.52,
        ankleX: 0.8,
        ankleY: 0.55,
      );

      // 1. Start in top position
      final updateTop1 = counter.update(plankTopPose);
      expect(updateTop1?.phase, RepPhase.up);
      expect(counter.count, 0);

      // 2. Go down (simulate 3 frames for smoothing window)
      counter.update(pushUpBottomPose);
      counter.update(pushUpBottomPose);
      final updateDown = counter.update(pushUpBottomPose);
      expect(updateDown?.phase, RepPhase.down);
      expect(counter.count, 0);

      // 3. Push back up (simulate 3 frames for smoothing window)
      counter.update(plankTopPose);
      counter.update(plankTopPose);
      final updateTop2 = counter.update(plankTopPose);
      expect(updateTop2?.phase, RepPhase.up);
      expect(updateTop2?.repJustCompleted, isTrue);
      expect(counter.count, 1);

      // 4. Now user stands up (vertical posture)
      final standingStraightPose = mockPose(
        shoulderX: 0.5,
        shoulderY: 0.2,
        elbowX: 0.5,
        elbowY: 0.35,
        wristX: 0.5,
        wristY: 0.5,
        hipX: 0.5,
        hipY: 0.55,
        ankleX: 0.5,
        ankleY: 0.9,
      );

      final updateStanding = counter.update(standingStraightPose);
      expect(updateStanding?.formWarning, isTrue);
      expect(updateStanding?.repJustCompleted, isFalse);
      // Count must STAY 1, NOT increment to 2!
      expect(counter.count, 1);
    });
  });
}
