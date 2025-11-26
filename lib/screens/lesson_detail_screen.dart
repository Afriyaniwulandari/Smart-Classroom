import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../providers/class_provider.dart';
import '../providers/quiz_provider.dart';
import '../providers/bookmark_provider.dart';
import '../models/lesson.dart' as lesson_models;
import 'create_quiz_screen.dart';
import 'take_quiz_screen.dart';
import 'quiz_results_screen.dart';

class LessonDetailScreen extends StatefulWidget {
  final lesson_models.Lesson lesson;

  const LessonDetailScreen({super.key, required this.lesson});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load quizzes for this lesson
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final quizProvider = Provider.of<QuizProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      quizProvider.loadQuizzes(widget.lesson.id);
      if (user != null) {
        quizProvider.loadQuizResults(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final classProvider = Provider.of<ClassProvider>(context);
    final quizProvider = Provider.of<QuizProvider>(context);
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);
    final user = authProvider.user;
    final lesson = widget.lesson;

    return Scaffold(
      appBar: AppBar(
        title: Text(lesson.title),
        actions: [
          if (user != null)
            IconButton(
              icon: Icon(
                bookmarkProvider.isBookmarked(lesson.id, user.id)
                    ? Icons.bookmark
                    : Icons.bookmark_border,
              ),
              onPressed: () {
                if (bookmarkProvider.isBookmarked(lesson.id, user.id)) {
                  bookmarkProvider.removeBookmark(lesson.id, user.id);
                } else {
                  bookmarkProvider.addBookmark(lesson, user.id);
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lesson.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text('Duration: ${lesson.durationMinutes} minutes'),
            Text('Scheduled: ${lesson.scheduledDate.toString().split(' ')[0]}'),
            const SizedBox(height: 16),
            if (lesson.isCompleted)
              const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Completed', style: TextStyle(color: Colors.green)),
                ],
              ),
            const SizedBox(height: 24),
            const Text(
              'Materials:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            lesson.materials.isEmpty
                ? const Text('No materials available')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: lesson.materials.length,
                    itemBuilder: (context, index) {
                      final material = lesson.materials[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(material.title),
                          subtitle: material.description != null ? Text(material.description!) : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_getMaterialIcon(material.type)),
                              IconButton(
                                icon: const Icon(Icons.download),
                                onPressed: () => _downloadMaterial(material),
                              ),
                            ],
                          ),
                          onTap: () => _openMaterial(material),
                        ),
                      );
                    },
                  ),
             const SizedBox(height: 24),
             // Quiz section
             const Text(
               'Quizzes:',
               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
             ),
             const SizedBox(height: 16),
             if (quizProvider.isLoading)
               const Center(child: CircularProgressIndicator())
             else if (quizProvider.quizzes.isEmpty)
               Column(
                 children: [
                   const Text('No quizzes available for this lesson'),
                   if (user?.role == 'teacher')
                     Padding(
                       padding: const EdgeInsets.only(top: 16),
                       child: ElevatedButton.icon(
                         onPressed: () {
                           Navigator.of(context).push(
                             MaterialPageRoute(
                               builder: (context) => CreateQuizScreen(lessonId: lesson.id),
                             ),
                           ).then((_) {
                             // Reload quizzes after creating
                             quizProvider.loadQuizzes(lesson.id);
                           });
                         },
                         icon: const Icon(Icons.add),
                         label: const Text('Create Quiz'),
                       ),
                     ),
                 ],
               )
             else
               Column(
                 children: quizProvider.quizzes.map((quiz) {
                   return Card(
                     margin: const EdgeInsets.only(bottom: 8),
                     child: Padding(
                       padding: const EdgeInsets.all(16),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text(
                             quiz.title,
                             style: const TextStyle(
                               fontSize: 16,
                               fontWeight: FontWeight.bold,
                             ),
                           ),
                           const SizedBox(height: 4),
                           Text(
                             quiz.description,
                             style: const TextStyle(fontSize: 14, color: Colors.grey),
                           ),
                           const SizedBox(height: 8),
                           Row(
                             children: [
                               const Icon(Icons.question_answer, size: 16),
                               const SizedBox(width: 4),
                               Text('${quiz.questions.length} questions'),
                               const SizedBox(width: 16),
                               const Icon(Icons.timer, size: 16),
                               const SizedBox(width: 4),
                               Text(quiz.timeLimitMinutes > 0
                                   ? '${quiz.timeLimitMinutes} min'
                                   : 'No limit'),
                             ],
                           ),
                           const SizedBox(height: 12),
                           if (user?.role == 'teacher')
                             Row(
                               children: [
                                 Expanded(
                                   child: OutlinedButton.icon(
                                     onPressed: () {
                                       Navigator.of(context).push(
                                         MaterialPageRoute(
                                           builder: (context) => CreateQuizScreen(
                                             lessonId: lesson.id,
                                             quiz: quiz,
                                           ),
                                         ),
                                       ).then((_) {
                                         quizProvider.loadQuizzes(lesson.id);
                                       });
                                     },
                                     icon: const Icon(Icons.edit),
                                     label: const Text('Edit'),
                                   ),
                                 ),
                                 const SizedBox(width: 8),
                                 Expanded(
                                   child: OutlinedButton.icon(
                                     onPressed: () async {
                                       final confirmed = await showDialog<bool>(
                                         context: context,
                                         builder: (context) => AlertDialog(
                                           title: const Text('Delete Quiz'),
                                           content: const Text('Are you sure you want to delete this quiz?'),
                                           actions: [
                                             TextButton(
                                               onPressed: () => Navigator.of(context).pop(false),
                                               child: const Text('Cancel'),
                                             ),
                                             TextButton(
                                               onPressed: () => Navigator.of(context).pop(true),
                                               child: const Text('Delete'),
                                               style: TextButton.styleFrom(foregroundColor: Colors.red),
                                             ),
                                           ],
                                         ),
                                       );

                                       if (confirmed == true) {
                                         await quizProvider.deleteQuiz(quiz.id);
                                       }
                                     },
                                     icon: const Icon(Icons.delete),
                                     label: const Text('Delete'),
                                     style: OutlinedButton.styleFrom(
                                       foregroundColor: Colors.red,
                                     ),
                                   ),
                                 ),
                               ],
                             )
                           else if (user?.role == 'student')
                             Builder(
                               builder: (context) {
                                 final quizResult = quizProvider.quizResults
                                     .where((result) => result.quizId == quiz.id)
                                     .firstOrNull;

                                 if (quizResult != null && quizResult.isCompleted) {
                                   // Student has completed the quiz
                                   return Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                       Row(
                                         children: [
                                           const Icon(Icons.check_circle, color: Colors.green, size: 20),
                                           const SizedBox(width: 4),
                                           Text(
                                             'Completed - ${quizResult.percentage.toStringAsFixed(1)}%',
                                             style: const TextStyle(
                                               color: Colors.green,
                                               fontWeight: FontWeight.bold,
                                             ),
                                           ),
                                         ],
                                       ),
                                       const SizedBox(height: 8),
                                       ElevatedButton(
                                         onPressed: () {
                                           Navigator.of(context).push(
                                             MaterialPageRoute(
                                               builder: (context) => QuizResultsScreen(quizResult: quizResult),
                                             ),
                                           );
                                         },
                                         child: const Text('View Results'),
                                       ),
                                     ],
                                   );
                                 } else {
                                   // Student hasn't taken the quiz yet
                                   return ElevatedButton(
                                     onPressed: () {
                                       Navigator.of(context).push(
                                         MaterialPageRoute(
                                           builder: (context) => TakeQuizScreen(quiz: quiz),
                                         ),
                                       ).then((_) {
                                         // Reload quiz results after taking quiz
                                         quizProvider.loadQuizResults(user!.id, quizId: quiz.id);
                                       });
                                     },
                                     child: const Text('Take Quiz'),
                                   );
                                 }
                               },
                             ),
                         ],
                       ),
                     ),
                   );
                 }).toList(),
               ),
             const SizedBox(height: 24),
             if (user?.role == 'student' && !lesson.isCompleted)
              ElevatedButton(
                onPressed: classProvider.isLoading
                    ? null
                    : () async {
                        final success = await classProvider.markLessonCompleted(
                          lesson.id,
                          user!.id,
                        );
                        if (success && mounted) {
                          setState(() {
                            // Update local state
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Lesson marked as completed')),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: classProvider.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Mark as Completed'),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getMaterialIcon(lesson_models.MaterialType type) {
    switch (type) {
      case lesson_models.MaterialType.pdf:
        return Icons.picture_as_pdf;
      case lesson_models.MaterialType.video:
        return Icons.video_file;
      case lesson_models.MaterialType.audio:
        return Icons.audio_file;
      case lesson_models.MaterialType.image:
        return Icons.image;
      case lesson_models.MaterialType.text:
        return Icons.text_fields;
    }
  }

  Future<void> _openMaterial(lesson_models.Material material) async {
    final bookmarkProvider = Provider.of<BookmarkProvider>(context, listen: false);
    final filename = '${widget.lesson.id}_${material.id}_${material.title}';
    final localPath = await bookmarkProvider.getLocalPath(filename);

    if (localPath != null) {
      // Open local file
      // For simplicity, show a message; in real app, use file opener
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${material.title} opened from local storage')),
      );
    } else {
      final url = material.url;
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cannot open ${material.title}')),
          );
        }
      }
    }
  }

  Future<void> _downloadMaterial(lesson_models.Material material) async {
    final bookmarkProvider = Provider.of<BookmarkProvider>(context, listen: false);
    final filename = '${widget.lesson.id}_${material.id}_${material.title}';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Downloading...'),
          ],
        ),
      ),
    );

    try {
      final localPath = await bookmarkProvider.downloadMaterial(
        material.url,
        filename,
        onProgress: (progress) {
          // Could update progress here
        },
      );

      Navigator.of(context).pop(); // Close dialog

      if (localPath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${material.title} downloaded successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download failed')),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    }
  }
}