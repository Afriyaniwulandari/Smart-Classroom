import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voice_assistant_provider.dart';

class VoiceAssistantOverlay extends StatefulWidget {
  const VoiceAssistantOverlay({super.key});

  @override
  State<VoiceAssistantOverlay> createState() => _VoiceAssistantOverlayState();
}

class _VoiceAssistantOverlayState extends State<VoiceAssistantOverlay> {
  @override
  Widget build(BuildContext context) {
    return Consumer<VoiceAssistantProvider>(
      builder: (context, voiceProvider, child) {
        // Check if we have a final command to execute
        if (voiceProvider.lastWords.isNotEmpty && !voiceProvider.isListening) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            String command = voiceProvider.lastWords;
            String action = voiceProvider.recognizeCommand(command);
            if (action.isNotEmpty) {
              voiceProvider.executeCommand(context, action);
            }
            voiceProvider.clearLastWords();
          });
        }

        return Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: () async {
              if (voiceProvider.isListening) {
                await voiceProvider.stopListening();
              } else {
                await voiceProvider.startListening();
              }
            },
            backgroundColor: voiceProvider.isListening ? Colors.red : Colors.blue,
            child: Icon(
              voiceProvider.isListening ? Icons.mic_off : Icons.mic,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}