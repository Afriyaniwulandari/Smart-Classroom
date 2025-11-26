import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/student_progress.dart';
import '../models/quiz_result.dart';
import '../models/class_model.dart';
import '../models/attendance.dart';
import 'security_service.dart';

class ProgressService {
  static const String baseUrl = 'http://localhost:3000/api'; // Adjust as needed
  final SecurityService _securityService = SecurityService();

  // Study Sessions
  Future<List<StudySession>> getStudySessions(String studentId) async {
    try {
      final headers = _securityService.getSecurityHeaders(null);
      final response = await http.get(
        Uri.parse('$baseUrl/study-sessions/$studentId'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => StudySession.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching study sessions: $e');
      return [];
    }
  }

  Future<void> logStudySession(StudySession session) async {
    try {
      final headers = _securityService.getSecurityHeaders(null);
      await http.post(
        Uri.parse('$baseUrl/study-sessions'),
        headers: headers,
        body: json.encode(session.toJson()),
      );
    } catch (e) {
      print('Error logging study session: $e');
    }
  }

  // Daily Targets
  Future<List<DailyTarget>> getDailyTargets(String studentId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/daily-targets/$studentId'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => DailyTarget.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching daily targets: $e');
      return [];
    }
  }

  Future<void> updateDailyTarget(DailyTarget target) async {
    try {
      await http.put(
        Uri.parse('$baseUrl/daily-targets/${target.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(target.toJson()),
      );
    } catch (e) {
      print('Error updating daily target: $e');
    }
  }

  // Reminders
  Future<List<Reminder>> getReminders(String studentId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/reminders/$studentId'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Reminder.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching reminders: $e');
      return [];
    }
  }

  Future<void> addReminder(Reminder reminder) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/reminders'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(reminder.toJson()),
      );
    } catch (e) {
      print('Error adding reminder: $e');
    }
  }

  // Calculate comprehensive student statistics
  Future<StudentStats> calculateStudentStats(
    String studentId,
    List<QuizResult> quizResults,
    List<ClassModel> enrolledClasses,
    List<Attendance> attendanceRecords,
    List<StudySession> studySessions,
  ) async {
    // Calculate grade trends (last 30 days)
    final gradeTrends = <String, double>{};
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

    final recentQuizzes = quizResults.where((quiz) =>
      quiz.completedAt != null && quiz.completedAt!.isAfter(thirtyDaysAgo)
    ).toList();

    for (var quiz in recentQuizzes) {
      final dateKey = '${quiz.completedAt!.year}-${quiz.completedAt!.month.toString().padLeft(2, '0')}-${quiz.completedAt!.day.toString().padLeft(2, '0')}';
      gradeTrends[dateKey] = quiz.percentage;
    }

    // Calculate study hours by subject
    final studyHoursBySubject = <String, int>{};
    for (var session in studySessions) {
      studyHoursBySubject[session.className] = (studyHoursBySubject[session.className] ?? 0) + session.durationMinutes;
    }

    // Calculate streaks
    final studyDates = studySessions
        .where((session) => session.endTime != null)
        .map((session) => session.startTime)
        .toSet()
        .toList()
      ..sort();

    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;

    for (int i = 0; i < studyDates.length; i++) {
      if (i == 0 || studyDates[i].difference(studyDates[i - 1]).inDays == 1) {
        tempStreak++;
      } else {
        longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;
        tempStreak = 1;
      }
    }
    longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;

    // Check if today has study session
    final today = DateTime.now();
    final hasStudiedToday = studyDates.any((date) =>
      date.year == today.year && date.month == today.month && date.day == today.day
    );

    if (hasStudiedToday) {
      currentStreak = tempStreak;
    } else if (studyDates.isNotEmpty) {
      final lastStudyDate = studyDates.last;
      final daysSinceLastStudy = today.difference(lastStudyDate).inDays;
      if (daysSinceLastStudy == 1) {
        currentStreak = tempStreak;
      } else {
        currentStreak = 0;
      }
    }

    // Calculate average grade
    final completedQuizzes = quizResults.where((quiz) => quiz.isCompleted).toList();
    final averageGrade = completedQuizzes.isNotEmpty
        ? completedQuizzes.map((q) => q.percentage).reduce((a, b) => a + b) / completedQuizzes.length
        : 0.0;

    // Calculate total study hours
    final totalStudyHours = studySessions.fold<int>(0, (sum, session) => sum + session.durationMinutes) ~/ 60;

    // Gamification: Calculate XP (simplified)
    int xpPoints = 0;
    xpPoints += completedQuizzes.length * 10; // 10 XP per quiz
    xpPoints += totalStudyHours * 5; // 5 XP per study hour
    xpPoints += currentStreak * 20; // 20 XP per streak day

    // Badges (simplified examples)
    final badgesEarned = <String>[];
    if (completedQuizzes.length >= 5) badgesEarned.add('Quiz Master');
    if (totalStudyHours >= 10) badgesEarned.add('Dedicated Learner');
    if (currentStreak >= 7) badgesEarned.add('Consistency King');
    if (averageGrade >= 90) badgesEarned.add('Academic Excellence');

    return StudentStats(
      totalStudyHours: totalStudyHours,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      averageGrade: averageGrade,
      totalQuizzesTaken: completedQuizzes.length,
      totalClassesEnrolled: enrolledClasses.length,
      xpPoints: xpPoints,
      badgesEarned: badgesEarned,
      gradeTrends: gradeTrends,
      studyHoursBySubject: studyHoursBySubject,
    );
  }

  // Get enrolled courses history
  Future<List<ClassModel>> getEnrolledCoursesHistory(String studentId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/classes/enrolled/$studentId'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ClassModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching enrolled courses: $e');
      return [];
    }
  }

  // Get upcoming reminders (next 7 days)
  Future<List<Reminder>> getUpcomingReminders(String studentId) async {
    final allReminders = await getReminders(studentId);
    final nextWeek = DateTime.now().add(const Duration(days: 7));

    return allReminders
        .where((reminder) =>
            !reminder.isCompleted &&
            reminder.dueDate.isBefore(nextWeek) &&
            reminder.dueDate.isAfter(DateTime.now().subtract(const Duration(days: 1)))
        )
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  // Get today's daily target
  Future<DailyTarget?> getTodaysTarget(String studentId) async {
    final targets = await getDailyTargets(studentId);
    final today = DateTime.now();

    return targets.cast<DailyTarget?>().firstWhere(
      (target) =>
          target!.date.year == today.year &&
          target.date.month == today.month &&
          target.date.day == today.day,
      orElse: () => null,
    );
  }

  // Create or update today's target
  Future<void> setTodaysTarget(String studentId, int targetMinutes) async {
    final existingTarget = await getTodaysTarget(studentId);
    final today = DateTime.now();

    if (existingTarget != null) {
      final updatedTarget = DailyTarget(
        id: existingTarget.id,
        studentId: studentId,
        date: today,
        targetMinutes: targetMinutes,
        completedMinutes: existingTarget.completedMinutes,
        completedTasks: existingTarget.completedTasks,
      );
      await updateDailyTarget(updatedTarget);
    } else {
      final newTarget = DailyTarget(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        studentId: studentId,
        date: today,
        targetMinutes: targetMinutes,
        completedMinutes: 0,
        completedTasks: [],
      );
      await updateDailyTarget(newTarget);
    }
  }
}