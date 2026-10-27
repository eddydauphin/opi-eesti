import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Reads Estonian text aloud using the phone's own text-to-speech engine.
///
/// Google's TTS engine on Android supports Estonian (et-EE). The voice data
/// has to be present on the phone; once installed it works fully offline.
class TtsService extends ChangeNotifier {
  TtsService({FlutterTts? tts}) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;
  static const language = 'et-EE';

  bool _ready = false;
  bool _available = false;

  bool get isAvailable => _available;

  Future<void> init() async {
    if (_ready && _available) return;
    _ready = true;
    try {
      final res = await _tts.isLanguageAvailable(language);
      _available = res == true || res == 1;
      if (_available) {
        await _tts.setLanguage(language);
        await _tts.setSpeechRate(0.45);
        await _tts.awaitSpeakCompletion(true);
      }
    } catch (e) {
      debugPrint('TTS init failed: $e');
      _available = false;
    }
    notifyListeners();
  }

  Future<void> speak(String text, {bool slow = false}) async {
    if (!_available) return;
    try {
      await _tts.stop();
      await _tts.setSpeechRate(slow ? 0.25 : 0.45);
      await _tts.speak(text);
    } catch (e) {
      debugPrint('TTS speak failed: $e');
    }
  }

  Future<void> stop() => _tts.stop();
}
