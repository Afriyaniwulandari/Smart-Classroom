import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/recommendation_provider.dart';
import 'class_detail_screen.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final recommendationProvider = Provider.of<RecommendationProvider>(context, listen: false);
    final user = authProvider.user;

    if (user != null) {
      recommendationProvider.loadRecommendations(user.id, user.interests ?? []);
    }
  }

  @override
  Widget build(BuildContext context) {
    final recommendationProvider = Provider.of<RecommendationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Recommendations'),
      ),
      body: recommendationProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recommended Classes',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  recommendationProvider.recommendedClasses.isEmpty
                      ? const Text('No class recommendations available')
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: recommendationProvider.recommendedClasses.length,
                          itemBuilder: (context, index) {
                            final classItem = recommendationProvider.recommendedClasses[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(classItem.name),
                                subtitle: Text(classItem.description),
                                trailing: const Icon(Icons.arrow_forward),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ClassDetailScreen(classModel: classItem),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                  const SizedBox(height: 32),
                  const Text(
                    'Recommended Lessons',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  recommendationProvider.recommendedLessons.isEmpty
                      ? const Text('No lesson recommendations available')
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: recommendationProvider.recommendedLessons.length,
                          itemBuilder: (context, index) {
                            final lesson = recommendationProvider.recommendedLessons[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(lesson.title),
                                subtitle: Text(lesson.description),
                                trailing: Text('${lesson.durationMinutes} min'),
                              ),
                            );
                          },
                        ),
                  const SizedBox(height: 32),
                  const Text(
                    'AI Insights',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Learning Pattern Analysis',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Based on your progress, you excel in visual learning. Try incorporating more diagrams and videos into your study routine.',
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Recommended Study Time: 45 minutes daily',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Your optimal learning time appears to be in the morning. Consider scheduling important lessons during this time.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}