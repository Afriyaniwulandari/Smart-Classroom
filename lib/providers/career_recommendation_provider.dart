import 'package:flutter/material.dart';
import '../models/career_recommendation.dart';
import '../models/user.dart';
import '../models/quiz_result.dart';
import '../models/class_model.dart';
import '../models/student_progress.dart';
import '../services/career_recommendation_service.dart';

class CareerRecommendationProvider with ChangeNotifier {
  final CareerRecommendationService _service = CareerRecommendationService();

  List<CareerRecommendation> _recommendations = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastGenerated;

  List<CareerRecommendation> get recommendations => _recommendations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastGenerated => _lastGenerated;
  bool get hasRecommendations => _recommendations.isNotEmpty;

  Future<void> generateRecommendations({
    required User user,
    required List<QuizResult> quizResults,
    required List<ClassModel> enrolledClasses,
    required List<StudySession> studySessions,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _recommendations = await _service.generateRecommendations(
        user: user,
        quizResults: quizResults,
        enrolledClasses: enrolledClasses,
        studySessions: studySessions,
      );

      _lastGenerated = DateTime.now();

      // Cache the recommendations
      await _service.cacheRecommendations(user.id, _recommendations);

    } catch (e) {
      _error = 'Failed to generate career recommendations: ${e.toString()}';
      _recommendations = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCachedRecommendations(String studentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _recommendations = await _service.getCachedRecommendations(studentId);
      if (_recommendations.isNotEmpty) {
        _lastGenerated = _recommendations.first.generatedAt;
      }
    } catch (e) {
      _error = 'Failed to load cached recommendations: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearRecommendations() {
    _recommendations = [];
    _lastGenerated = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get recommendations filtered by category
  List<CareerRecommendation> getRecommendationsByCategory(String category) {
    return _recommendations.where((rec) => rec.careerCategory == category).toList();
  }

  // Get top recommendations (highest match percentage)
  List<CareerRecommendation> getTopRecommendations({int limit = 3}) {
    final sorted = List<CareerRecommendation>.from(_recommendations)
      ..sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage));
    return sorted.take(limit).toList();
  }

  // Check if recommendations are stale (older than 30 days)
  bool get areRecommendationsStale {
    if (_lastGenerated == null) return true;
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return _lastGenerated!.isBefore(thirtyDaysAgo);
  }

  // Get career insights summary
  Map<String, dynamic> getCareerInsights() {
    if (_recommendations.isEmpty) {
      return {
        'totalCareers': 0,
        'topCategory': 'None',
        'averageMatch': 0.0,
        'highestMatch': 0.0,
        'categories': <String, int>{},
      };
    }

    final categories = <String, int>{};
    double totalMatch = 0;
    double highestMatch = 0;

    for (final rec in _recommendations) {
      categories[rec.careerCategory] = (categories[rec.careerCategory] ?? 0) + 1;
      totalMatch += rec.matchPercentage;
      if (rec.matchPercentage > highestMatch) {
        highestMatch = rec.matchPercentage;
      }
    }

    final topCategory = categories.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    return {
      'totalCareers': _recommendations.length,
      'topCategory': topCategory,
      'averageMatch': totalMatch / _recommendations.length,
      'highestMatch': highestMatch,
      'categories': categories,
    };
  }
}