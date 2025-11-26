class Poll {
  final String id;
  final String liveClassId;
  final String question;
  final List<String> options;
  final Map<String, int> responses; // userId -> option index
  final bool isActive;
  final DateTime createdAt;
  final DateTime? endTime;

  Poll({
    required this.id,
    required this.liveClassId,
    required this.question,
    required this.options,
    this.responses = const {},
    this.isActive = true,
    required this.createdAt,
    this.endTime,
  });

  factory Poll.fromJson(Map<String, dynamic> json) {
    return Poll(
      id: json['id'],
      liveClassId: json['liveClassId'],
      question: json['question'],
      options: List<String>.from(json['options']),
      responses: Map<String, int>.from(json['responses'] ?? {}),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'liveClassId': liveClassId,
      'question': question,
      'options': options,
      'responses': responses,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
    };
  }

  // Helper method to get response counts
  Map<String, int> getResponseCounts() {
    final counts = <String, int>{};
    for (final option in options) {
      counts[option] = 0;
    }
    responses.forEach((userId, optionIndex) {
      if (optionIndex >= 0 && optionIndex < options.length) {
        counts[options[optionIndex]] = (counts[options[optionIndex]] ?? 0) + 1;
      }
    });
    return counts;
  }
}