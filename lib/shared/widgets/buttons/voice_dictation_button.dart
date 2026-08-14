import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moodie/services/speech_service.dart';
import 'package:moodie/shared/themes/colors.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Reusable Voice Dictation Microphone Button.
/// Appends spoken words directly to the target [TextEditingController].
/// Supports changing recognition language via language badge or long-press.
class VoiceDictationButton extends StatefulWidget {
  final TextEditingController targetController;
  final VoidCallback? onChanged;

  const VoiceDictationButton({
    Key? key,
    required this.targetController,
    this.onChanged,
  }) : super(key: key);

  @override
  State<VoiceDictationButton> createState() => _VoiceDictationButtonState();
}

class _VoiceDictationButtonState extends State<VoiceDictationButton>
    with SingleTickerProviderStateMixin {
  late final SpeechService _speechService;
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;
  String _baseText = '';

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<SpeechService>()) {
      Get.put(SpeechService());
    }
    _speechService = SpeechService.to;
    _speechService.initSpeech();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _showLanguagePicker() async {
    if (!_speechService.isAvailable.value) {
      await _speechService.initSpeech();
    }

    final locales = _speechService.availableLocales;
    if (locales.isEmpty) {
      Get.snackbar(
        'Languages Unavailable',
        'No additional speech locales detected on device.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: ThemeColor.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Speech Recognition Language',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ThemeColor.neutral_900,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: locales.length,
                itemBuilder: (context, index) {
                  final LocaleName locale = locales[index];
                  return Obx(() {
                    final isSelected =
                        _speechService.activeLocaleId == locale.localeId;
                    return ListTile(
                      title: Text(
                        locale.name,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? ThemeColor.primary
                              : ThemeColor.neutral_900,
                        ),
                      ),
                      subtitle: Text(
                        locale.localeId,
                        style: const TextStyle(
                          fontSize: 12,
                          color: ThemeColor.neutral_500,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded,
                              color: ThemeColor.primary)
                          : null,
                      onTap: () {
                        _speechService.setLocale(locale.localeId);
                        Get.back();
                      },
                    );
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleListening() async {
    if (_speechService.isListening.value) {
      await _speechService.stopListening();
      _pulseController.stop();
      _pulseController.reset();
    } else {
      if (!_speechService.isAvailable.value) {
        final available = await _speechService.initSpeech();
        if (!available) {
          Get.snackbar(
            'Speech Unavailable',
            _speechService.lastError.value.isNotEmpty
                ? _speechService.lastError.value
                : 'Speech recognition is not available or permission was denied.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: ThemeColor.secondary_400,
            colorText: ThemeColor.white,
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
          );
          return;
        }
      }

      _baseText = widget.targetController.text.trim();
      _pulseController.repeat(reverse: true);

      await _speechService.startListening(
        onResult: (spokenText) {
          if (spokenText.isEmpty) return;

          final updatedText =
              _baseText.isEmpty ? spokenText : '$_baseText $spokenText';

          widget.targetController.text = updatedText;
          widget.targetController.selection = TextSelection.fromPosition(
            TextPosition(offset: updatedText.length),
          );

          if (widget.onChanged != null) {
            widget.onChanged!();
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isListening = _speechService.isListening.value;
      final localeId = _speechService.activeLocaleId;
      final shortLang = localeId.split('_').first.toUpperCase();

      if (!isListening && _pulseController.isAnimating) {
        _pulseController.stop();
        _pulseController.reset();
      }

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Language Badge Button
          GestureDetector(
            onTap: _showLanguagePicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ThemeColor.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: ThemeColor.primary.withAlpha(60),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    shortLang,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: ThemeColor.primary,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_drop_down_rounded,
                    size: 16,
                    color: ThemeColor.primary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Microphone Button
          GestureDetector(
            onTap: _toggleListening,
            onLongPress: _showLanguagePicker,
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: isListening ? _scaleAnimation.value : 1.0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isListening
                          ? ThemeColor.secondary_400
                          : ThemeColor.primary.withAlpha(40),
                      boxShadow: isListening
                          ? [
                              BoxShadow(
                                color: ThemeColor.secondary_400.withAlpha(120),
                                blurRadius: 16,
                                spreadRadius: 4,
                              ),
                            ]
                          : [],
                    ),
                    child: Icon(
                      isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                      color:
                          isListening ? ThemeColor.white : ThemeColor.primary,
                      size: 22,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}
