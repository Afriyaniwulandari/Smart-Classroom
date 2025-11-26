import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quiz.dart';
import '../models/quiz_result.dart';
import '../providers/quiz_provider.dart';

class QuizResultsScreen extends StatelessWidget {
  final QuizResult quizResult;

  const QuizResultsScreen({super.key, required this.quizResult});

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
    final quiz = quizProvider.currentQuiz;

    if (quiz == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isPassed = quizResult.percentage >= 60.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            child: const Text(
              'Done',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Score overview
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      isPassed ? Icons.check_circle : Icons.cancel,
                      size: 64,
                      color: isPassed ? Colors.green : Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isPassed ? 'Congratulations!' : 'Try Again',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You scored ${quizResult.totalScore} out of ${quizResult.maxScore} points',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${quizResult.percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isPassed ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.access_time, size: 20),
                        const SizedBox(width: 8),
                        Text('Time taken: ${quizResult.timeTakenMinutes} minutes'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Certificate section
            if (isPassed && quizResult.certificateUrl != null)
              Card(
                elevation: 4,
                color: Colors.amber.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        size: 48,
                        color: Colors.amber,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Certificate Earned!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'You have successfully completed this quiz.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          // In a real app, this would open/download the certificate
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Certificate downloaded!')),
                          );
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('Download Certificate'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Question breakdown
            const Text(
              'Question Breakdown',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: quizResult.answers.length,
              itemBuilder: (context, index) {
                final answer = quizResult.answers[index];
                final question = quiz.questions.firstWhere(
                  (q) => q.id == answer.questionId,
                  orElse: () => Question(
                    id: '',
                    questionText: 'Question not found',
                    type: QuestionType.multipleChoice,
                    options: [],
                    correctAnswers: [],
                    points: 0,
                  ),
                );

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Question ${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Icon(
                              answer.isCorrect ? Icons.check_circle : Icons.cancel,
                              color: answer.isCorrect ? Colors.green : Colors.red,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          question.questionText,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        if (question.type == QuestionType.multipleChoice)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your answer: ${answer.answers.isNotEmpty ? answer.answers[0] : "No answer"}',
                                style: TextStyle(
                                  color: answer.isCorrect ? Colors.green : Colors.red,
                                ),
                              ),
                              if (!answer.isCorrect)
                                Text(
                                  'Correct answer: ${question.correctAnswers.isNotEmpty ? question.correctAnswers[0] : "N/A"}',
                                  style: const TextStyle(color: Colors.green),
                                ),
                            ],
                          )
                        else if (question.type == QuestionType.shortEssay)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Your answer:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                answer.answers.isNotEmpty ? answer.answers[0] : 'No answer provided',
                                style: const TextStyle(fontStyle: FontStyle.italic),
                              ),
                              if (answer.aiGradingResult != null) ...[
                                const SizedBox(height: 16),
                                const Text(
                                  'AI Grading Results:',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                // Score breakdown
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Overall Score: ${(answer.aiGradingResult!.totalScore * 100).toStringAsFixed(1)}%',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              children: [
                                                Text('Keywords: ${(answer.aiGradingResult!.keywordScore * 100).toStringAsFixed(1)}%'),
                                                LinearProgressIndicator(
                                                  value: answer.aiGradingResult!.keywordScore,
                                                  backgroundColor: Colors.grey.shade300,
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              children: [
                                                Text('Length: ${(answer.aiGradingResult!.lengthScore * 100).toStringAsFixed(1)}%'),
                                                LinearProgressIndicator(
                                                  value: answer.aiGradingResult!.lengthScore,
                                                  backgroundColor: Colors.grey.shade300,
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              children: [
                                                Text('Coherence: ${(answer.aiGradingResult!.coherenceScore * 100).toStringAsFixed(1)}%'),
                                                LinearProgressIndicator(
                                                  value: answer.aiGradingResult!.coherenceScore,
                                                  backgroundColor: Colors.grey.shade300,
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Feedback
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'AI Feedback:',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(answer.aiGradingResult!.feedback),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Strengths
                                if (answer.aiGradingResult!.strengths.isNotEmpty) ...[
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Strengths:',
                                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                                        ),
                                        const SizedBox(height: 4),
                                        ...answer.aiGradingResult!.strengths.map((strength) => Padding(
                                          padding: const EdgeInsets.only(bottom: 4),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Icon(Icons.check_circle, size: 16, color: Colors.green),
                                              const SizedBox(width: 4),
                                              Expanded(child: Text(strength)),
                                            ],
                                          ),
                                        )),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                // Improvements
                                if (answer.aiGradingResult!.improvements.isNotEmpty) ...[
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Areas for Improvement:',
                                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                                        ),
                                        const SizedBox(height: 4),
                                        ...answer.aiGradingResult!.improvements.map((improvement) => Padding(
                                          padding: const EdgeInsets.only(bottom: 4),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Icon(Icons.lightbulb, size: 16, color: Colors.orange),
                                              const SizedBox(width: 4),
                                              Expanded(child: Text(improvement)),
                                            ],
                                          ),
                                        )),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ],
                          )
                        else if (question.type == QuestionType.matching)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Your matches:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              ...answer.answers.map((match) => Text(
                                match,
                                style: const TextStyle(fontStyle: FontStyle.italic),
                              )),
                            ],
                          ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Points: ${answer.pointsEarned}/${question.points}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: answer.pointsEarned == question.points ? Colors.green : Colors.red,
                              ),
                            ),
                            Text(
                              answer.isCorrect ? 'Correct' : 'Incorrect',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: answer.isCorrect ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Review Quiz'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: const Text('Back to Lessons'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}