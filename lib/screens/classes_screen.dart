import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/class_provider.dart';
import 'class_detail_screen.dart';
import 'create_class_screen.dart';

class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final classProvider = Provider.of<ClassProvider>(context, listen: false);
    final user = authProvider.user;
    if (user != null) {
      classProvider.loadClasses(user.id, user.role);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final classProvider = Provider.of<ClassProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Classes'),
        actions: [
          if (user?.role == 'teacher')
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CreateClassScreen()),
                );
              },
            ),
        ],
      ),
      body: classProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : classProvider.classes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No classes available'),
                      if (user?.role == 'student') const SizedBox(height: 16),
                      if (user?.role == 'student')
                        const Text('Enroll in classes to get started'),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: classProvider.classes.length,
                  itemBuilder: (context, index) {
                    final classItem = classProvider.classes[index];
                    final isEnrolled = user?.role == 'student'
                        ? classItem.enrolledStudents.contains(user!.id)
                        : true;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(classItem.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(classItem.description),
                            const SizedBox(height: 4),
                            Text('Teacher: ${classItem.teacherName}'),
                            Text('Enrolled: ${classItem.enrolledStudents.length} students'),
                          ],
                        ),
                        trailing: user?.role == 'student'
                            ? ElevatedButton(
                                onPressed: isEnrolled
                                    ? () => _unenrollFromClass(classItem.id)
                                    : () => _enrollInClass(classItem.id),
                                child: Text(isEnrolled ? 'Unenroll' : 'Enroll'),
                              )
                            : null,
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
    );
  }

  Future<void> _enrollInClass(String classId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final classProvider = Provider.of<ClassProvider>(context, listen: false);
    final user = authProvider.user;

    if (user != null) {
      final success = await classProvider.enrollInClass(classId, user.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enrolled successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to enroll')),
        );
      }
    }
  }

  Future<void> _unenrollFromClass(String classId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final classProvider = Provider.of<ClassProvider>(context, listen: false);
    final user = authProvider.user;

    if (user != null) {
      final success = await classProvider.unenrollFromClass(classId, user.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unenrolled successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to unenroll')),
        );
      }
    }
  }
}