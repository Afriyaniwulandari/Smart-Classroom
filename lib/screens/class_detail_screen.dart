import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/class_provider.dart';
import '../providers/live_class_provider.dart';
import '../models/class_model.dart';
import '../models/lesson.dart';
import '../models/live_class.dart';
import 'lesson_detail_screen.dart';
import 'create_lesson_screen.dart';
import 'live_class_screen.dart';

class ClassDetailScreen extends StatefulWidget {
  final ClassModel classModel;

  const ClassDetailScreen({super.key, required this.classModel});

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  @override
  void initState() {
    super.initState();
    final classProvider = Provider.of<ClassProvider>(context, listen: false);
    final liveClassProvider = Provider.of<LiveClassProvider>(context, listen: false);
    classProvider.loadLessons(widget.classModel.id);
    liveClassProvider.loadLiveClasses(widget.classModel.id);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final classProvider = Provider.of<ClassProvider>(context);
    final liveClassProvider = Provider.of<LiveClassProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.classModel.name),
        actions: [
          if (widget.classModel.teacherId == authProvider.user?.id)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CreateLessonScreen(classId: widget.classModel.id),
                  ),
                );
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
              widget.classModel.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text('Teacher: ${widget.classModel.teacherName}'),
            const SizedBox(height: 8),
            Text('Enrolled Students: ${widget.classModel.enrolledStudents.length}'),
            const SizedBox(height: 16),
            const Text(
              'Competencies:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8.0,
              children: widget.classModel.competencies
                  .map((competency) => Chip(label: Text(competency)))
                  .toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Live Classes:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            liveClassProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : liveClassProvider.liveClasses.isEmpty
                    ? const Text('No live classes scheduled')
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: liveClassProvider.liveClasses.length,
                        itemBuilder: (context, index) {
                          final LiveClass liveClass = liveClassProvider.liveClasses[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(liveClass.title),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(liveClass.description),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Scheduled: ${liveClass.scheduledDate.toString().split('.')[0]}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    'Status: ${liveClass.isActive ? 'Live' : 'Scheduled'}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: liveClass.isActive ? Colors.green : Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: liveClass.isActive
                                  ? const Icon(Icons.videocam, color: Colors.red)
                                  : const Icon(Icons.schedule),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => LiveClassScreen(liveClass: liveClass),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
            const SizedBox(height: 24),
            const Text(
              'Lessons:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            classProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : classProvider.lessons.isEmpty
                    ? const Text('No lessons available')
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: classProvider.lessons.length,
                        itemBuilder: (context, index) {
                          final Lesson lesson = classProvider.lessons[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(lesson.title),
                              subtitle: Text(lesson.description),
                              trailing: lesson.isCompleted
                                  ? const Icon(Icons.check_circle, color: Colors.green)
                                  : const Icon(Icons.play_circle_outline),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => LessonDetailScreen(lesson: lesson),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }
}