import '../models/class_model.dart';
import '../models/lesson.dart';

class RecommendationService {
  // Mock recommendation logic
  Future<List<ClassModel>> getRecommendedClasses(String userId, List<String> interests) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock data - in real app, this would use ML algorithms
    final allClasses = [
      ClassModel(
        id: '1',
        name: 'Mathematics 101',
        description: 'Basic mathematics concepts',
        teacherId: '2',
        teacherName: 'Jane Teacher',
        competencies: ['Algebra', 'Geometry'],
        enrolledStudents: [],
        createdAt: DateTime.now(),
      ),
      ClassModel(
        id: '2',
        name: 'Physics Fundamentals',
        description: 'Introduction to physics',
        teacherId: '2',
        teacherName: 'Jane Teacher',
        competencies: ['Mechanics', 'Thermodynamics'],
        enrolledStudents: [],
        createdAt: DateTime.now(),
      ),
    ];

    // Simple recommendation based on interests
    return allClasses.where((classModel) {
      return classModel.competencies.any((competency) =>
          interests.any((interest) =>
              competency.toLowerCase().contains(interest.toLowerCase())));
    }).toList();
  }

  Future<List<Lesson>> getRecommendedLessons(String userId, List<String> interests) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock lessons
    final allLessons = [
      Lesson(
        id: '1',
        classId: '1',
        title: 'Introduction to Algebra',
        description: 'Basic algebraic operations',
        materials: [],
        scheduledDate: DateTime.now().add(const Duration(days: 1)),
        durationMinutes: 60,
        createdAt: DateTime.now(),
      ),
      Lesson(
        id: '2',
        classId: '2',
        title: 'Newton\'s Laws',
        description: 'Fundamental principles of motion',
        materials: [],
        scheduledDate: DateTime.now().add(const Duration(days: 2)),
        durationMinutes: 45,
        createdAt: DateTime.now(),
      ),
    ];

    // Simple filtering based on interests
    return allLessons.where((lesson) {
      return interests.any((interest) =>
          lesson.title.toLowerCase().contains(interest.toLowerCase()) ||
          lesson.description.toLowerCase().contains(interest.toLowerCase()));
    }).toList();
  }

  Future<List<Lesson>> getNextLessonRecommendations(String currentLessonId, String userId) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock next lesson recommendations
    return [
      Lesson(
        id: '3',
        classId: '1',
        title: 'Advanced Algebra',
        description: 'Complex algebraic equations',
        materials: [],
        scheduledDate: DateTime.now().add(const Duration(days: 7)),
        durationMinutes: 60,
        createdAt: DateTime.now(),
      ),
    ];
  }

  Future<List<String>> getPersonalizedHints(String lessonId, String userId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock AI-generated hints
    return [
      'Remember to distribute terms carefully in equations',
      'Check your work by substituting values back into the original equation',
      'Practice with similar problems to reinforce understanding',
    ];
  }
}