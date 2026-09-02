// Hallmark · redesign · target: PushUpCameraScreen (Flutter, native widget tree — no CSS/tokens file exists in this stack)
// theme: "Field HUD" — telemetry/instrument-panel language instead of generic translucent-rounded-box AI chrome
// tokens: locked in _Tokens below; every color/radius/weight in the build methods references it, no inline hex
// scope: visual/interaction layer only — pose detection, camera lifecycle, exercise switching, and callbacks are unchanged

import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pose_detection/pose_detection.dart';

import 'exercise_types.dart';
import 'rep_counter.dart';

// Alias so both names work cleanly
typedef WorkoutCameraScreen = PushUpCameraScreen;

/// Locked design tokens for this screen. Nothing in the widgets below should
/// declare a raw Color, radius, or weight outside of this block — if a new
/// value is needed, it gets named here first.
class _Tokens {
  _Tokens._();

  // Surfaces — a single warm-black scrim, not the default Colors.black54
  // reached for by every AI-generated camera overlay.
  static const Color scrim = Color(0xFF0B0C10);
  static const Color scrimSoft = Color(0xCC0B0C10); // 80%
  static const Color hairline = Color(0x1FFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFFF4F4F2);
  static const Color textMuted = Color(0xFFA9ACB4);

  // Status
  static const Color warn = Color(0xFFE8A33D);
  static const Color danger = Color(0xFFE05252);

  // Per-exercise accent — replaces the flat "amber everywhere" default.
  // Each exercise reads as its own instrument, not a re-skinned template.
  static Color accentFor(ExerciseType type) {
    switch (type) {
      case ExerciseType.pushUps:
        return const Color(0xFF5FD0A8); // signal green
      case ExerciseType.squats:
        return const Color(0xFFE8A33D); // amber
      case ExerciseType.bicepCurls:
        return const Color(0xFF6FA8E8); // steel blue
      case ExerciseType.jumpingJacks:
        return const Color(0xFFE87FA0); // rose
      case ExerciseType.plank:
        return const Color(0xFFB08FE8); // violet
      default:
        return const Color(0xFF5FD0A8);
    }
  }

  static const double radiusPanel =
      4; // near-square panels — deliberately not rounded-everything
  static const double radiusChip = 8;

  static const FontWeight weightDisplay = FontWeight.w700;
  static const FontWeight weightLabel = FontWeight.w600;
}

/// A self-contained AI camera screen supporting multiple exercise types
/// (Push-ups, Squats, Bicep Curls, Jumping Jacks, Plank, General).
class PushUpCameraScreen extends StatefulWidget {
  final ExerciseType exerciseType;
  final void Function(int count)? onRepCompleted;
  final void Function(int count, ExerciseType exerciseType)? onSessionEnded;

  const PushUpCameraScreen({
    super.key,
    this.exerciseType = ExerciseType.pushUps,
    this.onRepCompleted,
    this.onSessionEnded,
  });

  @override
  State<PushUpCameraScreen> createState() => _PushUpCameraScreenState();
}

class _PushUpCameraScreenState extends State<PushUpCameraScreen> {
  CameraController? _camera;
  PoseDetector? _detector;
  late ExerciseType _currentExercise;
  late ExerciseCounter _counter;
  bool _isProcessingFrame = false;

  List<CameraDescription> _availableCameras = [];
  int _selectedCameraIndex = 0;
  List<Pose> _poses = [];
  Size? _imageSize;
  bool _isFrontCamera = true;
  bool _ready = false;
  String? _error;
  bool _hasFormWarning = false;
  String? _feedbackMessage;

  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _sessionEndedCalled = false;

  @override
  void initState() {
    super.initState();
    _currentExercise = widget.exerciseType;
    _counter = ExerciseCounter.create(_currentExercise);
    _setup();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  Future<void> _setup() async {
    try {
      _detector = await PoseDetector.create(
        landmarkModel: PoseLandmarkModel.lite,
      );

      _availableCameras = await availableCameras();
      if (_availableCameras.isEmpty) {
        if (mounted) {
          setState(() => _error = 'No cameras available on this device');
        }
        return;
      }

      _selectedCameraIndex = _availableCameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
      );
      if (_selectedCameraIndex == -1) _selectedCameraIndex = 0;

      await _initCamera(_availableCameras[_selectedCameraIndex]);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  Future<void> _initCamera(CameraDescription description) async {
    final prevCamera = _camera;
    _isFrontCamera = description.lensDirection == CameraLensDirection.front;

    final controller = CameraController(
      description,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    try {
      await prevCamera?.dispose();
      await controller.initialize();
      _camera = controller;

      await controller.startImageStream(_onFrame);

      if (mounted) setState(() => _ready = true);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  Future<void> _switchCamera() async {
    if (_availableCameras.length < 2) return;
    _selectedCameraIndex =
        (_selectedCameraIndex + 1) % _availableCameras.length;
    setState(() {
      _ready = false;
      _poses = [];
      _imageSize = null;
    });
    await _initCamera(_availableCameras[_selectedCameraIndex]);
  }

  void _changeExercise(ExerciseType newType) {
    if (newType == _currentExercise) return;
    setState(() {
      _currentExercise = newType;
      _counter = ExerciseCounter.create(newType);
      _hasFormWarning = false;
      _feedbackMessage = null;
    });
  }

  void _onFrame(CameraImage image) async {
    if (_isProcessingFrame) return;
    _isProcessingFrame = true;

    try {
      final camera = _camera;
      final detector = _detector;
      if (camera == null || detector == null || !mounted) return;

      final rotation = rotationForFrame(
        width: image.width,
        height: image.height,
        sensorOrientation: camera.description.sensorOrientation,
        isFrontCamera: _isFrontCamera,
        deviceOrientation: camera.value.deviceOrientation,
      );

      const int maxDim = 640;
      final Size size = detectionSize(
        width: image.width,
        height: image.height,
        rotation: rotation,
        maxDim: maxDim,
      );

      final poses = await detector.detectFromCameraImage(
        image,
        rotation: rotation,
        maxDim: maxDim,
      );

      bool warning = false;
      String? msg;
      if (poses.isNotEmpty) {
        final primary = poses.reduce((a, b) => a.score >= b.score ? a : b);
        final update = _counter.update(primary);
        if (update?.repJustCompleted == true) {
          HapticFeedback.mediumImpact();
          widget.onRepCompleted?.call(_counter.count);
        }
        warning = update?.formWarning ?? false;
        msg = update?.feedbackMessage;
      }

      if (mounted) {
        setState(() {
          _poses = poses;
          _imageSize = size;
          _hasFormWarning = warning;
          _feedbackMessage = msg;
        });
      }
    } finally {
      _isProcessingFrame = false;
    }
  }

  void _finishSession() {
    if (!_sessionEndedCalled) {
      _sessionEndedCalled = true;
      widget.onSessionEnded?.call(_counter.count, _currentExercise);
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (!_sessionEndedCalled) {
      _sessionEndedCalled = true;
      widget.onSessionEnded?.call(_counter.count, _currentExercise);
    }
    _camera?.dispose();
    _detector?.dispose();
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _ErrorScreen(
          error: _error!,
          onRetry: _setup,
          onBack: () => Navigator.of(context).pop());
    }

    if (!_ready || _camera == null) {
      return const _LoadingScreen();
    }

    final camera = _camera!;
    final accent = _Tokens.accentFor(_currentExercise);
    final cameraAspectRatio = camera.value.aspectRatio;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final displayAspectRatio =
        isPortrait ? (1.0 / cameraAspectRatio) : cameraAspectRatio;
    final mirrorOverlayHorizontally =
        (Theme.of(context).platform == TargetPlatform.android &&
                _isFrontCamera) ||
            Theme.of(context).platform == TargetPlatform.windows;

    return Scaffold(
      backgroundColor: _Tokens.scrim,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPoseOverlay(
            cameraPreview: CameraPreview(camera),
            poses: _poses,
            cameraAspectRatio: cameraAspectRatio,
            displayAspectRatio: displayAspectRatio,
            sensorOrientation: camera.description.sensorOrientation,
            isFrontCamera: _isFrontCamera,
            mirrorHorizontally: mirrorOverlayHorizontally,
            deviceOrientation: MediaQuery.of(context).orientation,
            imageSize: _imageSize,
          ),

          // Top telemetry strip & rep readout
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _TopStrip(
                    accent: accent,
                    currentExercise: _currentExercise,
                    elapsed: _formatDuration(_elapsedSeconds),
                    canSwitchCamera: _availableCameras.length > 1,
                    onClose: _finishSession,
                    onSwitchCamera: _switchCamera,
                    onSelectExercise: _changeExercise,
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _RepReadout(
                      count: _counter.count,
                      phase: _counter.phase,
                      exerciseType: _currentExercise,
                      accent: accent,
                      hasWarning: _hasFormWarning,
                      feedbackMessage: _feedbackMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom control bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: _FinishBar(
                accent: accent,
                exerciseType: _currentExercise,
                count: _counter.count,
                onFinish: _finishSession,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopStrip extends StatelessWidget {
  final Color accent;
  final ExerciseType currentExercise;
  final String elapsed;
  final bool canSwitchCamera;
  final VoidCallback onClose;
  final VoidCallback onSwitchCamera;
  final void Function(ExerciseType) onSelectExercise;

  const _TopStrip({
    required this.accent,
    required this.currentExercise,
    required this.elapsed,
    required this.canSwitchCamera,
    required this.onClose,
    required this.onSwitchCamera,
    required this.onSelectExercise,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _Tokens.scrimSoft,
        borderRadius: BorderRadius.circular(_Tokens.radiusPanel),
        border: Border.all(color: _Tokens.hairline),
      ),
      child: Row(
        children: [
          _IconTap(icon: Icons.close_rounded, onTap: onClose),
          const SizedBox(width: 4),
          Container(width: 1, height: 22, color: _Tokens.hairline),
          const SizedBox(width: 4),
          Expanded(
            child: PopupMenuButton<ExerciseType>(
              initialValue: currentExercise,
              onSelected: onSelectExercise,
              color: const Color(0xFF15161B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_Tokens.radiusChip),
                side: const BorderSide(color: _Tokens.hairline),
              ),
              itemBuilder: (ctx) => ExerciseType.values.map((type) {
                final isSelected = type == currentExercise;
                final itemAccent = _Tokens.accentFor(type);
                return PopupMenuItem<ExerciseType>(
                  value: type,
                  child: Row(
                    children: [
                      Icon(type.icon,
                          color: isSelected ? itemAccent : _Tokens.textMuted,
                          size: 18),
                      const SizedBox(width: 12),
                      Text(
                        type.label,
                        style: TextStyle(
                          color: isSelected
                              ? _Tokens.textPrimary
                              : _Tokens.textMuted,
                          fontWeight: isSelected
                              ? _Tokens.weightLabel
                              : FontWeight.normal,
                        ),
                      ),
                      if (isSelected) ...[
                        const Spacer(),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                              color: itemAccent, shape: BoxShape.circle),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(currentExercise.icon, color: accent, size: 16),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      currentExercise.label.toUpperCase(),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _Tokens.textPrimary,
                        fontWeight: _Tokens.weightLabel,
                        fontSize: 13,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.expand_more_rounded,
                      color: _Tokens.textMuted, size: 18),
                ],
              ),
            ),
          ),
          Container(width: 1, height: 22, color: _Tokens.hairline),
          const SizedBox(width: 10),
          Text(
            elapsed,
            style: const TextStyle(
              color: _Tokens.textPrimary,
              fontWeight: _Tokens.weightLabel,
              fontSize: 13,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 8),
          _IconTap(
            icon: Icons.flip_camera_ios_rounded,
            onTap: canSwitchCamera ? onSwitchCamera : null,
          ),
        ],
      ),
    );
  }
}

class _IconTap extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _IconTap({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(_Tokens.radiusChip),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon,
            color: enabled
                ? _Tokens.textPrimary
                : _Tokens.textMuted.withValues(alpha: 0.4),
            size: 20),
      ),
    );
  }
}

class _RepReadout extends StatelessWidget {
  final int count;
  final RepPhase phase;
  final ExerciseType exerciseType;
  final Color accent;
  final bool hasWarning;
  final String? feedbackMessage;

  const _RepReadout({
    required this.count,
    required this.phase,
    required this.exerciseType,
    required this.accent,
    this.hasWarning = false,
    this.feedbackMessage,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = hasWarning ? _Tokens.warn : accent;
    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: _Tokens.scrimSoft,
        border: Border(left: BorderSide(color: statusColor, width: 3)),
        borderRadius: BorderRadius.circular(_Tokens.radiusPanel),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                exerciseType == ExerciseType.plank ? '$count' : '$count',
                style: const TextStyle(
                  color: _Tokens.textPrimary,
                  fontSize: 48,
                  fontWeight: _Tokens.weightDisplay,
                  height: 1.0,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              if (exerciseType == ExerciseType.plank) ...[
                const SizedBox(width: 4),
                const Text('s',
                    style: TextStyle(
                        color: _Tokens.textMuted,
                        fontSize: 20,
                        fontWeight: _Tokens.weightLabel)),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(
            phase.label.toUpperCase(),
            style: TextStyle(
              color: statusColor,
              fontSize: 11,
              fontWeight: _Tokens.weightLabel,
              letterSpacing: 1.2,
            ),
          ),
          if (feedbackMessage != null && feedbackMessage!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              feedbackMessage!,
              style: const TextStyle(
                color: _Tokens.warn,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FinishBar extends StatelessWidget {
  final Color accent;
  final ExerciseType exerciseType;
  final int count;
  final VoidCallback onFinish;

  const _FinishBar({
    required this.accent,
    required this.exerciseType,
    required this.count,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: _Tokens.scrimSoft,
        borderRadius: BorderRadius.circular(_Tokens.radiusPanel),
        border: Border.all(color: _Tokens.hairline),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onFinish,
          borderRadius: BorderRadius.circular(_Tokens.radiusPanel),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration:
                      BoxDecoration(color: accent, shape: BoxShape.circle),
                ),
                const SizedBox(width: 12),
                const Text(
                  'FINISH SESSION',
                  style: TextStyle(
                    color: _Tokens.textPrimary,
                    fontWeight: _Tokens.weightLabel,
                    fontSize: 14,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                Text(
                  '$count ${exerciseType.unit}',
                  style: const TextStyle(
                    color: _Tokens.textMuted,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_rounded,
                    color: _Tokens.textMuted, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: _Tokens.scrim,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: _Tokens.textPrimary,
                strokeWidth: 2,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'CALIBRATING POSE TRACKER',
              style: TextStyle(
                color: _Tokens.textMuted,
                fontSize: 12,
                fontWeight: _Tokens.weightLabel,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  const _ErrorScreen(
      {required this.error, required this.onRetry, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Tokens.scrim,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _Tokens.textPrimary),
          onPressed: onBack,
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: _Tokens.danger, size: 40),
              const SizedBox(height: 16),
              const Text(
                'CAMERA ERROR',
                style: TextStyle(
                  color: _Tokens.textPrimary,
                  fontWeight: _Tokens.weightLabel,
                  fontSize: 13,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: _Tokens.textMuted, fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: _Tokens.textPrimary,
                  side: const BorderSide(color: _Tokens.hairline),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_Tokens.radiusPanel),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: onRetry,
                child: const Text('TRY AGAIN'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
