import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/class_provider.dart';
import '../models/class_model.dart';

class CreateClassScreen extends StatefulWidget {
  const CreateClassScreen({super.key});

  @override
  State<CreateClassScreen> createState() => _CreateClassScreenState();
}

class _CreateClassScreenState extends State<CreateClassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<String> _competencies = [];
  final _competencyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final classProvider = Provider.of<ClassProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Class'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Class Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter class name';
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
              const Text('Competencies', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _competencyController,
                      decoration: const InputDecoration(
                        labelText: 'Add competency',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_competencyController.text.isNotEmpty) {
                        setState(() {
                          _competencies.add(_competencyController.text);
                          _competencyController.clear();
                        });
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                children: _competencies
                    .map((competency) => Chip(
                          label: Text(competency),
                          onDeleted: () {
                            setState(() {
                              _competencies.remove(competency);
                            });
                          },
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: classProvider.isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate() && user != null) {
                          final classModel = ClassModel(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            name: _nameController.text,
                            description: _descriptionController.text,
                            teacherId: user.id,
                            teacherName: user.name,
                            competencies: _competencies,
                            enrolledStudents: [],
                            createdAt: DateTime.now(),
                          );

                          final success = await classProvider.createClass(classModel);
                          if (success && mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Class created successfully')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Failed to create class')),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: classProvider.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Create Class'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _competencyController.dispose();
    super.dispose();
  }
}