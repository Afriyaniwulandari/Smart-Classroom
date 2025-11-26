import 'package:flutter/material.dart';
import '../models/quiz.dart';
import '../models/quiz_result.dart';
import '../services/quiz_service.dart';

class QuizProvider with ChangeNotifier {
  final QuizService _quizService = QuizService();

  List<Quiz> _quizzes = [];
  List<QuizResult> _quizResults = [];
  Quiz? _currentQuiz;
  QuizResult? _currentQuizResult;
  bool _isLoading = false;

  List<Quiz> get quizzes => _quizzes;
  List<QuizResult> get quizResults => _quizResults;
  Quiz? get currentQuiz => _currentQuiz;
  QuizResult? get currentQuizResult => _currentQuizResult;
  bool get isLoading => _isLoading;

  Future<void> loadQuizzes(String lessonId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _quizzes = await _quizService.getQuizzes(lessonId);
    } catch (e) {
      _quizzes = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadQuiz(String quizId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentQuiz = await _quizService.getQuiz(quizId);
    } catch (e) {
      _currentQuiz = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadQuizResults(String studentId, {String? quizId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _quizResults = await _quizService.getQuizResults(studentId, quizId: quizId);
    } catch (e) {
      _quizResults = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadQuizResult(String quizId, String studentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentQuizResult = await _quizService.getQuizResult(quizId, studentId);
    } catch (e) {
      _currentQuizResult = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createQuiz(Quiz quiz) async {
    try {
      final success = await _quizService.createQuiz(quiz);
      if (success) {
        _quizzes.add(quiz);
        notifyListeners();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateQuiz(Quiz quiz) async {
    try {
      final success = await _quizService.updateQuiz(quiz);
      if (success) {
        final quizIndex = _quizzes.indexWhere((q) => q.id == quiz.id);
        if (quizIndex != -1) {
          _quizzes[quizIndex] = quiz;
          if (_currentQuiz?.id == quiz.id) {
            _currentQuiz = quiz;
          }
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteQuiz(String quizId) async {
    try {
      final success = await _quizService.deleteQuiz(quizId);
      if (success) {
        _quizzes.removeWhere((q) => q.id == quizId);
        if (_currentQuiz?.id == quizId) {
          _currentQuiz = null;
        }
        notifyListeners();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> startQuiz(String quizId, String studentId) async {
    try {
      final success = await _quizService.startQuiz(quizId, studentId);
      if (success) {
        // Reload the quiz result after starting
        await loadQuizResult(quizId, studentId);
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> submitQuizAnswer(String quizId, String studentId, String questionId, List<String> answers) async {
    try {
      final success = await _quizService.submitQuizAnswer(quizId, studentId, questionId, answers);
      if (success) {
        // Reload the current quiz result to reflect the updated answer
        await loadQuizResult(quizId, studentId);
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<QuizResult?> completeQuiz(String quizId, String studentId, int timeTakenMinutes) async {
    try {
      final result = await _quizService.completeQuiz(quizId, studentId, timeTakenMinutes);
      if (result != null) {
        _currentQuizResult = result;
        // Update in the results list if it exists
        final resultIndex = _quizResults.indexWhere((r) => r.id == result.id);
        if (resultIndex != -1) {
          _quizResults[resultIndex] = result;
        } else {
          _quizResults.add(result);
        }
        notifyListeners();
      }
      return result;
    } catch (e) {
      return null;
    }
  }

  void clearCurrentQuiz() {
    _currentQuiz = null;
    _currentQuizResult = null;
    notifyListeners();
  }

  void clearQuizzes() {
    _quizzes = [];
    _currentQuiz = null;
    notifyListeners();
  }

  void clearQuizResults() {
    _quizResults = [];
    _currentQuizResult = null;
    notifyListeners();
  }
}