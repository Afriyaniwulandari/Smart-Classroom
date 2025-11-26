enum AttendanceType {
  automatic,
  manual,
}

class Attendance {
  final String id;
  final String studentId;
  final String studentName;
  final String classId;
  final String className;
  final AttendanceType type;
  final DateTime timestamp;
  final String? notes;
  final bool isPresent;

  Attendance({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.classId,
    required this.className,
    required this.type,
    required this.timestamp,
    this.notes,
    this.isPresent = true,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      studentId: json['studentId'],
      studentName: json['studentName'],
      classId: json['classId'],
      className: json['className'],
      type: AttendanceType.values[json['type']],
      timestamp: DateTime.parse(json['timestamp']),
      notes: json['notes'],
      isPresent: json['isPresent'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'classId': classId,
      'className': className,
      'type': type.index,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
      'isPresent': isPresent,
    };
  }

  Attendance copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? classId,
    String? className,
    AttendanceType? type,
    DateTime? timestamp,
    String? notes,
    bool? isPresent,
  }) {
    return Attendance(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      classId: classId ?? this.classId,
      className: className ?? this.className,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
      isPresent: isPresent ?? this.isPresent,
    );
  }

  // Helper methods
  bool get isLate => timestamp.hour > 9; // Assuming 9 AM start time
  String get formattedTime => '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  String get formattedDate => '${timestamp.day}/${timestamp.month}/${timestamp.year}';
}