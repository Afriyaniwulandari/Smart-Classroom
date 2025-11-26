import 'package:flutter/material.dart';
import '../screens/classes_screen.dart';

class VoiceAssistantService {
  String recognizeCommand(String speech) {
    speech = speech.toLowerCase();

    if (speech.contains('start class') || speech.contains('begin class')) {
      return 'start_class';
    } else if (speech.contains('open lesson') || speech.contains('view lesson')) {
      return 'open_lesson';
    } else if (speech.contains('take quiz') || speech.contains('start quiz')) {
      return 'take_quiz';
    } else if (speech.contains('view dashboard') || speech.contains('open dashboard')) {
      return 'view_dashboard';
    }

    return '';
  }

  void executeCommand(BuildContext context, String command) {
    // Import necessary screens
    // Since we can't import here, we'll assume the context has access

    switch (command) {
      case 'start_class':
        // Navigate to live class or create class
        // For now, navigate to classes
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ClassesScreen()),
        );
        break;
      case 'open_lesson':
        // Navigate to lessons
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ClassesScreen()),
        );
        break;
      case 'take_quiz':
        // Navigate to quiz list or classes
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ClassesScreen()),
        );
        break;
      case 'view_dashboard':
        // Navigate to dashboard based on role
        // For simplicity, stay on home or go to student/teacher dashboard
        // For now, do nothing or go to home
        break;
      default:
        // Do nothing
        break;
    }
  }
}