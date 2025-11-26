import 'dart:math';
import '../models/career_recommendation.dart';
import '../models/user.dart';
import '../models/quiz_result.dart';
import '../models/class_model.dart';
import '../models/student_progress.dart';

class CareerRecommendationService {
  // Mock career database
  final List<Map<String, dynamic>> _careerDatabase = [
    {
      'careerName': 'Software Engineer',
      'description': 'Design, develop, and maintain software applications',
      'requiredSkills': ['Programming', 'Problem Solving', 'Mathematics', 'Algorithms'],
      'recommendedSubjects': ['Mathematics', 'Computer Science', 'Physics'],
      'careerCategory': 'Technology',
      'salaryRange': '\$80,000 - \$150,000',
      'jobOutlook': 'Growing rapidly',
      'interestKeywords': ['technology', 'programming', 'computers', 'math'],
      'strengthSubjects': ['Mathematics', 'Computer Science', 'Physics']
    },
    {
      'careerName': 'Data Scientist',
      'description': 'Analyze complex data sets to help organizations make decisions',
      'requiredSkills': ['Statistics', 'Programming', 'Machine Learning', 'Data Analysis'],
      'recommendedSubjects': ['Mathematics', 'Statistics', 'Computer Science'],
      'careerCategory': 'Technology',
      'salaryRange': '\$90,000 - \$160,000',
      'jobOutlook': 'High demand',
      'interestKeywords': ['data', 'analytics', 'statistics', 'research'],
      'strengthSubjects': ['Mathematics', 'Statistics', 'Computer Science']
    },
    {
      'careerName': 'Doctor',
      'description': 'Diagnose and treat patients, promote health and wellness',
      'requiredSkills': ['Biology', 'Chemistry', 'Communication', 'Critical Thinking'],
      'recommendedSubjects': ['Biology', 'Chemistry', 'Physics'],
      'careerCategory': 'Healthcare',
      'salaryRange': '\$150,000 - \$250,000',
      'jobOutlook': 'Stable demand',
      'interestKeywords': ['health', 'medicine', 'biology', 'helping others'],
      'strengthSubjects': ['Biology', 'Chemistry', 'Physics']
    },
    {
      'careerName': 'Teacher',
      'description': 'Educate and inspire students in various subjects',
      'requiredSkills': ['Communication', 'Subject Expertise', 'Patience', 'Leadership'],
      'recommendedSubjects': ['Education', 'Psychology', 'Subject of Expertise'],
      'careerCategory': 'Education',
      'salaryRange': '\$40,000 - \$80,000',
      'jobOutlook': 'Stable',
      'interestKeywords': ['teaching', 'education', 'helping others', 'knowledge'],
      'strengthSubjects': ['Any subject with strong performance']
    },
    {
      'careerName': 'Business Analyst',
      'description': 'Analyze business needs and help improve processes',
      'requiredSkills': ['Analysis', 'Communication', 'Problem Solving', 'Business Knowledge'],
      'recommendedSubjects': ['Business', 'Mathematics', 'Economics'],
      'careerCategory': 'Business',
      'salaryRange': '\$60,000 - \$110,000',
      'jobOutlook': 'Growing',
      'interestKeywords': ['business', 'analysis', 'strategy', 'management'],
      'strengthSubjects': ['Business', 'Mathematics', 'Economics']
    },
    {
      'careerName': 'Graphic Designer',
      'description': 'Create visual content for digital and print media',
      'requiredSkills': ['Creativity', 'Design Software', 'Art', 'Communication'],
      'recommendedSubjects': ['Art', 'Design', 'Computer Science'],
      'careerCategory': 'Creative',
      'salaryRange': '\$45,000 - \$85,000',
      'jobOutlook': 'Moderate growth',
      'interestKeywords': ['art', 'design', 'creativity', 'visual'],
      'strengthSubjects': ['Art', 'Design', 'Computer Science']
    },
    {
      'careerName': 'Environmental Scientist',
      'description': 'Study environmental issues and develop solutions',
      'requiredSkills': ['Research', 'Analysis', 'Biology', 'Chemistry'],
      'recommendedSubjects': ['Biology', 'Chemistry', 'Environmental Science'],
      'careerCategory': 'Science',
      'salaryRange': '\$50,000 - \$90,000',
      'jobOutlook': 'Growing',
      'interestKeywords': ['environment', 'nature', 'science', 'research'],
      'strengthSubjects': ['Biology', 'Chemistry', 'Environmental Science']
    },
    {
      'careerName': 'Financial Advisor',
      'description': 'Help clients manage their finances and investments',
      'requiredSkills': ['Mathematics', 'Economics', 'Communication', 'Trust Building'],
      'recommendedSubjects': ['Mathematics', 'Economics', 'Business'],
      'careerCategory': 'Finance',
      'salaryRange': '\$60,000 - \$150,000',
      'jobOutlook': 'Stable',
      'interestKeywords': ['finance', 'money', 'investing', 'economics'],
      'strengthSubjects': ['Mathematics', 'Economics', 'Business']
    }
  ];

  Future<List<CareerRecommendation>> generateRecommendations({
    required User user,
    required List<QuizResult> quizResults,
    required List<ClassModel> enrolledClasses,
    required List<StudySession> studySessions,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));

    // Calculate user profile scores
    final interestScores = _calculateInterestScores(user.interests ?? []);
    final subjectStrengths = _calculateSubjectStrengths(quizResults, enrolledClasses);
    final studyPatterns = _analyzeStudyPatterns(studySessions);

    // Generate recommendations
    final recommendations = <CareerRecommendation>[];

    for (final careerData in _careerDatabase) {
      final matchScore = _calculateCareerMatch(
        careerData,
        interestScores,
        subjectStrengths,
        studyPatterns,
      );

      if (matchScore > 30) { // Only include careers with >30% match
        recommendations.add(CareerRecommendation(
          id: '${careerData['careerName'].toLowerCase().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}',
          careerName: careerData['careerName'],
          description: careerData['description'],
          matchPercentage: matchScore,
          requiredSkills: List<String>.from(careerData['requiredSkills']),
          recommendedSubjects: List<String>.from(careerData['recommendedSubjects']),
          careerCategory: careerData['careerCategory'],
          salaryRange: careerData['salaryRange'],
          jobOutlook: careerData['jobOutlook'],
          generatedAt: DateTime.now(),
        ));
      }
    }

    // Sort by match percentage (highest first)
    recommendations.sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage));

    // Return top 5 recommendations
    return recommendations.take(5).toList();
  }

  Map<String, double> _calculateInterestScores(List<String> interests) {
    final scores = <String, double>{};

    for (final interest in interests) {
      final lowerInterest = interest.toLowerCase();
      for (final career in _careerDatabase) {
        final keywords = career['interestKeywords'] as List<String>;
        if (keywords.any((keyword) => lowerInterest.contains(keyword) || keyword.contains(lowerInterest))) {
          scores[career['careerName']] = (scores[career['careerName']] ?? 0) + 25.0;
        }
      }
    }

    return scores;
  }

  Map<String, double> _calculateSubjectStrengths(List<QuizResult> quizResults, List<ClassModel> enrolledClasses) {
    final subjectScores = <String, double>{};
    final subjectCounts = <String, int>{};

    // Analyze quiz performance by subject
    for (final result in quizResults) {
      // Find the class/competency this quiz belongs to
      final relatedClass = enrolledClasses.firstWhere(
        (classModel) => classModel.competencies.any((comp) => result.quizId.contains(comp.toLowerCase())),
        orElse: () => enrolledClasses.isNotEmpty ? enrolledClasses.first : ClassModel(
          id: 'unknown',
          name: 'Unknown',
          description: 'Unknown',
          teacherId: 'unknown',
          teacherName: 'Unknown',
          competencies: ['General'],
          enrolledStudents: [],
          createdAt: DateTime.now(),
        ),
      );

      for (final competency in relatedClass.competencies) {
        subjectScores[competency] = (subjectScores[competency] ?? 0) + result.percentage;
        subjectCounts[competency] = (subjectCounts[competency] ?? 0) + 1;
      }
    }

    // Calculate averages
    subjectScores.forEach((subject, totalScore) {
      final count = subjectCounts[subject] ?? 1;
      subjectScores[subject] = totalScore / count;
    });

    return subjectScores;
  }

  Map<String, double> _analyzeStudyPatterns(List<StudySession> studySessions) {
    final patterns = <String, double>{};

    if (studySessions.isEmpty) return patterns;

    // Analyze study time distribution
    final totalTime = studySessions.fold<double>(0, (sum, session) => sum + session.durationMinutes);
    final avgSessionTime = totalTime / studySessions.length;

    // Reward consistent study patterns
    if (avgSessionTime > 30) {
      patterns['consistency'] = min(20.0, avgSessionTime / 10);
    }

    // Analyze subject diversity
    final subjects = studySessions.map((s) => s.className).toSet();
    patterns['diversity'] = min(15.0, subjects.length * 3.0);

    return patterns;
  }

  double _calculateCareerMatch(
    Map<String, dynamic> career,
    Map<String, double> interestScores,
    Map<String, double> subjectStrengths,
    Map<String, double> studyPatterns,
  ) {
    double totalScore = 0;

    // Interest match (weight: 40%)
    final interestMatch = interestScores[career['careerName']] ?? 0;
    totalScore += interestMatch * 0.4;

    // Subject strength match (weight: 40%)
    final strengthSubjects = career['strengthSubjects'] as List<String>;
    double subjectMatch = 0;
    for (final subject in strengthSubjects) {
      subjectMatch += subjectStrengths[subject] ?? 0;
    }
    subjectMatch = strengthSubjects.isNotEmpty ? subjectMatch / strengthSubjects.length : 0;
    totalScore += subjectMatch * 0.4;

    // Study pattern bonus (weight: 20%)
    final consistencyBonus = studyPatterns['consistency'] ?? 0;
    final diversityBonus = studyPatterns['diversity'] ?? 0;
    final patternBonus = (consistencyBonus + diversityBonus) / 2;
    totalScore += patternBonus * 0.2;

    // Add some randomness to simulate AI unpredictability (±10%)
    final random = Random();
    final randomFactor = 1.0 + (random.nextDouble() - 0.5) * 0.2;

    return min(100.0, totalScore * randomFactor);
  }

  Future<List<CareerRecommendation>> getCachedRecommendations(String studentId) async {
    // Simulate API call to get cached recommendations
    await Future.delayed(const Duration(milliseconds: 500));

    // In a real app, this would fetch from a database
    // For now, return empty list (will be populated when generateRecommendations is called)
    return [];
  }

  Future<void> cacheRecommendations(String studentId, List<CareerRecommendation> recommendations) async {
    // Simulate caching recommendations
    await Future.delayed(const Duration(milliseconds: 300));

    // In a real app, this would save to a database
  }
}