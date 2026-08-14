import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Robust Singleton Speech-to-Text Service for Moodie.
/// Follows official speech_to_text guidelines:
/// - Single instance per application session
/// - Proper status/error listeners
/// - On-device preference for low memory and privacy
/// - Automatic text appending & formatting
class SpeechService extends GetxService {
  static SpeechService get to => Get.find<SpeechService>();

  final SpeechToText _speech = SpeechToText();

  RxBool isInitialized = false.obs;
  RxBool isAvailable = false.obs;
  RxBool isListening = false.obs;
  RxString lastError = ''.obs;
  RxString lastStatus = ''.obs;
  RxString recognizedWords = ''.obs;

  List<LocaleName> availableLocales = [];
  String? currentLocaleId;
  RxnString selectedLocaleId = RxnString();

  void setLocale(String localeId) {
    selectedLocaleId.value = localeId;
    log('SpeechService: Language changed to $localeId');
  }

  String get activeLocaleId =>
      selectedLocaleId.value ?? currentLocaleId ?? 'en_US';

  /// Call once during app startup or module initialization
  Future<bool> initSpeech() async {
    if (isInitialized.value) return isAvailable.value;

    try {
      final available = await _speech.initialize(
        onStatus: _handleStatus,
        onError: _handleError,
        debugLogging: kDebugMode,
      );

      isAvailable.value = available;
      isInitialized.value = true;

      if (available) {
        availableLocales = await _speech.locales();
        final systemLocale = await _speech.systemLocale();
        currentLocaleId = systemLocale?.localeId;
        log('SpeechService initialized successfully. Locale: $currentLocaleId');
      } else {
        lastError.value =
            'Speech recognition is unavailable or permission was denied.';
        log('SpeechService: Speech recognition unavailable.');
      }
    } catch (e) {
      isAvailable.value = false;
      isInitialized.value = true;
      lastError.value = 'Failed to initialize speech recognition: $e';
      log('SpeechService init error: $e');
    }

    return isAvailable.value;
  }

  /// Start listening for voice input
  Future<void> startListening({
    required Function(String text) onResult,
    String? localeId,
  }) async {
    if (!isInitialized.value) {
      final initialized = await initSpeech();
      if (!initialized) {
        log('SpeechService: Cannot start listening, initialization failed.');
        return;
      }
    }

    if (_speech.isListening) {
      await stopListening();
    }

    lastError.value = '';
    recognizedWords.value = '';

    try {
      await _speech.listen(
        onResult: (SpeechRecognitionResult result) {
          recognizedWords.value = result.recognizedWords;
          onResult(result.recognizedWords);
        },
        listenOptions: SpeechListenOptions(
          onDevice: true, // Prefer on-device for memory efficiency & privacy
          cancelOnError: false,
          partialResults: true,
          localeId: localeId ?? activeLocaleId,
        ),
      );
      isListening.value = true;
    } catch (e) {
      isListening.value = false;
      lastError.value = 'Failed to start listening: $e';
      log('SpeechService listen error: $e');
    }
  }

  /// Stop active listening session
  Future<void> stopListening() async {
    try {
      if (_speech.isListening) {
        await _speech.stop();
      }
    } catch (e) {
      log('SpeechService stop error: $e');
    } finally {
      isListening.value = false;
    }
  }

  /// Cancel active listening session
  Future<void> cancelListening() async {
    try {
      if (_speech.isListening) {
        await _speech.cancel();
      }
    } catch (e) {
      log('SpeechService cancel error: $e');
    } finally {
      isListening.value = false;
    }
  }

  void _handleStatus(String status) {
    lastStatus.value = status;
    log('SpeechService status: $status');
    if (status == 'listening') {
      isListening.value = true;
    } else if (status == 'notListening' || status == 'done') {
      isListening.value = false;
    }
  }

  void _handleError(SpeechRecognitionError error) {
    lastError.value = error.errorMsg;
    isListening.value = false;
    log('SpeechService error: ${error.errorMsg} (permanent: ${error.permanent})');
  }
}
