class ClassModel {
  final String id;
  final String name;
  final String description;
  final String teacherId;
  final String teacherName;
  final List<String> competencies;
  final List<String> enrolledStudents;
  final DateTime createdAt;

  ClassModel({
    required this.id,
    required this.name,
    required this.description,
    required this.teacherId,
    required this.teacherName,
    required this.competencies,
    required this.enrolledStudents,
    required this.createdAt,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      teacherId: json['teacherId'],
      teacherName: json['teacherName'],
      competencies: List<String>.from(json['competencies'] ?? []),
      enrolledStudents: List<String>.from(json['enrolledStudents'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'competencies': competencies,
      'enrolledStudents': enrolledStudents,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}