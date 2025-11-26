import '../models/class_model.dart';
import '../models/lesson.dart';

class ClassService {
  // Mock data for development
  final List<Map<String, dynamic>> _mockClasses = [
    {
      'id': '1',
      'name': 'Mathematics 101',
      'description': 'Basic mathematics concepts and problem solving',
      'teacherId': '2',
      'teacherName': 'Jane Teacher',
      'competencies': ['Algebra', 'Geometry', 'Calculus'],
      'enrolledStudents': ['1'],
      'createdAt': '2024-01-01T00:00:00.000Z',
    },
    {
      'id': '2',
      'name': 'Physics Fundamentals',
      'description': 'Introduction to physics principles',
      'teacherId': '2',
      'teacherName': 'Jane Teacher',
      'competencies': ['Mechanics', 'Thermodynamics', 'Electricity'],
      'enrolledStudents': [],
      'createdAt': '2024-01-02T00:00:00.000Z',
    },
  ];

  final List<Map<String, dynamic>> _mockLessons = [
    {
      'id': '1',
      'classId': '1',
      'title': 'Introduction to Algebra',
      'description': 'Basic algebraic operations and equations',
      'materials': [
        {
          'id': '1',
          'title': 'Algebra Basics PDF',
          'type': 1, // pdf
          'url': 'https://example.com/algebra.pdf',
          'description': 'Comprehensive guide to algebra',
        },
        {
          'id': '2',
          'title': 'Algebra Video',
          'type': 3, // video
          'url': 'https://example.com/algebra.mp4',
          'description': 'Video explanation of algebra concepts',
        },
      ],
      'scheduledDate': '2024-01-15T10:00:00.000Z',
      'durationMinutes': 60,
      'isCompleted': false,
      'createdAt': '2024-01-01T00:00:00.000Z',
    },
  ];

  Future<List<ClassModel>> getClasses(String userId, String userRole) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    if (userRole == 'teacher') {
      return _mockClasses
          .where((c) => c['teacherId'] == userId)
          .map((c) => ClassModel.fromJson(c))
          .toList();
    } else {
      // For students, return all classes (in real app, would filter by enrolled or available)
      return _mockClasses.map((c) => ClassModel.fromJson(c)).toList();
    }
  }

  Future<List<Lesson>> getLessons(String classId) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    return _mockLessons
        .where((l) => l['classId'] == classId)
        .map((l) => Lesson.fromJson(l))
        .toList();
  }

  Future<bool> enrollStudent(String classId, String studentId) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    final classIndex = _mockClasses.indexWhere((c) => c['id'] == classId);
    if (classIndex != -1) {
      final enrolledStudents = _mockClasses[classIndex]['enrolledStudents'] as List;
      if (!enrolledStudents.contains(studentId)) {
        enrolledStudents.add(studentId);
        return true;
      }
    }
    return false;
  }

  Future<bool> unenrollStudent(String classId, String studentId) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    final classIndex = _mockClasses.indexWhere((c) => c['id'] == classId);
    if (classIndex != -1) {
      final enrolledStudents = _mockClasses[classIndex]['enrolledStudents'] as List;
      enrolledStudents.remove(studentId);
      return true;
    }
    return false;
  }

  Future<bool> createClass(ClassModel classModel) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    _mockClasses.add(classModel.toJson());
    return true;
  }

  Future<bool> createLesson(Lesson lesson) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    _mockLessons.add(lesson.toJson());
    return true;
  }

  Future<bool> markLessonCompleted(String lessonId, String studentId) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    final lessonIndex = _mockLessons.indexWhere((l) => l['id'] == lessonId);
    if (lessonIndex != -1) {
      _mockLessons[lessonIndex]['isCompleted'] = true;
      return true;
    }
    return false;
  }
}