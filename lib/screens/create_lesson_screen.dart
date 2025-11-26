import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/class_provider.dart';
import '../providers/live_class_provider.dart';
import '../providers/notification_provider.dart';
import '../models/lesson.dart';
import '../models/lesson.dart' as lesson_models;
import '../models/live_class.dart';

class CreateLessonScreen extends StatefulWidget {
  final String classId;

  const CreateLessonScreen({super.key, required this.classId});

  @override
  State<CreateLessonScreen> createState() => _CreateLessonScreenState();
}

class _CreateLessonScreenState extends State<CreateLessonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  final _liveClassTitleController = TextEditingController();
  final _liveClassDescriptionController = TextEditingController();
  DateTime _scheduledDate = DateTime.now();
  DateTime _liveClassScheduledDate = DateTime.now();
  final List<lesson_models.Material> _materials = [];
  bool _scheduleLiveClass = false;

  @override
  Widget build(BuildContext context) {
    final classProvider = Provider.of<ClassProvider>(context);
    final liveClassProvider = Provider.of<LiveClassProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Lesson'),
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
                  labelText: 'Lesson Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter lesson title';
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
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter duration';
                  }
                  final duration = int.tryParse(value);
                  if (duration == null || duration <= 0) {
                    return 'Please enter valid duration';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Scheduled Date'),
                subtitle: Text(_scheduledDate.toString().split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _scheduledDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() {
                      _scheduledDate = picked;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Schedule Live Class'),
                subtitle: const Text('Create an interactive live session for this lesson'),
                value: _scheduleLiveClass,
                onChanged: (value) {
                  setState(() {
                    _scheduleLiveClass = value ?? false;
                  });
                },
              ),
              if (_scheduleLiveClass) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _liveClassTitleController,
                  decoration: const InputDecoration(
                    labelText: 'Live Class Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_scheduleLiveClass && (value == null || value.isEmpty)) {
                      return 'Please enter live class title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _liveClassDescriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Live Class Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (_scheduleLiveClass && (value == null || value.isEmpty)) {
                      return 'Please enter live class description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Live Class Date & Time'),
                  subtitle: Text(_liveClassScheduledDate.toString()),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _liveClassScheduledDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (pickedDate != null) {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_liveClassScheduledDate),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          _liveClassScheduledDate = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                        });
                      }
                    }
                  },
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: (classProvider.isLoading || liveClassProvider.isLoading)
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          final lesson = Lesson(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            classId: widget.classId,
                            title: _titleController.text,
                            description: _descriptionController.text,
                            materials: _materials,
                            scheduledDate: _scheduledDate,
                            durationMinutes: int.parse(_durationController.text),
                            createdAt: DateTime.now(),
                          );

                          final lessonSuccess = await classProvider.createLesson(lesson);

                          bool liveClassSuccess = true;
                          if (_scheduleLiveClass && lessonSuccess) {
                            final liveClass = LiveClass(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              lessonId: lesson.id,
                              title: _liveClassTitleController.text,
                              description: _liveClassDescriptionController.text,
                              scheduledDate: _liveClassScheduledDate,
                              durationMinutes: int.parse(_durationController.text),
                              createdAt: DateTime.now(),
                            );
                            liveClassSuccess = await liveClassProvider.createLiveClass(liveClass);
                          }

                          if (lessonSuccess && liveClassSuccess && mounted) {
                            // Create notifications
                            final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);

                            // Create announcement for new lesson
                            await notificationProvider.createAnnouncement(
                              userId: 'all_students', // This should be actual student IDs
                              title: 'New Lesson Available',
                              message: 'A new lesson "${lesson.title}" has been scheduled for ${lesson.scheduledDate.toString().split(' ')[0]}.',
                              classId: widget.classId,
                            );

                            // Create live class reminder if scheduled
                            if (_scheduleLiveClass) {
                              final liveClass = LiveClass(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                lessonId: lesson.id,
                                title: _liveClassTitleController.text,
                                description: _liveClassDescriptionController.text,
                                scheduledDate: _liveClassScheduledDate,
                                durationMinutes: int.parse(_durationController.text),
                                createdAt: DateTime.now(),
                              );

                              await notificationProvider.createLiveClassReminder(
                                userId: 'all_students', // This should be actual student IDs
                                classTitle: liveClass.title,
                                classTime: liveClass.scheduledDate,
                                classId: liveClass.id,
                              );
                            }

                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(_scheduleLiveClass
                                  ? 'Lesson and live class created successfully'
                                  : 'Lesson created successfully')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Failed to create lesson')),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: classProvider.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Create Lesson'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _liveClassTitleController.dispose();
    _liveClassDescriptionController.dispose();
    super.dispose();
  }
}