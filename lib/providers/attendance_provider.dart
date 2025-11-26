import 'dart:async';
import 'package:flutter/material.dart';
import '../models/attendance.dart';
import '../services/attendance_service.dart';

class AttendanceProvider with ChangeNotifier {
  final AttendanceService _attendanceService = AttendanceService();

  List<Attendance> _classAttendance = [];
  List<Attendance> _studentAttendance = [];
  Map<String, dynamic> _attendanceStatistics = {};
  bool _isLoading = false;
  String? _currentAttendanceCode;
  Timer? _codeExpirationTimer;

  List<Attendance> get classAttendance => _classAttendance;
  List<Attendance> get studentAttendance => _studentAttendance;
  Map<String, dynamic> get attendanceStatistics => _attendanceStatistics;
  bool get isLoading => _isLoading;
  String? get currentAttendanceCode => _currentAttendanceCode;

  Future<void> loadClassAttendance(String classId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _classAttendance = await _attendanceService.getAttendanceForClass(classId);
    } catch (e) {
      _classAttendance = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadStudentAttendance(String studentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _studentAttendance = await _attendanceService.getAttendanceForStudent(studentId);
    } catch (e) {
      _studentAttendance = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markAttendance(String studentId, String studentName, String classId, String className, AttendanceType type, {String? notes}) async {
    try {
      final success = await _attendanceService.markAttendance(studentId, studentName, classId, className, type, notes: notes);
      if (success) {
        // Reload attendance data
        await loadClassAttendance(classId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> markBulkAttendance(String classId, String className, List<Map<String, dynamic>> attendanceData) async {
    try {
      final success = await _attendanceService.markBulkAttendance(classId, className, attendanceData);
      if (success) {
        // Reload attendance data
        await loadClassAttendance(classId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<void> loadAttendanceStatistics(String classId) async {
    try {
      _attendanceStatistics = await _attendanceService.getAttendanceStatistics(classId);
      notifyListeners();
    } catch (e) {
      _attendanceStatistics = {};
      notifyListeners();
    }
  }

  Future<bool> generateAttendanceCode(String classId) async {
    try {
      _currentAttendanceCode = await _attendanceService.generateAttendanceCode(classId);

      // Set timer to expire code after 5 minutes
      _codeExpirationTimer?.cancel();
      _codeExpirationTimer = Timer(const Duration(minutes: 5), () {
        _currentAttendanceCode = null;
        notifyListeners();
      });

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyAttendanceCode(String code, String studentId, String studentName, String classId, String className) async {
    try {
      final success = await _attendanceService.verifyAttendanceCode(code, studentId, studentName, classId, className);
      if (success) {
        // Reload attendance data
        await loadClassAttendance(classId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  void clearCurrentCode() {
    _currentAttendanceCode = null;
    _codeExpirationTimer?.cancel();
    notifyListeners();
  }

  // Helper methods for filtering and statistics
  List<Attendance> getAttendanceForDate(String classId, DateTime date) {
    return _classAttendance.where((attendance) {
      return attendance.classId == classId &&
             attendance.timestamp.year == date.year &&
             attendance.timestamp.month == date.month &&
             attendance.timestamp.day == date.day;
    }).toList();
  }

  List<Attendance> getAttendanceForStudentInClass(String studentId, String classId) {
    return _classAttendance.where((attendance) =>
      attendance.studentId == studentId && attendance.classId == classId
    ).toList();
  }

  double getAttendancePercentage(String studentId, String classId) {
    final studentAttendance = getAttendanceForStudentInClass(studentId, classId);
    if (studentAttendance.isEmpty) return 0.0;

    final presentCount = studentAttendance.where((a) => a.isPresent).length;
    return (presentCount / studentAttendance.length) * 100;
  }

  int getTotalSessions(String classId) {
    final uniqueDates = _classAttendance
        .where((a) => a.classId == classId)
        .map((a) => DateTime(a.timestamp.year, a.timestamp.month, a.timestamp.day))
        .toSet()
        .length;
    return uniqueDates;
  }

  int getPresentCount(String classId, DateTime date) {
    return getAttendanceForDate(classId, date).where((a) => a.isPresent).length;
  }

  int getLateCount(String classId, DateTime date) {
    return getAttendanceForDate(classId, date).where((a) => a.isLate).length;
  }

  @override
  void dispose() {
    _codeExpirationTimer?.cancel();
    super.dispose();
  }
}