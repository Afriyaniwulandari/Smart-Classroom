import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../models/user.dart';
import '../models/quiz_result.dart';
import '../models/attendance.dart';
import '../models/student_progress.dart';
import '../models/gamification.dart';
import '../models/class_model.dart';
import '../services/progress_service.dart';
import '../services/quiz_service.dart';
import '../services/attendance_service.dart';
import 'package:intl/intl.dart';

class ReportService {
  final ProgressService _progressService = ProgressService();
  final QuizService _quizService = QuizService();
  final AttendanceService _attendanceService = AttendanceService();

  Future<String> generateSemesterReport(
    String studentId,
    DateTime semesterStart,
    DateTime semesterEnd,
  ) async {
    // Fetch all required data
    final user = await _getUser(studentId);
    final quizResults = await _getQuizResultsInSemester(studentId, semesterStart, semesterEnd);
    final attendanceRecords = await _getAttendanceInSemester(studentId, semesterStart, semesterEnd);
    final studySessions = await _getStudySessionsInSemester(studentId, semesterStart, semesterEnd);
    final enrolledClasses = await _getEnrolledClasses(studentId);
    final gamificationProfile = await _getGamificationProfile(studentId);

    // Calculate stats
    final stats = await _progressService.calculateStudentStats(
      studentId,
      quizResults,
      enrolledClasses,
      attendanceRecords,
      studySessions,
    );

    // Generate PDF
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          _buildHeader(user, semesterStart, semesterEnd),
          pw.SizedBox(height: 20),
          _buildStudentProgressSection(stats),
          pw.SizedBox(height: 20),
          _buildGradesSection(quizResults),
          pw.SizedBox(height: 20),
          _buildAttendanceSection(attendanceRecords),
          pw.SizedBox(height: 20),
          _buildQuizResultsSection(quizResults),
          pw.SizedBox(height: 20),
          _buildAchievementsSection(gamificationProfile),
        ],
      ),
    );

    // Save PDF
    final output = await _getOutputFilePath(user.name, semesterStart, semesterEnd);
    final file = File(output);
    await file.writeAsBytes(await pdf.save());

    return output;
  }

  pw.Widget _buildHeader(User user, DateTime start, DateTime end) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Semester Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Text('Student: ${user.name}', style: pw.TextStyle(fontSize: 16)),
        pw.Text('Email: ${user.email}', style: pw.TextStyle(fontSize: 14)),
        pw.Text('Period: ${DateFormat('MMM dd, yyyy').format(start)} - ${DateFormat('MMM dd, yyyy').format(end)}',
            style: pw.TextStyle(fontSize: 14)),
        pw.Text('Generated on: ${DateFormat('MMM dd, yyyy').format(DateTime.now())}',
            style: pw.TextStyle(fontSize: 12)),
      ],
    );
  }

  pw.Widget _buildStudentProgressSection(StudentStats stats) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Student Progress', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            pw.TableRow(
              children: [
                pw.Text('Total Study Hours', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('${stats.totalStudyHours}'),
              ],
            ),
            pw.TableRow(
              children: [
                pw.Text('Current Streak', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('${stats.currentStreak} days'),
              ],
            ),
            pw.TableRow(
              children: [
                pw.Text('Longest Streak', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('${stats.longestStreak} days'),
              ],
            ),
            pw.TableRow(
              children: [
                pw.Text('Average Grade', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('${stats.averageGrade.toStringAsFixed(1)}%'),
              ],
            ),
            pw.TableRow(
              children: [
                pw.Text('Total Quizzes Taken', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('${stats.totalQuizzesTaken}'),
              ],
            ),
            pw.TableRow(
              children: [
                pw.Text('XP Points', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('${stats.xpPoints}'),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Text('Study Hours by Subject:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.Table(
          border: pw.TableBorder.all(),
          children: stats.studyHoursBySubject.entries.map((entry) {
            return pw.TableRow(
              children: [
                pw.Text(entry.key),
                pw.Text('${(entry.value / 60).toStringAsFixed(1)} hours'),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  pw.Widget _buildGradesSection(List<QuizResult> quizResults) {
    final completedQuizzes = quizResults.where((q) => q.isCompleted).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Grades Overview', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Text('Completed Quizzes: ${completedQuizzes.length}', style: pw.TextStyle(fontSize: 14)),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            pw.TableRow(
              children: [
                pw.Text('Quiz ID', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('Score', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('Percentage', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ],
            ),
            ...completedQuizzes.map((quiz) {
              return pw.TableRow(
                children: [
                  pw.Text(quiz.quizId),
                  pw.Text('${quiz.totalScore}/${quiz.maxScore}'),
                  pw.Text('${quiz.percentage.toStringAsFixed(1)}%'),
                  pw.Text(quiz.completedAt != null ? DateFormat('MMM dd').format(quiz.completedAt!) : 'N/A'),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildAttendanceSection(List<Attendance> attendanceRecords) {
    final presentCount = attendanceRecords.where((a) => a.isPresent).length;
    final totalCount = attendanceRecords.length;
    final attendanceRate = totalCount > 0 ? (presentCount / totalCount * 100) : 0;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Attendance Statistics', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Text('Attendance Rate: ${attendanceRate.toStringAsFixed(1)}%', style: pw.TextStyle(fontSize: 14)),
        pw.Text('Present: $presentCount / Total: $totalCount', style: pw.TextStyle(fontSize: 14)),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            pw.TableRow(
              children: [
                pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('Class', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('Status', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('Type', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ],
            ),
            ...attendanceRecords.take(20).map((attendance) { // Limit to 20 entries
              return pw.TableRow(
                children: [
                  pw.Text(DateFormat('MMM dd').format(attendance.timestamp)),
                  pw.Text(attendance.className),
                  pw.Text(attendance.isPresent ? 'Present' : 'Absent'),
                  pw.Text(attendance.type.toString().split('.').last),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildQuizResultsSection(List<QuizResult> quizResults) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Quiz Performance Details', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Text('Recent Quiz Results:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 5),
        ...quizResults.take(10).map((quiz) {
          return pw.Container(
            margin: pw.EdgeInsets.only(bottom: 8),
            padding: pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Quiz: ${quiz.quizId}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('Score: ${quiz.totalScore}/${quiz.maxScore} (${quiz.percentage.toStringAsFixed(1)}%)'),
                pw.Text('Time Taken: ${quiz.timeTakenMinutes} minutes'),
                pw.Text('Completed: ${quiz.completedAt != null ? DateFormat('MMM dd, yyyy').format(quiz.completedAt!) : 'Not completed'}'),
              ],
            ),
          );
        }),
      ],
    );
  }

  pw.Widget _buildAchievementsSection(GamificationProfile? profile) {
    if (profile == null) return pw.Text('Achievements: No data available');

    final unlockedAchievements = profile.achievements.where((a) => a.isUnlocked).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Achievements & Gamification', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Text('Level: ${profile.currentLevel}', style: pw.TextStyle(fontSize: 14)),
        pw.Text('Total XP: ${profile.totalXp}', style: pw.TextStyle(fontSize: 14)),
        pw.Text('Unlocked Achievements: ${unlockedAchievements.length}', style: pw.TextStyle(fontSize: 14)),
        pw.SizedBox(height: 10),
        pw.Text('Recent Achievements:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 5),
        ...unlockedAchievements.take(5).map((achievement) {
          return pw.Bullet(
            text: '${achievement.name}: ${achievement.description}',
          );
        }),
      ],
    );
  }

  Future<User> _getUser(String studentId) async {
    // This would need to be implemented based on how users are fetched
    // For now, return a mock user
    return User(
      id: studentId,
      email: 'student@example.com',
      name: 'Student Name',
      role: 'student',
    );
  }

  Future<List<QuizResult>> _getQuizResultsInSemester(String studentId, DateTime start, DateTime end) async {
    final allResults = await _quizService.getQuizResults(studentId);
    return allResults.where((result) {
      if (result.completedAt == null) return false;
      return result.completedAt!.isAfter(start) && result.completedAt!.isBefore(end);
    }).toList();
  }

  Future<List<Attendance>> _getAttendanceInSemester(String studentId, DateTime start, DateTime end) async {
    final allAttendance = await _attendanceService.getAttendanceForStudent(studentId);
    return allAttendance.where((attendance) {
      return attendance.timestamp.isAfter(start) && attendance.timestamp.isBefore(end);
    }).toList();
  }

  Future<List<StudySession>> _getStudySessionsInSemester(String studentId, DateTime start, DateTime end) async {
    final allSessions = await _progressService.getStudySessions(studentId);
    return allSessions.where((session) {
      return session.startTime.isAfter(start) && session.startTime.isBefore(end);
    }).toList();
  }

  Future<List<ClassModel>> _getEnrolledClasses(String studentId) async {
    return await _progressService.getEnrolledCoursesHistory(studentId);
  }

  Future<GamificationProfile?> _getGamificationProfile(String studentId) async {
    // This would use the gamification service
    // For now, return null
    return null;
  }

  Future<String> _getOutputFilePath(String studentName, DateTime start, DateTime end) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'semester_report_${studentName.replaceAll(' ', '_')}_${DateFormat('yyyy_MM').format(start)}.pdf';
    return '${directory.path}/$fileName';
  }
}