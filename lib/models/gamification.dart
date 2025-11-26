import 'dart:convert';
import 'package:http/http.dart' as http;

class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String category; // study, quiz, streak, social
  final int xpReward;
  final Map<String, dynamic> criteria; // Conditions to unlock
  bool isUnlocked;
  DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.xpReward,
    required this.criteria,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      category: json['category'],
      xpReward: json['xpReward'] ?? 0,
      criteria: json['criteria'] ?? {},
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null ? DateTime.parse(json['unlockedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'category': category,
      'xpReward': xpReward,
      'criteria': criteria,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }
}

class Level {
  final int level;
  final String title;
  final int xpRequired;
  final List<String> rewards; // Unlocked features or badges

  Level({
    required this.level,
    required this.title,
    required this.xpRequired,
    required this.rewards,
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      level: json['level'] ?? 1,
      title: json['title'] ?? 'Beginner',
      xpRequired: json['xpRequired'] ?? 0,
      rewards: List<String>.from(json['rewards'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'title': title,
      'xpRequired': xpRequired,
      'rewards': rewards,
    };
  }
}

class GamificationProfile {
  final String studentId;
  int totalXp;
  int currentLevel;
  final List<Achievement> achievements;
  final Map<String, int> categoryXp; // study, quiz, streak, social
  final DateTime lastActivityDate;
  final int weeklyXp;
  final int monthlyXp;
  final List<DateTime> loginDates; // Track daily logins for bonuses
  int consecutiveLoginDays;
  final List<String> unlockedMilestones; // XP milestone rewards

  GamificationProfile({
    required this.studentId,
    required this.totalXp,
    required this.currentLevel,
    required this.achievements,
    required this.categoryXp,
    required this.lastActivityDate,
    required this.weeklyXp,
    required this.monthlyXp,
    required this.loginDates,
    required this.consecutiveLoginDays,
    required this.unlockedMilestones,
  });

  factory GamificationProfile.fromJson(Map<String, dynamic> json) {
    return GamificationProfile(
      studentId: json['studentId'],
      totalXp: json['totalXp'] ?? 0,
      currentLevel: json['currentLevel'] ?? 1,
      achievements: (json['achievements'] as List<dynamic>?)
          ?.map((a) => Achievement.fromJson(a))
          .toList() ?? [],
      categoryXp: Map<String, int>.from(json['categoryXp'] ?? {}),
      lastActivityDate: DateTime.parse(json['lastActivityDate']),
      weeklyXp: json['weeklyXp'] ?? 0,
      monthlyXp: json['monthlyXp'] ?? 0,
      loginDates: (json['loginDates'] as List<dynamic>?)
          ?.map((d) => DateTime.parse(d))
          .toList() ?? [],
      consecutiveLoginDays: json['consecutiveLoginDays'] ?? 0,
      unlockedMilestones: List<String>.from(json['unlockedMilestones'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'totalXp': totalXp,
      'currentLevel': currentLevel,
      'achievements': achievements.map((a) => a.toJson()).toList(),
      'categoryXp': categoryXp,
      'lastActivityDate': lastActivityDate.toIso8601String(),
      'weeklyXp': weeklyXp,
      'monthlyXp': monthlyXp,
      'loginDates': loginDates.map((d) => d.toIso8601String()).toList(),
      'consecutiveLoginDays': consecutiveLoginDays,
      'unlockedMilestones': unlockedMilestones,
    };
  }

  // Helper methods
  int get unlockedAchievementsCount => achievements.where((a) => a.isUnlocked).length;
  double get levelProgress {
    final currentLevelXp = getXpForLevel(currentLevel);
    final nextLevelXp = getXpForLevel(currentLevel + 1);
    final levelXp = totalXp - currentLevelXp;
    final levelRange = nextLevelXp - currentLevelXp;
    return levelRange > 0 ? levelXp / levelRange : 1.0;
  }

  static int getXpForLevel(int level) {
    // XP required follows a curve: level 1 = 0, level 2 = 100, level 3 = 250, etc.
    return ((level - 1) * 100 * level) ~/ 2;
  }

  Level getCurrentLevelInfo() {
    final levels = GamificationService.getLevels();
    return levels.firstWhere(
      (level) => level.level == currentLevel,
      orElse: () => levels.first,
    );
  }
}

class GamificationService {
  static const String baseUrl = 'http://localhost:3000/api'; // Adjust as needed

  // Predefined achievements
  static List<Achievement> getDefaultAchievements() {
    return [
      // Quiz Achievements
      Achievement(
        id: 'first_quiz',
        name: 'Quiz Beginner',
        description: 'Complete your first quiz',
        icon: 'quiz',
        category: 'quiz',
        xpReward: 50,
        criteria: {'quizzesCompleted': 1},
      ),
      Achievement(
        id: 'quiz_master',
        name: 'Quiz Master',
        description: 'Complete 10 quizzes',
        icon: 'school',
        category: 'quiz',
        xpReward: 200,
        criteria: {'quizzesCompleted': 10},
      ),
      Achievement(
        id: 'quiz_expert',
        name: 'Quiz Expert',
        description: 'Complete 50 quizzes',
        icon: 'psychology',
        category: 'quiz',
        xpReward: 500,
        criteria: {'quizzesCompleted': 50},
      ),
      Achievement(
        id: 'perfect_score',
        name: 'Perfect Score',
        description: 'Get 100% on any quiz',
        icon: 'grade',
        category: 'quiz',
        xpReward: 150,
        criteria: {'perfectScore': true},
      ),
      Achievement(
        id: 'speed_demon',
        name: 'Speed Demon',
        description: 'Complete a quiz in under 5 minutes',
        icon: 'flash',
        category: 'quiz',
        xpReward: 100,
        criteria: {'fastQuizCompletion': true},
      ),

      // Study Achievements
      Achievement(
        id: 'first_hour',
        name: 'Hour of Study',
        description: 'Study for 1 hour total',
        icon: 'schedule',
        category: 'study',
        xpReward: 100,
        criteria: {'totalStudyHours': 1},
      ),
      Achievement(
        id: 'dedicated_learner',
        name: 'Dedicated Learner',
        description: 'Study for 10 hours total',
        icon: 'library_books',
        category: 'study',
        xpReward: 500,
        criteria: {'totalStudyHours': 10},
      ),
      Achievement(
        id: 'study_champion',
        name: 'Study Champion',
        description: 'Study for 100 hours total',
        icon: 'military_tech',
        category: 'study',
        xpReward: 2000,
        criteria: {'totalStudyHours': 100},
      ),
      Achievement(
        id: 'early_bird',
        name: 'Early Bird',
        description: 'Study before 6 AM',
        icon: 'wb_sunny',
        category: 'study',
        xpReward: 75,
        criteria: {'earlyStudy': true},
      ),

      // Streak Achievements
      Achievement(
        id: 'study_streak_3',
        name: 'Getting Started',
        description: 'Study for 3 consecutive days',
        icon: 'local_fire_department',
        category: 'streak',
        xpReward: 100,
        criteria: {'currentStreak': 3},
      ),
      Achievement(
        id: 'study_streak_7',
        name: 'Week Warrior',
        description: 'Study for 7 consecutive days',
        icon: 'local_fire_department',
        category: 'streak',
        xpReward: 300,
        criteria: {'currentStreak': 7},
      ),
      Achievement(
        id: 'study_streak_30',
        name: 'Monthly Master',
        description: 'Study for 30 consecutive days',
        icon: 'emoji_events',
        category: 'streak',
        xpReward: 1000,
        criteria: {'currentStreak': 30},
      ),
      Achievement(
        id: 'study_streak_100',
        name: 'Century Champion',
        description: 'Study for 100 consecutive days',
        icon: 'workspace_premium',
        category: 'streak',
        xpReward: 5000,
        criteria: {'currentStreak': 100},
      ),

      // Grade Achievements
      Achievement(
        id: 'academic_excellence',
        name: 'Academic Excellence',
        description: 'Maintain 90%+ average grade',
        icon: 'star',
        category: 'quiz',
        xpReward: 400,
        criteria: {'averageGrade': 90.0},
      ),
      Achievement(
        id: 'grade_perfectionist',
        name: 'Grade Perfectionist',
        description: 'Maintain 95%+ average grade',
        icon: 'stars',
        category: 'quiz',
        xpReward: 800,
        criteria: {'averageGrade': 95.0},
      ),

      // Daily Login Achievements
      Achievement(
        id: 'login_streak_7',
        name: 'Login Loyalist',
        description: 'Login for 7 consecutive days',
        icon: 'login',
        category: 'streak',
        xpReward: 250,
        criteria: {'consecutiveLoginDays': 7},
      ),
      Achievement(
        id: 'login_streak_30',
        name: 'Login Legend',
        description: 'Login for 30 consecutive days',
        icon: 'verified_user',
        category: 'streak',
        xpReward: 1000,
        criteria: {'consecutiveLoginDays': 30},
      ),

      // Social Achievements
      Achievement(
        id: 'first_class_join',
        name: 'Class Joiner',
        description: 'Join your first class',
        icon: 'group_add',
        category: 'social',
        xpReward: 50,
        criteria: {'classesJoined': 1},
      ),
      Achievement(
        id: 'social_butterfly',
        name: 'Social Butterfly',
        description: 'Join 5 classes',
        icon: 'groups',
        category: 'social',
        xpReward: 200,
        criteria: {'classesJoined': 5},
      ),

      // Milestone Achievements (XP-based)
      Achievement(
        id: 'xp_milestone_1000',
        name: 'XP Explorer',
        description: 'Reach 1000 XP',
        icon: 'explore',
        category: 'study',
        xpReward: 100,
        criteria: {'totalXp': 1000},
      ),
      Achievement(
        id: 'xp_milestone_5000',
        name: 'XP Adventurer',
        description: 'Reach 5000 XP',
        icon: 'hiking',
        category: 'study',
        xpReward: 250,
        criteria: {'totalXp': 5000},
      ),
      Achievement(
        id: 'xp_milestone_10000',
        name: 'XP Champion',
        description: 'Reach 10000 XP',
        icon: 'trophy',
        category: 'study',
        xpReward: 500,
        criteria: {'totalXp': 10000},
      ),
    ];
  }

  // Predefined levels
  static List<Level> getLevels() {
    return [
      Level(level: 1, title: 'Beginner', xpRequired: 0, rewards: ['Basic Dashboard']),
      Level(level: 2, title: 'Learner', xpRequired: 100, rewards: ['Progress Charts']),
      Level(level: 3, title: 'Student', xpRequired: 250, rewards: ['Advanced Analytics']),
      Level(level: 4, title: 'Scholar', xpRequired: 450, rewards: ['Custom Study Plans']),
      Level(level: 5, title: 'Expert', xpRequired: 700, rewards: ['Priority Support']),
      Level(level: 6, title: 'Master', xpRequired: 1000, rewards: ['Exclusive Content']),
      Level(level: 7, title: 'Legend', xpRequired: 1350, rewards: ['Mentorship Access']),
      Level(level: 8, title: 'Champion', xpRequired: 1750, rewards: ['Beta Features']),
      Level(level: 9, title: 'Elite', xpRequired: 2200, rewards: ['Advanced Badges']),
      Level(level: 10, title: 'Grandmaster', xpRequired: 2700, rewards: ['VIP Support']),
      Level(level: 11, title: 'Mythical', xpRequired: 3250, rewards: ['Custom Themes']),
      Level(level: 12, title: 'Legendary', xpRequired: 3850, rewards: ['Exclusive Events']),
      Level(level: 13, title: 'Immortal', xpRequired: 4500, rewards: ['Hall of Fame']),
      Level(level: 14, title: 'Divine', xpRequired: 5200, rewards: ['Ultimate Access']),
      Level(level: 15, title: 'Transcendent', xpRequired: 5950, rewards: ['All Features Unlocked']),
    ];
  }

  Future<GamificationProfile> getGamificationProfile(String studentId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/gamification/$studentId'));
      if (response.statusCode == 200) {
        return GamificationProfile.fromJson(json.decode(response.body));
      }
      // Return default profile if not found
      return GamificationProfile(
        studentId: studentId,
        totalXp: 0,
        currentLevel: 1,
        achievements: getDefaultAchievements(),
        categoryXp: {'study': 0, 'quiz': 0, 'streak': 0, 'social': 0},
        lastActivityDate: DateTime.now(),
        weeklyXp: 0,
        monthlyXp: 0,
        loginDates: [],
        consecutiveLoginDays: 0,
        unlockedMilestones: [],
      );
    } catch (e) {
      print('Error fetching gamification profile: $e');
      return GamificationProfile(
        studentId: studentId,
        totalXp: 0,
        currentLevel: 1,
        achievements: getDefaultAchievements(),
        categoryXp: {'study': 0, 'quiz': 0, 'streak': 0, 'social': 0},
        lastActivityDate: DateTime.now(),
        weeklyXp: 0,
        monthlyXp: 0,
        loginDates: [],
        consecutiveLoginDays: 0,
        unlockedMilestones: [],
      );
    }
  }

  Future<void> updateGamificationProfile(GamificationProfile profile) async {
    try {
      await http.put(
        Uri.parse('$baseUrl/gamification/${profile.studentId}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(profile.toJson()),
      );
    } catch (e) {
      print('Error updating gamification profile: $e');
    }
  }

  Future<void> awardXp(String studentId, int xpAmount, String category) async {
    final profile = await getGamificationProfile(studentId);

    profile.categoryXp[category] = (profile.categoryXp[category] ?? 0) + xpAmount;

    final newTotalXp = profile.categoryXp.values.fold<int>(0, (sum, xp) => sum + xp);
    profile.totalXp = newTotalXp;

    // Update level
    int newLevel = 1;
    for (final level in getLevels()) {
      if (newTotalXp >= level.xpRequired) {
        newLevel = level.level;
      } else {
        break;
      }
    }
    profile.currentLevel = newLevel;

    // Check for new achievements
    for (final achievement in profile.achievements) {
      if (!achievement.isUnlocked) {
        // This would need to be implemented based on actual student stats
        // For now, we'll keep it simple
      }
    }

    await updateGamificationProfile(profile);
  }

  Future<List<Achievement>> checkAndUnlockAchievements(
    String studentId,
    Map<String, dynamic> stats,
  ) async {
    final profile = await getGamificationProfile(studentId);
    final unlockedAchievements = <Achievement>[];

    for (final achievement in profile.achievements) {
      if (!achievement.isUnlocked && _meetsCriteria(achievement.criteria, stats)) {
        achievement.isUnlocked = true;
        achievement.unlockedAt = DateTime.now();
        unlockedAchievements.add(achievement);

        // Award XP for achievement
        await awardXp(studentId, achievement.xpReward, achievement.category);
      }
    }

    if (unlockedAchievements.isNotEmpty) {
      await updateGamificationProfile(profile);
    }

    return unlockedAchievements;
  }

  bool _meetsCriteria(Map<String, dynamic> criteria, Map<String, dynamic> stats) {
    for (final entry in criteria.entries) {
      final statKey = entry.key;
      final requiredValue = entry.value;
      final actualValue = stats[statKey];

      if (actualValue == null) return false;

      if (requiredValue is num && actualValue is num) {
        if (actualValue < requiredValue) return false;
      } else if (requiredValue is bool && actualValue is bool) {
        if (actualValue != requiredValue) return false;
      } else {
        // For other types, exact match
        if (actualValue != requiredValue) return false;
      }
    }
    return true;
  }

  // Daily login bonus system
  Future<int> processDailyLogin(String studentId) async {
    final profile = await getGamificationProfile(studentId);
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // Check if already logged in today
    final hasLoggedInToday = profile.loginDates.any((date) {
      final loginDate = DateTime(date.year, date.month, date.day);
      return loginDate == todayDate;
    });

    if (hasLoggedInToday) return 0; // No bonus for multiple logins in same day

    // Add today's login
    profile.loginDates.add(today);

    // Calculate consecutive days
    int consecutiveDays = 1;
    DateTime checkDate = todayDate.subtract(const Duration(days: 1));

    while (profile.loginDates.any((date) {
      final loginDate = DateTime(date.year, date.month, date.day);
      return loginDate == checkDate;
    })) {
      consecutiveDays++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    profile.consecutiveLoginDays = consecutiveDays;

    // Calculate bonus XP based on streak
    int bonusXp = 10; // Base bonus
    if (consecutiveDays >= 7) bonusXp = 50;
    if (consecutiveDays >= 30) bonusXp = 100;
    if (consecutiveDays >= 100) bonusXp = 200;

    // Award bonus XP
    await awardXp(studentId, bonusXp, 'streak');

    // Check for login streak achievements
    await checkAndUnlockAchievements(studentId, {
      'consecutiveLoginDays': consecutiveDays,
    });

    await updateGamificationProfile(profile);
    return bonusXp;
  }

  // Milestone rewards system
  Future<List<String>> checkAndUnlockMilestones(String studentId) async {
    final profile = await getGamificationProfile(studentId);
    final unlockedMilestones = <String>[];

    final milestones = [
      {'xp': 1000, 'id': 'xp_1000', 'reward': 100},
      {'xp': 2500, 'id': 'xp_2500', 'reward': 250},
      {'xp': 5000, 'id': 'xp_5000', 'reward': 500},
      {'xp': 10000, 'id': 'xp_10000', 'reward': 1000},
      {'xp': 25000, 'id': 'xp_25000', 'reward': 2500},
      {'xp': 50000, 'id': 'xp_50000', 'reward': 5000},
    ];

    for (final milestone in milestones) {
      final xpThreshold = milestone['xp'] as int;
      final milestoneId = milestone['id'] as String;
      final rewardXp = milestone['reward'] as int;

      if (profile.totalXp >= xpThreshold && !profile.unlockedMilestones.contains(milestoneId)) {
        profile.unlockedMilestones.add(milestoneId);
        unlockedMilestones.add(milestoneId);

        // Award milestone reward XP
        await awardXp(studentId, rewardXp, 'study');
      }
    }

    if (unlockedMilestones.isNotEmpty) {
      await updateGamificationProfile(profile);
    }

    return unlockedMilestones;
  }

  // Leaderboard data
  Future<List<Map<String, dynamic>>> getLeaderboard(String criteria) async {
    // This would typically fetch from backend
    // For now, return mock data structure
    try {
      final response = await http.get(Uri.parse('$baseUrl/leaderboard/$criteria'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((item) => item as Map<String, dynamic>).toList();
      }
    } catch (e) {
      print('Error fetching leaderboard: $e');
    }
    return [];
  }
}