import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/career_recommendation_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/quiz_provider.dart';
import '../providers/class_provider.dart';
import '../services/progress_service.dart';
import '../models/career_recommendation.dart';

class CareerRecommendationScreen extends StatefulWidget {
  const CareerRecommendationScreen({super.key});

  @override
  State<CareerRecommendationScreen> createState() => _CareerRecommendationScreenState();
}

class _CareerRecommendationScreenState extends State<CareerRecommendationScreen> {
  final ProgressService _progressService = ProgressService();

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final careerProvider = Provider.of<CareerRecommendationProvider>(context, listen: false);
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    final classProvider = Provider.of<ClassProvider>(context, listen: false);

    final user = authProvider.user;
    if (user == null) return;

    // Check if we have cached recommendations that aren't stale
    if (careerProvider.hasRecommendations && !careerProvider.areRecommendationsStale) {
      return; // Use cached recommendations
    }

    // Load necessary data for generating recommendations
    final studentId = user.id;

    // Load quiz results
    await quizProvider.loadQuizResults(studentId);

    // Load enrolled classes
    await classProvider.loadClasses(user.id, user.role);

    // Load study sessions
    final studySessions = await _progressService.getStudySessions(studentId);
    final enrolledClasses = classProvider.classes
        .where((classModel) => classModel.enrolledStudents.contains(studentId))
        .toList();

    // Generate new recommendations
    await careerProvider.generateRecommendations(
      user: user,
      quizResults: quizProvider.quizResults,
      enrolledClasses: enrolledClasses,
      studySessions: studySessions,
    );
  }

  @override
  Widget build(BuildContext context) {
    final careerProvider = Provider.of<CareerRecommendationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Career Recommendations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRecommendations,
            tooltip: 'Refresh Recommendations',
          ),
        ],
      ),
      body: careerProvider.isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Analyzing your profile...'),
                  SizedBox(height: 8),
                  Text('This may take a few moments', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : careerProvider.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: ${careerProvider.error}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadRecommendations,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with insights
                      _buildInsightsHeader(careerProvider),

                      const SizedBox(height: 24),

                      // Career recommendations list
                      const Text(
                        'Recommended Careers',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      careerProvider.recommendations.isEmpty
                          ? const Card(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: Text(
                                    'No career recommendations available yet.\nComplete more quizzes and classes to get personalized recommendations.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: careerProvider.recommendations.length,
                              itemBuilder: (context, index) {
                                final recommendation = careerProvider.recommendations[index];
                                return _buildCareerCard(recommendation, index + 1);
                              },
                            ),

                      const SizedBox(height: 32),

                      // Career categories overview
                      if (careerProvider.hasRecommendations) ...[
                        const Text(
                          'Career Categories',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _buildCategoryOverview(careerProvider),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildInsightsHeader(CareerRecommendationProvider provider) {
    final insights = provider.getCareerInsights();

    return Card(
      elevation: 4,
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.insights, color: Colors.blue, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI Career Insights',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      if (provider.lastGenerated != null)
                        Text(
                          'Generated ${provider.lastGenerated!.toLocal().toString().split(' ')[0]}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (insights['totalCareers'] > 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInsightStat(
                    '${insights['totalCareers']}',
                    'Careers Found',
                    Colors.blue,
                  ),
                  _buildInsightStat(
                    '${insights['averageMatch'].toStringAsFixed(1)}%',
                    'Avg Match',
                    Colors.green,
                  ),
                  _buildInsightStat(
                    '${insights['highestMatch'].toStringAsFixed(1)}%',
                    'Best Match',
                    Colors.amber,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Your top career category: ${insights['topCategory']}',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.blue,
                ),
              ),
            ] else ...[
              const Text(
                'Complete more assessments to unlock personalized career insights.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInsightStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildCareerCard(CareerRecommendation recommendation, int rank) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with rank and match percentage
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '#$rank',
                    style: TextStyle(
                      color: Colors.amber.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    recommendation.careerName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getMatchColor(recommendation.matchPercentage),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${recommendation.matchPercentage.toStringAsFixed(1)}% Match',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Category and salary
            Row(
              children: [
                Icon(_getCategoryIcon(recommendation.careerCategory), size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  recommendation.careerCategory,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.attach_money, size: 16, color: Colors.grey),
                Text(
                  recommendation.salaryRange,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              recommendation.description,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),

            const SizedBox(height: 16),

            // Required skills
            const Text(
              'Required Skills:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: recommendation.requiredSkills.map((skill) {
                return Chip(
                  label: Text(skill, style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.blue.shade50,
                  side: BorderSide(color: Colors.blue.shade200),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            // Recommended subjects
            const Text(
              'Recommended Subjects:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: recommendation.recommendedSubjects.map((subject) {
                return Chip(
                  label: Text(subject, style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.green.shade50,
                  side: BorderSide(color: Colors.green.shade200),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            // Job outlook
            Row(
              children: [
                const Icon(Icons.trending_up, size: 16, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  'Job Outlook: ${recommendation.jobOutlook}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryOverview(CareerRecommendationProvider provider) {
    final insights = provider.getCareerInsights();
    final categories = insights['categories'] as Map<String, int>;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Career Interests by Category',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...categories.entries.map((entry) {
              final percentage = (entry.value / provider.recommendations.length * 100).round();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(_getCategoryIcon(entry.key), size: 20, color: _getCategoryColor(entry.key)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${entry.key} (${entry.value} careers)',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _getCategoryColor(entry.key),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Color _getMatchColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.blue;
    if (percentage >= 40) return Colors.orange;
    return Colors.red;
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'technology':
        return Icons.computer;
      case 'healthcare':
        return Icons.local_hospital;
      case 'education':
        return Icons.school;
      case 'business':
        return Icons.business;
      case 'creative':
        return Icons.palette;
      case 'science':
        return Icons.science;
      case 'finance':
        return Icons.account_balance;
      default:
        return Icons.work;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'technology':
        return Colors.blue;
      case 'healthcare':
        return Colors.red;
      case 'education':
        return Colors.green;
      case 'business':
        return Colors.purple;
      case 'creative':
        return Colors.pink;
      case 'science':
        return Colors.teal;
      case 'finance':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
}