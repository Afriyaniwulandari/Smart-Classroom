import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../providers/auth_provider.dart';
import '../models/quiz.dart';
import 'quiz_results_screen.dart';

class TakeQuizScreen extends StatefulWidget {
  final Quiz quiz;

  const TakeQuizScreen({super.key, required this.quiz});

  @override
  State<TakeQuizScreen> createState() => _TakeQuizScreenState();
}

class _TakeQuizScreenState extends State<TakeQuizScreen> {
  final Map<String, List<String>> _answers = {};
  Timer? _timer;
  int _remainingTime = 0;
  int _currentQuestionIndex = 0;
  bool _isSubmitting = false;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.quiz.timeLimitMinutes * 60; // Convert to seconds
    _startTime = DateTime.now();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    final user = authProvider.user;

    // Start the quiz
    quizProvider.startQuiz(widget.quiz.id, user!.id);

    if (widget.quiz.timeLimitMinutes > 0) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingTime--;
        if (_remainingTime <= 0) {
          _timer?.cancel();
          _submitQuiz();
        }
      });
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _submitQuiz() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    final user = authProvider.user;

    // Submit all answers
    for (final entry in _answers.entries) {
      await quizProvider.submitQuizAnswer(widget.quiz.id, user!.id, entry.key, entry.value);
    }

    // Calculate time taken
    final timeTaken = DateTime.now().difference(_startTime!).inMinutes;

    // Complete the quiz
    final result = await quizProvider.completeQuiz(widget.quiz.id, user!.id, timeTaken);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => QuizResultsScreen(quizResult: result!),
        ),
      );
    }
  }

  void _updateAnswer(String questionId, List<String> answers) {
    setState(() {
      _answers[questionId] = answers;
    });
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.quiz.questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.title),
        automaticallyImplyLeading: false,
        actions: [
          if (widget.quiz.timeLimitMinutes > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _remainingTime < 300 ? Colors.red : Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _formatTime(_remainingTime),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / widget.quiz.questions.length,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Question ${_currentQuestionIndex + 1} of ${widget.quiz.questions.length}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.questionText,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  _buildQuestionWidget(question),
                  if (question.hint != null && question.type == QuestionType.shortEssay)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Card(
                        color: Colors.blue.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '💡 AI Hint:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(question.hint!),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentQuestionIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _currentQuestionIndex--;
                        });
                      },
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentQuestionIndex > 0 && _currentQuestionIndex < widget.quiz.questions.length - 1)
                  const SizedBox(width: 16),
                if (_currentQuestionIndex < widget.quiz.questions.length - 1)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentQuestionIndex++;
                        });
                      },
                      child: const Text('Next'),
                    ),
                  )
                else
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitQuiz,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator()
                          : const Text('Submit Quiz'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionWidget(Question question) {
    final currentAnswers = _answers[question.id] ?? [];

    switch (question.type) {
      case QuestionType.multipleChoice:
        return Column(
          children: question.options.map((option) {
            return RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: currentAnswers.isNotEmpty ? currentAnswers[0] : null,
              onChanged: (value) {
                if (value != null) {
                  _updateAnswer(question.id, [value]);
                }
              },
            );
          }).toList(),
        );

      case QuestionType.matching:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Match the items by typing the correct pairs (format: "item1-item2"):',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: question.options.map((option) {
                return Chip(label: Text(option));
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Your matches (one per line)',
                border: OutlineInputBorder(),
                hintText: 'term1-definition1\nterm2-definition2',
              ),
              maxLines: question.options.length ~/ 2 + 1,
              onChanged: (value) {
                final matches = value.split('\n').where((s) => s.trim().isNotEmpty).toList();
                _updateAnswer(question.id, matches);
              },
            ),
          ],
        );

      case QuestionType.shortEssay:
        return TextField(
          decoration: const InputDecoration(
            labelText: 'Your answer',
            border: OutlineInputBorder(),
            hintText: 'Type your response here...',
          ),
          maxLines: 5,
          onChanged: (value) {
            _updateAnswer(question.id, [value]);
          },
        );
    }
  }
}