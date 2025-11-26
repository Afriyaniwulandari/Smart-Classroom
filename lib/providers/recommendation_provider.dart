import 'package:flutter/material.dart';
import '../models/class_model.dart';
import '../models/lesson.dart';
import '../services/recommendation_service.dart';

class RecommendationProvider with ChangeNotifier {
  final RecommendationService _recommendationService = RecommendationService();

  List<ClassModel> _recommendedClasses = [];
  List<Lesson> _recommendedLessons = [];
  bool _isLoading = false;

  List<ClassModel> get recommendedClasses => _recommendedClasses;
  List<Lesson> get recommendedLessons => _recommendedLessons;
  bool get isLoading => _isLoading;

  Future<void> loadRecommendations(String userId, List<String> interests) async {
    _isLoading = true;
    notifyListeners();

    try {
      _recommendedClasses = await _recommendationService.getRecommendedClasses(userId, interests);
      _recommendedLessons = await _recommendationService.getRecommendedLessons(userId, interests);
    } catch (e) {
      _recommendedClasses = [];
      _recommendedLessons = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadNextLessonRecommendations(String currentLessonId, String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _recommendedLessons = await _recommendationService.getNextLessonRecommendations(currentLessonId, userId);
    } catch (e) {
      _recommendedLessons = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}