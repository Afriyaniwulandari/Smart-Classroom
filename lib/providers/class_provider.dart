import 'package:flutter/material.dart';
import '../models/class_model.dart';
import '../models/lesson.dart';
import '../services/class_service.dart';

class ClassProvider with ChangeNotifier {
  final ClassService _classService = ClassService();

  List<ClassModel> _classes = [];
  List<Lesson> _lessons = [];
  bool _isLoading = false;

  List<ClassModel> get classes => _classes;
  List<Lesson> get lessons => _lessons;
  bool get isLoading => _isLoading;

  Future<void> loadClasses(String userId, String userRole) async {
    _isLoading = true;
    notifyListeners();

    try {
      _classes = await _classService.getClasses(userId, userRole);
    } catch (e) {
      _classes = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadLessons(String classId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _lessons = await _classService.getLessons(classId);
    } catch (e) {
      _lessons = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> enrollInClass(String classId, String studentId) async {
    try {
      final success = await _classService.enrollStudent(classId, studentId);
      if (success) {
        // Update local class data
        final classIndex = _classes.indexWhere((c) => c.id == classId);
        if (classIndex != -1) {
          _classes[classIndex].enrolledStudents.add(studentId);
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> unenrollFromClass(String classId, String studentId) async {
    try {
      final success = await _classService.unenrollStudent(classId, studentId);
      if (success) {
        // Update local class data
        final classIndex = _classes.indexWhere((c) => c.id == classId);
        if (classIndex != -1) {
          _classes[classIndex].enrolledStudents.remove(studentId);
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> createClass(ClassModel classModel) async {
    try {
      final success = await _classService.createClass(classModel);
      if (success) {
        _classes.add(classModel);
        notifyListeners();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> createLesson(Lesson lesson) async {
    try {
      final success = await _classService.createLesson(lesson);
      if (success) {
        _lessons.add(lesson);
        notifyListeners();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> markLessonCompleted(String lessonId, String studentId) async {
    try {
      final success = await _classService.markLessonCompleted(lessonId, studentId);
      if (success) {
        final lessonIndex = _lessons.indexWhere((l) => l.id == lessonId);
        if (lessonIndex != -1) {
          _lessons[lessonIndex] = Lesson(
            id: _lessons[lessonIndex].id,
            classId: _lessons[lessonIndex].classId,
            title: _lessons[lessonIndex].title,
            description: _lessons[lessonIndex].description,
            materials: _lessons[lessonIndex].materials,
            scheduledDate: _lessons[lessonIndex].scheduledDate,
            durationMinutes: _lessons[lessonIndex].durationMinutes,
            isCompleted: true,
            createdAt: _lessons[lessonIndex].createdAt,
          );
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      return false;
    }
  }
}