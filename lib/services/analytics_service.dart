import '../providers/class_provider.dart';
import '../providers/attendance_provider.dart';
import '../providers/quiz_provider.dart';

class AnalyticsService {
  final ClassProvider _classProvider;
  final AttendanceProvider _attendanceProvider;
  final QuizProvider _quizProvider;

  AnalyticsService(this._classProvider, this._attendanceProvider, this._quizProvider);

  // Overview statistics
  Future<Map<String, dynamic>> getOverviewStats(String teacherId) async {
    final classes = _classProvider.classes.where((c) => c.teacherId == teacherId).toList();
    final totalClasses = classes.length;

    int totalStudents = 0;
    double totalAttendanceRate = 0.0;
    double totalAverageGrade = 0.0;
    int classesWithAttendanceData = 0;
    int classesWithGradeData = 0;

    for (final classModel in classes) {
      totalStudents += classModel.enrolledStudents.length;

      // Load attendance data for this class
      await _attendanceProvider.loadClassAttendance(classModel.id);
      final attendanceStats = _attendanceProvider.attendanceStatistics;

      if (attendanceStats.isNotEmpty) {
        totalAttendanceRate += (attendanceStats['averageAttendance'] ?? 0.0);
        classesWithAttendanceData++;
      }

      // Load quiz results for this class (simplified - get all quiz results for students in class)
      double classAverageGrade = 0.0;
      int studentsWithGrades = 0;

      for (final studentId in classModel.enrolledStudents) {
        await _quizProvider.loadQuizResults(studentId);
        final studentResults = _quizProvider.quizResults.where((r) => r.isCompleted).toList();

        if (studentResults.isNotEmpty) {
          final avgGrade = studentResults.map((r) => r.percentage).reduce((a, b) => a + b) / studentResults.length;
          classAverageGrade += avgGrade;
          studentsWithGrades++;
        }
      }

      if (studentsWithGrades > 0) {
        totalAverageGrade += (classAverageGrade / studentsWithGrades);
        classesWithGradeData++;
      }
    }

    return {
      'totalStudents': totalStudents,
      'totalClasses': totalClasses,
      'averageAttendanceRate': classesWithAttendanceData > 0 ? totalAttendanceRate / classesWithAttendanceData : 0.0,
      'averageGrade': classesWithGradeData > 0 ? totalAverageGrade / classesWithGradeData : 0.0,
    };
  }

  // Attendance trends for the last N days
  Future<List<Map<String, dynamic>>> getAttendanceTrends(String teacherId, int days) async {
    final classes = _classProvider.classes.where((c) => c.teacherId == teacherId).toList();
    final trends = <Map<String, dynamic>>[];

    final now = DateTime.now();
    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      int totalPresent = 0;
      int totalStudents = 0;

      for (final classModel in classes) {
        await _attendanceProvider.loadClassAttendance(classModel.id);
        final attendanceForDate = _attendanceProvider.getAttendanceForDate(classModel.id, date);
        totalPresent += attendanceForDate.where((a) => a.isPresent).length;
        totalStudents += classModel.enrolledStudents.length;
      }

      final rate = totalStudents > 0 ? (totalPresent / totalStudents) * 100 : 0.0;
      trends.add({
        'date': date,
        'attendanceRate': rate,
        'totalPresent': totalPresent,
        'totalStudents': totalStudents,
      });
    }

    return trends;
  }

  // Grade distribution
  Future<Map<String, int>> getGradeDistribution(String teacherId) async {
    final classes = _classProvider.classes.where((c) => c.teacherId == teacherId).toList();
    final distribution = {'A': 0, 'B': 0, 'C': 0, 'D': 0, 'F': 0};

    for (final classModel in classes) {
      for (final studentId in classModel.enrolledStudents) {
        await _quizProvider.loadQuizResults(studentId);
        final studentResults = _quizProvider.quizResults.where((r) => r.isCompleted).toList();

        if (studentResults.isNotEmpty) {
          final avgGrade = studentResults.map((r) => r.percentage).reduce((a, b) => a + b) / studentResults.length;
          String letterGrade;
          if (avgGrade >= 90) letterGrade = 'A';
          else if (avgGrade >= 80) letterGrade = 'B';
          else if (avgGrade >= 70) letterGrade = 'C';
          else if (avgGrade >= 60) letterGrade = 'D';
          else letterGrade = 'F';

          distribution[letterGrade] = (distribution[letterGrade] ?? 0) + 1;
        }
      }
    }

    return distribution;
  }

  // Engagement metrics
  Future<Map<String, dynamic>> getEngagementMetrics(String teacherId) async {
    final classes = _classProvider.classes.where((c) => c.teacherId == teacherId).toList();
    int totalQuizzesTaken = 0;
    int totalStudents = 0;

    for (final classModel in classes) {
      totalStudents += classModel.enrolledStudents.length;

      for (final studentId in classModel.enrolledStudents) {
        await _quizProvider.loadQuizResults(studentId);
        totalQuizzesTaken += _quizProvider.quizResults.where((r) => r.isCompleted).length;

        // Note: Lesson completion tracking would need to be implemented
        // For now, we'll use quiz completion as a proxy for engagement
      }
    }

    return {
      'averageQuizzesPerStudent': totalStudents > 0 ? (totalQuizzesTaken / totalStudents) : 0.0,
      'totalQuizzesTaken': totalQuizzesTaken,
    };
  }

  // Student performance data for table
  Future<List<Map<String, dynamic>>> getStudentPerformanceData(String teacherId) async {
    final classes = _classProvider.classes.where((c) => c.teacherId == teacherId).toList();
    final studentData = <Map<String, dynamic>>[];

    for (final classModel in classes) {
      for (final studentId in classModel.enrolledStudents) {
        await _attendanceProvider.loadStudentAttendance(studentId);
        await _quizProvider.loadQuizResults(studentId);

        final attendanceRecords = _attendanceProvider.studentAttendance
            .where((a) => a.classId == classModel.id)
            .toList();
        final attendanceRate = attendanceRecords.isNotEmpty
            ? (attendanceRecords.where((a) => a.isPresent).length / attendanceRecords.length) * 100
            : 0.0;

        final quizResults = _quizProvider.quizResults.where((r) => r.isCompleted).toList();
        final averageGrade = quizResults.isNotEmpty
            ? quizResults.map((r) => r.percentage).reduce((a, b) => a + b) / quizResults.length
            : 0.0;

        studentData.add({
          'studentId': studentId,
          'studentName': attendanceRecords.isNotEmpty ? attendanceRecords.first.studentName : 'Unknown',
          'className': classModel.name,
          'attendanceRate': attendanceRate,
          'averageGrade': averageGrade,
          'quizzesCompleted': quizResults.length,
        });
      }
    }

    return studentData;
  }
}