import '../models/attendance.dart';

class AttendanceService {
  static const String baseUrl = 'https://api.smartclassroom.com'; // Replace with actual API URL

  // Mock data for development
  final Map<String, List<Map<String, dynamic>>> _mockAttendance = {
    'class1': [
      {
        'id': '1',
        'studentId': '1',
        'studentName': 'John Student',
        'classId': 'class1',
        'className': 'Mathematics 101',
        'type': 0, // automatic
        'timestamp': '2024-11-25T08:30:00.000Z',
        'notes': null,
        'isPresent': true,
      },
      {
        'id': '2',
        'studentId': '1',
        'studentName': 'John Student',
        'classId': 'class1',
        'className': 'Mathematics 101',
        'type': 0, // automatic
        'timestamp': '2024-11-24T08:25:00.000Z',
        'notes': null,
        'isPresent': true,
      },
    ],
    'class2': [
      {
        'id': '3',
        'studentId': '1',
        'studentName': 'John Student',
        'classId': 'class2',
        'className': 'Physics 101',
        'type': 1, // manual
        'timestamp': '2024-11-25T09:15:00.000Z',
        'notes': 'Late arrival',
        'isPresent': true,
      },
    ],
  };

  Future<List<Attendance>> getAttendanceForClass(String classId) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock data
    final attendanceData = _mockAttendance[classId] ?? [];
    return attendanceData.map((data) => Attendance.fromJson(data)).toList();

    // Uncomment below for real API call
    /*
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/attendance/class/$classId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((item) => Attendance.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
    */
  }

  Future<List<Attendance>> getAttendanceForStudent(String studentId) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock data - collect all attendance for this student
    final allAttendance = <Attendance>[];
    for (final classAttendance in _mockAttendance.values) {
      allAttendance.addAll(
        classAttendance
            .where((data) => data['studentId'] == studentId)
            .map((data) => Attendance.fromJson(data))
      );
    }
    return allAttendance;

    // Uncomment below for real API call
    /*
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/attendance/student/$studentId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((item) => Attendance.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
    */
  }

  Future<bool> markAttendance(String studentId, String studentName, String classId, String className, AttendanceType type, {String? notes}) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock attendance marking
    final newAttendance = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'studentId': studentId,
      'studentName': studentName,
      'classId': classId,
      'className': className,
      'type': type.index,
      'timestamp': DateTime.now().toIso8601String(),
      'notes': notes,
      'isPresent': true,
    };

    if (_mockAttendance.containsKey(classId)) {
      _mockAttendance[classId]!.add(newAttendance);
    } else {
      _mockAttendance[classId] = [newAttendance];
    }

    return true;

    // Uncomment below for real API call
    /*
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/attendance'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'studentId': studentId,
          'studentName': studentName,
          'classId': classId,
          'className': className,
          'type': type.index,
          'timestamp': DateTime.now().toIso8601String(),
          'notes': notes,
          'isPresent': true,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
    */
  }

  Future<bool> markBulkAttendance(String classId, String className, List<Map<String, dynamic>> attendanceData) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock bulk attendance marking
    for (final data in attendanceData) {
      final newAttendance = {
        'id': DateTime.now().millisecondsSinceEpoch.toString() + data['studentId'],
        'studentId': data['studentId'],
        'studentName': data['studentName'],
        'classId': classId,
        'className': className,
        'type': 1, // manual
        'timestamp': DateTime.now().toIso8601String(),
        'notes': data['notes'],
        'isPresent': data['isPresent'] ?? true,
      };

      if (_mockAttendance.containsKey(classId)) {
        _mockAttendance[classId]!.add(newAttendance);
      } else {
        _mockAttendance[classId] = [newAttendance];
      }
    }

    return true;

    // Uncomment below for real API call
    /*
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/attendance/bulk'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'classId': classId,
          'className': className,
          'attendance': attendanceData,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
    */
  }

  Future<Map<String, dynamic>> getAttendanceStatistics(String classId) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock statistics
    final attendance = _mockAttendance[classId] ?? [];
    final totalStudents = 25; // Mock total students
    final presentToday = attendance.where((a) {
      final attendanceDate = DateTime.parse(a['timestamp']);
      final today = DateTime.now();
      return attendanceDate.year == today.year &&
             attendanceDate.month == today.month &&
             attendanceDate.day == today.day;
    }).length;

    final totalSessions = 10; // Mock total sessions
    final averageAttendance = (attendance.length / totalSessions) * 100;

    return {
      'totalStudents': totalStudents,
      'presentToday': presentToday,
      'absentToday': totalStudents - presentToday,
      'averageAttendance': averageAttendance,
      'totalSessions': totalSessions,
    };

    // Uncomment below for real API call
    /*
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/attendance/statistics/$classId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {};
      }
    } catch (e) {
      return {};
    }
    */
  }

  Future<String> generateAttendanceCode(String classId) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // Generate a code in format: CLASSID_CLASSNAME_CODE
    // For demo, using mock class name
    final className = classId == 'class1' ? 'Mathematics_101' : 'Physics_101';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final shortCode = timestamp.toString().substring(timestamp.toString().length - 6);
    final code = '${classId}_${className}_${shortCode}';

    return code;

    // Uncomment below for real API call
    /*
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/attendance/generate-code'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'classId': classId}),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['code'];
      } else {
        return '';
      }
    } catch (e) {
      return '';
    }
    */
  }

  Future<bool> verifyAttendanceCode(String code, String studentId, String studentName, String classId, String className) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock verification - accept any code for now
    return await markAttendance(studentId, studentName, classId, className, AttendanceType.manual, notes: 'QR Code: $code');

    // Uncomment below for real API call
    /*
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/attendance/verify-code'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'code': code,
          'studentId': studentId,
          'studentName': studentName,
          'classId': classId,
          'className': className,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
    */
  }
}