class ChatMessage {
  final String id;
  final String liveClassId;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isQuestion;

  ChatMessage({
    required this.id,
    required this.liveClassId,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    this.isQuestion = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      liveClassId: json['liveClassId'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      isQuestion: json['isQuestion'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'liveClassId': liveClassId,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isQuestion': isQuestion,
    };
  }
}