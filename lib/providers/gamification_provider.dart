import 'dart:async';
import 'package:flutter/material.dart';
import '../models/gamification.dart';

class GamificationProvider with ChangeNotifier {
  GamificationProfile? _profile;
  bool _isLoading = false;
  List<Map<String, dynamic>> _xpLeaderboard = [];
  List<Map<String, dynamic>> _gradeLeaderboard = [];
  List<Map<String, dynamic>> _streakLeaderboard = [];
  List<Achievement> _recentAchievements = [];

  final GamificationService _gamificationService = GamificationService();

  // Getters
  GamificationProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get xpLeaderboard => _xpLeaderboard;
  List<Map<String, dynamic>> get gradeLeaderboard => _gradeLeaderboard;
  List<Map<String, dynamic>> get streakLeaderboard => _streakLeaderboard;
  List<Achievement> get recentAchievements => _recentAchievements;

  // Computed properties
  int get currentLevel => _profile?.currentLevel ?? 1;
  int get totalXp => _profile?.totalXp ?? 0;
  double get levelProgress => _profile?.levelProgress ?? 0.0;
  int get unlockedAchievementsCount => _profile?.unlockedAchievementsCount ?? 0;
  int get consecutiveLoginDays => _profile?.consecutiveLoginDays ?? 0;

  // Load gamification profile for a student
  Future<void> loadGamificationProfile(String studentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _profile = await _gamificationService.getGamificationProfile(studentId);
    } catch (e) {
      print('Error loading gamification profile: $e');
      _profile = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Process daily login and award bonus
  Future<int> processDailyLogin(String studentId) async {
    try {
      final bonusXp = await _gamificationService.processDailyLogin(studentId);

      // Reload profile to get updated data
      await loadGamificationProfile(studentId);

      return bonusXp;
    } catch (e) {
      print('Error processing daily login: $e');
      return 0;
    }
  }

  // Award XP for various activities
  Future<void> awardXp(String studentId, int xpAmount, String category) async {
    try {
      await _gamificationService.awardXp(studentId, xpAmount, category);

      // Reload profile to get updated data
      await loadGamificationProfile(studentId);

      // Check for milestones
      await checkAndUnlockMilestones(studentId);
    } catch (e) {
      print('Error awarding XP: $e');
    }
  }

  // Check and unlock achievements
  Future<List<Achievement>> checkAndUnlockAchievements(
    String studentId,
    Map<String, dynamic> stats,
  ) async {
    try {
      final unlockedAchievements = await _gamificationService.checkAndUnlockAchievements(
        studentId,
        stats,
      );

      if (unlockedAchievements.isNotEmpty) {
        // Add to recent achievements
        _recentAchievements.insertAll(0, unlockedAchievements);
        // Keep only last 10
        if (_recentAchievements.length > 10) {
          _recentAchievements = _recentAchievements.sublist(0, 10);
        }

        // Reload profile
        await loadGamificationProfile(studentId);
      }

      notifyListeners();
      return unlockedAchievements;
    } catch (e) {
      print('Error checking achievements: $e');
      return [];
    }
  }

  // Check and unlock milestones
  Future<List<String>> checkAndUnlockMilestones(String studentId) async {
    try {
      final unlockedMilestones = await _gamificationService.checkAndUnlockMilestones(studentId);

      if (unlockedMilestones.isNotEmpty) {
        // Reload profile
        await loadGamificationProfile(studentId);
      }

      return unlockedMilestones;
    } catch (e) {
      print('Error checking milestones: $e');
      return [];
    }
  }

  // Load leaderboards
  Future<void> loadLeaderboards() async {
    _isLoading = true;
    notifyListeners();

    try {
      _xpLeaderboard = await _gamificationService.getLeaderboard('xp');
      _gradeLeaderboard = await _gamificationService.getLeaderboard('grades');
      _streakLeaderboard = await _gamificationService.getLeaderboard('streaks');
    } catch (e) {
      print('Error loading leaderboards: $e');
      _xpLeaderboard = [];
      _gradeLeaderboard = [];
      _streakLeaderboard = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Get leaderboard position for current user
  int getLeaderboardPosition(String studentId, String criteria) {
    List<Map<String, dynamic>> leaderboard;
    switch (criteria) {
      case 'xp':
        leaderboard = _xpLeaderboard;
        break;
      case 'grades':
        leaderboard = _gradeLeaderboard;
        break;
      case 'streaks':
        leaderboard = _streakLeaderboard;
        break;
      default:
        return -1;
    }

    for (int i = 0; i < leaderboard.length; i++) {
      if (leaderboard[i]['studentId'] == studentId) {
        return i + 1; // 1-based position
      }
    }
    return -1;
  }

  // Clear recent achievements (call after showing them)
  void clearRecentAchievements() {
    _recentAchievements.clear();
    notifyListeners();
  }

  // Get achievements by category
  List<Achievement> getAchievementsByCategory(String category) {
    if (_profile == null) return [];
    return _profile!.achievements.where((a) => a.category == category).toList();
  }

  // Get unlocked achievements
  List<Achievement> get unlockedAchievements {
    if (_profile == null) return [];
    return _profile!.achievements.where((a) => a.isUnlocked).toList();
  }

  // Get locked achievements
  List<Achievement> get lockedAchievements {
    if (_profile == null) return [];
    return _profile!.achievements.where((a) => !a.isUnlocked).toList();
  }

  // Get current level info
  Level? get currentLevelInfo {
    if (_profile == null) return null;
    return _profile!.getCurrentLevelInfo();
  }

  // Get next level info
  Level? get nextLevelInfo {
    if (_profile == null) return null;
    final levels = GamificationService.getLevels();
    final nextLevelIndex = levels.indexWhere((l) => l.level == currentLevel + 1);
    if (nextLevelIndex != -1) {
      return levels[nextLevelIndex];
    }
    return null;
  }

  // Reset provider (for logout)
  void reset() {
    _profile = null;
    _xpLeaderboard = [];
    _gradeLeaderboard = [];
    _streakLeaderboard = [];
    _recentAchievements = [];
    notifyListeners();
  }
}