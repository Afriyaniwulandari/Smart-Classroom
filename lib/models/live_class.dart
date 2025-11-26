class LiveClass {
  final String id;
  final String lessonId;
  final String title;
  final String description;
  final DateTime scheduledDate;
  final int durationMinutes;
  final bool isActive;
  final List<String> participants;
  final Map<String, DateTime> attendance;
  final List<String> raisedHands;
  final String? currentPollId;
  final DateTime createdAt;

  LiveClass({
    required this.id,
    required this.lessonId,
    required this.title,
    required this.description,
    required this.scheduledDate,
    required this.durationMinutes,
    this.isActive = false,
    this.participants = const [],
    this.attendance = const {},
    this.raisedHands = const [],
    this.currentPollId,
    required this.createdAt,
  });

  factory LiveClass.fromJson(Map<String, dynamic> json) {
    return LiveClass(
      id: json['id'],
      lessonId: json['lessonId'],
      title: json['title'],
      description: json['description'],
      scheduledDate: DateTime.parse(json['scheduledDate']),
      durationMinutes: json['durationMinutes'],
      isActive: json['isActive'] ?? false,
      participants: List<String>.from(json['participants'] ?? []),
      attendance: Map<String, DateTime>.from(
        (json['attendance'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, DateTime.parse(value)),
        ) ?? {},
      ),
      raisedHands: List<String>.from(json['raisedHands'] ?? []),
      currentPollId: json['currentPollId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lessonId': lessonId,
      'title': title,
      'description': description,
      'scheduledDate': scheduledDate.toIso8601String(),
      'durationMinutes': durationMinutes,
      'isActive': isActive,
      'participants': participants,
      'attendance': attendance.map((key, value) => MapEntry(key, value.toIso8601String())),
      'raisedHands': raisedHands,
      'currentPollId': currentPollId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}