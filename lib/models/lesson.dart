enum MaterialType { text, pdf, image, video, audio }

class Material {
  final String id;
  final String title;
  final MaterialType type;
  final String url;
  final String? description;

  Material({
    required this.id,
    required this.title,
    required this.type,
    required this.url,
    this.description,
  });

  factory Material.fromJson(Map<String, dynamic> json) {
    return Material(
      id: json['id'],
      title: json['title'],
      type: MaterialType.values[json['type']],
      url: json['url'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.index,
      'url': url,
      'description': description,
    };
  }
}

class Lesson {
  final String id;
  final String classId;
  final String title;
  final String description;
  final List<Material> materials;
  final DateTime scheduledDate;
  final int durationMinutes;
  final bool isCompleted;
  final DateTime createdAt;

  Lesson({
    required this.id,
    required this.classId,
    required this.title,
    required this.description,
    required this.materials,
    required this.scheduledDate,
    required this.durationMinutes,
    this.isCompleted = false,
    required this.createdAt,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],
      classId: json['classId'],
      title: json['title'],
      description: json['description'],
      materials: (json['materials'] as List<dynamic>?)
          ?.map((m) => Material.fromJson(m))
          .toList() ?? [],
      scheduledDate: DateTime.parse(json['scheduledDate']),
      durationMinutes: json['durationMinutes'],
      isCompleted: json['isCompleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'classId': classId,
      'title': title,
      'description': description,
      'materials': materials.map((m) => m.toJson()).toList(),
      'scheduledDate': scheduledDate.toIso8601String(),
      'durationMinutes': durationMinutes,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}