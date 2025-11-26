class StudySession {
  final String id;
  final String studentId;
  final String classId;
  final String className;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationMinutes; // Total study time in minutes
  final String? notes;

  StudySession({
    required this.id,
    required this.studentId,
    required this.classId,
    required this.className,
    required this.startTime,
    this.endTime,
    required this.durationMinutes,
    this.notes,
  });

  factory StudySession.fromJson(Map<String, dynamic> json) {
    return StudySession(
      id: json['id'],
      studentId: json['studentId'],
      classId: json['classId'],
      className: json['className'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      durationMinutes: json['durationMinutes'] ?? 0,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'classId': classId,
      'className': className,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationMinutes': durationMinutes,
      'notes': notes,
    };
  }
}

class DailyTarget {
  final String id;
  final String studentId;
  final DateTime date;
  final int targetMinutes; // Daily study target in minutes
  final int completedMinutes; // Actual study time completed
  final List<String> completedTasks; // List of completed learning tasks

  DailyTarget({
    required this.id,
    required this.studentId,
    required this.date,
    required this.targetMinutes,
    required this.completedMinutes,
    required this.completedTasks,
  });

  factory DailyTarget.fromJson(Map<String, dynamic> json) {
    return DailyTarget(
      id: json['id'],
      studentId: json['studentId'],
      date: DateTime.parse(json['date']),
      targetMinutes: json['targetMinutes'] ?? 0,
      completedMinutes: json['completedMinutes'] ?? 0,
      completedTasks: List<String>.from(json['completedTasks'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'date': date.toIso8601String(),
      'targetMinutes': targetMinutes,
      'completedMinutes': completedMinutes,
      'completedTasks': completedTasks,
    };
  }

  double get progressPercentage => targetMinutes > 0 ? (completedMinutes / targetMinutes) * 100 : 0;
  bool get isCompleted => completedMinutes >= targetMinutes;
}

class StudentStats {
  final int totalStudyHours;
  final int currentStreak; // Consecutive days with study
  final int longestStreak;
  final double averageGrade;
  final int totalQuizzesTaken;
  final int totalClassesEnrolled;
  final int xpPoints;
  final List<String> badgesEarned;
  final Map<String, double> gradeTrends; // Date string -> grade percentage
  final Map<String, int> studyHoursBySubject; // Subject -> hours

  StudentStats({
    required this.totalStudyHours,
    required this.currentStreak,
    required this.longestStreak,
    required this.averageGrade,
    required this.totalQuizzesTaken,
    required this.totalClassesEnrolled,
    required this.xpPoints,
    required this.badgesEarned,
    required this.gradeTrends,
    required this.studyHoursBySubject,
  });

  factory StudentStats.empty() {
    return StudentStats(
      totalStudyHours: 0,
      currentStreak: 0,
      longestStreak: 0,
      averageGrade: 0.0,
      totalQuizzesTaken: 0,
      totalClassesEnrolled: 0,
      xpPoints: 0,
      badgesEarned: [],
      gradeTrends: {},
      studyHoursBySubject: {},
    );
  }
}

class Reminder {
  final String id;
  final String studentId;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isCompleted;
  final String? classId;

  Reminder({
    required this.id,
    required this.studentId,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    this.classId,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'],
      studentId: json['studentId'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['dueDate']),
      isCompleted: json['isCompleted'] ?? false,
      classId: json['classId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'classId': classId,
    };
  }

  bool get isOverdue => !isCompleted && dueDate.isBefore(DateTime.now());
  bool get isDueToday => dueDate.day == DateTime.now().day &&
                        dueDate.month == DateTime.now().month &&
                        dueDate.year == DateTime.now().year;
}