import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

import '../localization/translator.dart';
import '../services/session_service.dart';
import '../services/api_service.dart';

class ChatbotScreen extends StatefulWidget {
  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController controller = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool isListening = false;
  List<Map<String, String>> messages = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (messages.isEmpty) {
      messages.add({"bot": t(context, "Hello! How can i help you today?")});
    }
  }

  /// Map app language to speech locale
  String _localeFromLanguage(String lang) {
    switch (lang) {
      case "te":
        return "te_IN";
      case "hi":
        return "hi_IN";
      default:
        return "en_US";
    }
  }

  Future<void> _sendTextMessage(String text) async {
    if (text.trim().isEmpty) return;

    final user = await SessionService.getUser();
    final phone = user["phone"] ?? "";

    setState(() {
      messages.add({"user": text});
      messages.add({"bot": "Thinking..."});
    });

    final response = await ApiService.sendMessage(
      phone: phone,
      message: text,
    );

    setState(() {
      messages.removeLast();
    });

    if (response["success"] == true) {
      final reply = response["reply"];

      setState(() {
        messages.add({"bot": reply});
      });

      final cleanText = _cleanForSpeech(reply);
      await _speak(cleanText);
    } else {
      setState(() {
        messages.add({"bot": "AI service unavailable"});
      });
    }
  }

  void sendMessage() {
    final text = controller.text;
    controller.clear();
    _sendTextMessage(text);
  }

  Future<void> startListening() async {
    final user = await SessionService.getUser();
    final language = user["language"] ?? "en";
    final localeId = _localeFromLanguage(language);

    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == "done") {
          setState(() => isListening = false);
        }
      },
      onError: (_) {
        setState(() => isListening = false);
      },
    );

    if (!available) return;

    setState(() => isListening = true);

    _speech.listen(
      localeId: localeId,
      listenMode: stt.ListenMode.confirmation,
      onResult: (result) {
        if (result.finalResult && result.recognizedWords.isNotEmpty) {
          _speech.stop();
          setState(() => isListening = false);
          _sendTextMessage(result.recognizedWords);
        }
      },
    );
  }

  /// Clean markdown and formatting for smooth TTS
  String _cleanForSpeech(String text) {
    String cleaned = text;

    cleaned = cleaned.replaceAll(RegExp(r'\*\*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\#+'), '');
    cleaned = cleaned.replaceAll(RegExp(r'`'), '');
    cleaned = cleaned.replaceAll(RegExp(r'- '), '');
    cleaned = cleaned.replaceAll(RegExp(r'\n- '), '\n');
    cleaned = cleaned.replaceAll(RegExp(r'\d+\.'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\n+'), '. ');
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
    cleaned = cleaned.trim();

    return cleaned;
  }

  Future<void> _speak(String text) async {
    final user = await SessionService.getUser();
    final language = user["language"] ?? "en";

    String locale;

    switch (language) {
      case "te":
        locale = "te-IN";
        break;
      case "hi":
        locale = "hi-IN";
        break;
      default:
        locale = "en-US";
    }

    await _tts.stop();

    var languages = await _tts.getLanguages;

    if (languages.contains(locale)) {
      await _tts.setLanguage(locale);
    } else {
      await _tts.setLanguage("en-US");
    }

    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);

    await _tts.speak(text);
  }

  Widget bubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.green.shade200 : Colors.green.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(text),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(t(context, "farmer_assistant")),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(10),
                children: messages.map((m) {
                  return bubble(
                    m.values.first,
                    m.keys.first == "user",
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: t(context, "ask_about_crops"),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    tooltip: t(context, "send"),
                    onPressed: sendMessage,
                  ),
                  IconButton(
                    icon: Icon(
                      isListening ? Icons.mic : Icons.mic_none,
                      color: isListening ? Colors.red : null,
                    ),
                    tooltip: t(context, "speak"),
                    onPressed: isListening ? null : startListening,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
