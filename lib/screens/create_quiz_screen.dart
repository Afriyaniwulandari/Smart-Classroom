import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../models/quiz.dart';
import '../services/ai_grading_service.dart';

class CreateQuizScreen extends StatefulWidget {
  final String lessonId;
  final Quiz? quiz; // For editing existing quiz

  const CreateQuizScreen({super.key, required this.lessonId, this.quiz});

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _timeLimitController = TextEditingController();
  final List<Question> _questions = [];

  @override
  void initState() {
    super.initState();
    if (widget.quiz != null) {
      _titleController.text = widget.quiz!.title;
      _descriptionController.text = widget.quiz!.description;
      _timeLimitController.text = widget.quiz!.timeLimitMinutes.toString();
      _questions.addAll(widget.quiz!.questions);
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz != null ? 'Edit Quiz' : 'Create Quiz'),
        actions: [
          if (_questions.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addQuestion,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Quiz Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quiz title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _timeLimitController,
                decoration: const InputDecoration(
                  labelText: 'Time Limit (minutes, 0 for no limit)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter time limit';
                  }
                  final timeLimit = int.tryParse(value);
                  if (timeLimit == null || timeLimit < 0) {
                    return 'Please enter valid time limit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Questions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (_questions.isEmpty)
                Center(
                  child: Column(
                    children: [
                      const Text('No questions added yet'),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _addQuestion,
                        icon: const Icon(Icons.add),
                        label: const Text('Add First Question'),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    final question = _questions[index];
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
                                    'Question ${index + 1}: ${question.questionText}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editQuestion(index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteQuestion(index),
                                ),
                              ],
                            ),
                            Text('Type: ${_getQuestionTypeText(question.type)}'),
                            Text('Points: ${question.points}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 24),
              if (_questions.isNotEmpty)
                ElevatedButton(
                  onPressed: quizProvider.isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            if (_questions.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please add at least one question')),
                              );
                              return;
                            }

                            final quiz = Quiz(
                              id: widget.quiz?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                              lessonId: widget.lessonId,
                              title: _titleController.text,
                              description: _descriptionController.text,
                              questions: _questions,
                              timeLimitMinutes: int.parse(_timeLimitController.text),
                              createdAt: widget.quiz?.createdAt ?? DateTime.now(),
                              createdBy: widget.quiz?.createdBy ?? user!.id,
                            );

                            final success = widget.quiz != null
                                ? await quizProvider.updateQuiz(quiz)
                                : await quizProvider.createQuiz(quiz);

                            if (success && mounted) {
                              // Create notification for new quiz
                              if (widget.quiz == null) { // Only for new quizzes
                                final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
                                await notificationProvider.createAnnouncement(
                                  userId: user!.id, // This should be student IDs, but for now using teacher ID
                                  title: 'New Quiz Available',
                                  message: 'A new quiz "${quiz.title}" has been added to your lesson.',
                                  classId: widget.lessonId,
                                );
                              }

                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Quiz ${widget.quiz != null ? 'updated' : 'created'} successfully')),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Failed to save quiz')),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: quizProvider.isLoading
                      ? const CircularProgressIndicator()
                      : Text(widget.quiz != null ? 'Update Quiz' : 'Create Quiz'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _addQuestion() {
    _showQuestionDialog();
  }

  void _editQuestion(int index) {
    _showQuestionDialog(question: _questions[index], index: index);
  }

  void _deleteQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  void _showQuestionDialog({Question? question, int? index}) {
    final isEditing = question != null;
    final questionController = TextEditingController(text: question?.questionText ?? '');
    final pointsController = TextEditingController(text: question?.points.toString() ?? '1');
    QuestionType selectedType = question?.type ?? QuestionType.multipleChoice;
    final List<String> options = question != null ? List.from(question.options) : [];
    final List<String> correctAnswers = question != null ? List.from(question.correctAnswers) : [];
    final hintController = TextEditingController(text: question?.hint ?? '');

    // Grading criteria for essays
    final keywordWeightController = TextEditingController(text: question?.gradingCriteria?.keywordWeight.toString() ?? '0.5');
    final lengthWeightController = TextEditingController(text: question?.gradingCriteria?.lengthWeight.toString() ?? '0.2');
    final coherenceWeightController = TextEditingController(text: question?.gradingCriteria?.coherenceWeight.toString() ?? '0.3');
    final minLengthController = TextEditingController(text: question?.gradingCriteria?.minLength.toString() ?? '50');
    final maxLengthController = TextEditingController(text: question?.gradingCriteria?.maxLength.toString() ?? '500');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? 'Edit Question' : 'Add Question'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: questionController,
                  decoration: const InputDecoration(labelText: 'Question Text'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<QuestionType>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Question Type'),
                  items: QuestionType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getQuestionTypeText(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                      if (selectedType == QuestionType.multipleChoice && correctAnswers.length > 1) {
                        correctAnswers.clear();
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                if (selectedType == QuestionType.multipleChoice || selectedType == QuestionType.matching)
                  Column(
                    children: [
                      const Text('Options:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ...List.generate(options.length + 1, (i) {
                        if (i == options.length) {
                          return TextButton.icon(
                            onPressed: () {
                              setState(() {
                                options.add('');
                              });
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Option'),
                          );
                        }
                        return Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: TextEditingController(text: options[i]),
                                decoration: InputDecoration(labelText: 'Option ${i + 1}'),
                                onChanged: (value) {
                                  options[i] = value;
                                },
                              ),
                            ),
                            if (selectedType == QuestionType.multipleChoice)
                              Checkbox(
                                value: correctAnswers.contains(options[i]),
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      correctAnswers.clear();
                                      correctAnswers.add(options[i]);
                                    } else {
                                      correctAnswers.remove(options[i]);
                                    }
                                  });
                                },
                              )
                            else
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    options.removeAt(i);
                                    correctAnswers.remove(options[i]);
                                  });
                                },
                              ),
                          ],
                        );
                      }),
                      if (selectedType == QuestionType.matching)
                        Column(
                          children: [
                            const SizedBox(height: 16),
                            const Text('Correct Matches (format: "term-definition"):',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            ...List.generate(correctAnswers.length + 1, (i) {
                              if (i == correctAnswers.length) {
                                return TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      correctAnswers.add('');
                                    });
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Match'),
                                );
                              }
                              return TextField(
                                controller: TextEditingController(text: correctAnswers[i]),
                                decoration: InputDecoration(labelText: 'Match ${i + 1}'),
                                onChanged: (value) {
                                  correctAnswers[i] = value;
                                },
                              );
                            }),
                          ],
                        ),
                    ],
                  ),
                if (selectedType == QuestionType.shortEssay)
                  Column(
                    children: [
                      const Text('Correct Keywords (comma-separated):',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextField(
                        controller: TextEditingController(text: correctAnswers.join(', ')),
                        decoration: const InputDecoration(labelText: 'Keywords'),
                        onChanged: (value) {
                          correctAnswers.clear();
                          correctAnswers.addAll(value.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty));
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: hintController,
                        decoration: const InputDecoration(labelText: 'AI Hint (optional)'),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 24),
                      const Text('AI Grading Criteria:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 16),
                      const Text('Grading Weights (must sum to 1.0):', style: TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: keywordWeightController,
                              decoration: const InputDecoration(labelText: 'Keywords'),
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: lengthWeightController,
                              decoration: const InputDecoration(labelText: 'Length'),
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: coherenceWeightController,
                              decoration: const InputDecoration(labelText: 'Coherence'),
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Length Requirements:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: minLengthController,
                              decoration: const InputDecoration(labelText: 'Min Length'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: maxLengthController,
                              decoration: const InputDecoration(labelText: 'Max Length'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                TextField(
                  controller: pointsController,
                  decoration: const InputDecoration(labelText: 'Points'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (questionController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter question text')),
                  );
                  return;
                }

                EssayGradingCriteria? gradingCriteria;
                if (selectedType == QuestionType.shortEssay) {
                  gradingCriteria = EssayGradingCriteria(
                    keywordWeight: double.tryParse(keywordWeightController.text) ?? 0.5,
                    lengthWeight: double.tryParse(lengthWeightController.text) ?? 0.2,
                    coherenceWeight: double.tryParse(coherenceWeightController.text) ?? 0.3,
                    minLength: int.tryParse(minLengthController.text) ?? 50,
                    maxLength: int.tryParse(maxLengthController.text) ?? 500,
                    keywords: correctAnswers,
                  );
                }

                final newQuestion = Question(
                  id: question?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  questionText: questionController.text,
                  type: selectedType,
                  options: options,
                  correctAnswers: correctAnswers,
                  points: int.tryParse(pointsController.text) ?? 1,
                  hint: hintController.text.isEmpty ? null : hintController.text,
                  gradingCriteria: gradingCriteria,
                );

                setState(() {
                  if (isEditing && index != null) {
                    _questions[index] = newQuestion;
                  } else {
                    _questions.add(newQuestion);
                  }
                });

                Navigator.of(context).pop();
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  String _getQuestionTypeText(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return 'Multiple Choice';
      case QuestionType.matching:
        return 'Matching';
      case QuestionType.shortEssay:
        return 'Short Essay';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _timeLimitController.dispose();
    super.dispose();
  }
}