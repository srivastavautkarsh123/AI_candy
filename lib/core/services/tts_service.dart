import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  String? _currentlyPlayingMessageId;
  final ValueNotifier<String?> activeMessageNotifier = ValueNotifier<String?>(null);

  Future<void> _init() async {
    if (_isInitialized) return;
    try {
      await _flutterTts.setLanguage('en-US');
      _flutterTts.setCompletionHandler(() {
        _currentlyPlayingMessageId = null;
        activeMessageNotifier.value = null;
      });
      _flutterTts.setCancelHandler(() {
        _currentlyPlayingMessageId = null;
        activeMessageNotifier.value = null;
      });
      _flutterTts.setErrorHandler((msg) {
        _currentlyPlayingMessageId = null;
        activeMessageNotifier.value = null;
      });
      _isInitialized = true;
    } catch (e) {
      debugPrint('TTS initialization error: $e');
    }
  }

  Future<void> speak({
    required String messageId,
    required String text,
    double pitch = 1.1,
    double rate = 0.48,
  }) async {
    await _init();
    if (_currentlyPlayingMessageId == messageId) {
      await stop();
      return;
    }

    await stop();
    _currentlyPlayingMessageId = messageId;
    activeMessageNotifier.value = messageId;

    // Clean roleplay asterisks so TTS speaks dialogue naturally
    final cleanText = text.replaceAll(RegExp(r'\*[^*]+\*'), '').trim();
    final spokenText = cleanText.isEmpty ? text.replaceAll('*', '') : cleanText;

    try {
      await _flutterTts.setPitch(pitch.clamp(0.5, 2.0));
      await _flutterTts.setSpeechRate(rate.clamp(0.2, 1.0));
      await _flutterTts.speak(spokenText);
    } catch (e) {
      debugPrint('TTS speak error: $e');
      _currentlyPlayingMessageId = null;
      activeMessageNotifier.value = null;
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (_) {}
    _currentlyPlayingMessageId = null;
    activeMessageNotifier.value = null;
  }
}
