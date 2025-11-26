import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../services/voice_assistant_service.dart';

class VoiceAssistantProvider extends ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  final VoiceAssistantService _service = VoiceAssistantService();

  bool _isListening = false;
  String _lastWords = '';

  bool get isListening => _isListening;
  String get lastWords => _lastWords;

  VoiceAssistantProvider() {
    _initializeTts();
  }

  void _initializeTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> startListening() async {
    bool available = await _speech.initialize(
      onStatus: (val) => print('onStatus: $val'),
      onError: (val) => print('onError: $val'),
    );

    if (available) {
      _isListening = true;
      notifyListeners();

      _speech.listen(
        onResult: (val) {
          _lastWords = val.recognizedWords;
          if (val.finalResult) {
            _processCommand(_lastWords);
          }
        },
      );
    } else {
      _speak("Speech recognition not available");
    }
  }

  Future<void> stopListening() async {
    _speech.stop();
    _isListening = false;
    notifyListeners();
  }

  void _processCommand(String command) {
    String action = _service.recognizeCommand(command);
    if (action.isNotEmpty) {
      _speak("Executing: $action");
      // Navigation will be handled by calling executeCommand with context
    } else {
      _speak("Sorry, I didn't understand that command");
    }
  }

  void executeCommand(BuildContext context, String command) {
    _service.executeCommand(context, command);
  }

  String recognizeCommand(String speech) {
    return _service.recognizeCommand(speech);
  }

  void clearLastWords() {
    _lastWords = '';
    notifyListeners();
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }
}