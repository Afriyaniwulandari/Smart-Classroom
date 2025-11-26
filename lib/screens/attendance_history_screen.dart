import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';
import '../providers/auth_provider.dart';
import '../models/attendance.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  @override
  void initState() {
    super.initState();

    // Load student attendance data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);

      if (authProvider.user != null) {
        attendanceProvider.loadStudentAttendance(authProvider.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = Provider.of<AttendanceProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Attendance History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (authProvider.user != null) {
                attendanceProvider.loadStudentAttendance(authProvider.user!.id);
              }
            },
          ),
        ],
      ),
      body: attendanceProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildAttendanceHistory(attendanceProvider),
    );
  }

  Widget _buildAttendanceHistory(AttendanceProvider attendanceProvider) {
    final attendance = attendanceProvider.studentAttendance;

    if (attendance.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No attendance records found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Your attendance will appear here once recorded',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Sort by date (most recent first)
    final sortedAttendance = List<Attendance>.from(attendance)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Group by class
    final groupedByClass = <String, List<Attendance>>{};
    for (final record in sortedAttendance) {
      if (groupedByClass[record.className] == null) {
        groupedByClass[record.className] = [];
      }
      groupedByClass[record.className]!.add(record);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall statistics
          _buildOverallStats(attendanceProvider, attendance),
          const SizedBox(height: 24),

          // Attendance by class
          const Text(
            'Attendance by Class',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ...groupedByClass.entries.map((entry) {
            final className = entry.key;
            final classAttendance = entry.value;
            final presentCount = classAttendance.where((a) => a.isPresent).length;
            final percentage = classAttendance.isEmpty ? 0.0 : (presentCount / classAttendance.length) * 100;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ExpansionTile(
                title: Text(
                  className,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '$presentCount/${classAttendance.length} sessions (${percentage.toStringAsFixed(1)}%)',
                ),
                leading: CircularProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    percentage >= 75 ? Colors.green : percentage >= 50 ? Colors.orange : Colors.red,
                  ),
                ),
                children: classAttendance.map((record) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: record.isPresent ? Colors.green : Colors.red,
                      child: Icon(
                        record.isPresent ? Icons.check : Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(record.formattedDate),
                    subtitle: Text('${record.type.name} • ${record.formattedTime}'),
                    trailing: record.isLate
                        ? const Chip(
                            label: Text('Late'),
                            backgroundColor: Colors.orange,
                            labelStyle: TextStyle(color: Colors.white, fontSize: 12),
                          )
                        : record.notes != null
                            ? Tooltip(
                                message: record.notes!,
                                child: const Icon(Icons.info_outline),
                              )
                            : null,
                  );
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOverallStats(AttendanceProvider attendanceProvider, List<Attendance> attendance) {
    final totalSessions = attendance.length;
    final presentCount = attendance.where((a) => a.isPresent).length;
    final absentCount = totalSessions - presentCount;
    final lateCount = attendance.where((a) => a.isLate).length;
    final overallPercentage = totalSessions == 0 ? 0.0 : (presentCount / totalSessions) * 100;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overall Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Sessions',
                    totalSessions.toString(),
                    Icons.calendar_today,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Present',
                    presentCount.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Absent',
                    absentCount.toString(),
                    Icons.cancel,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Late',
                    lateCount.toString(),
                    Icons.schedule,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${overallPercentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: overallPercentage >= 75
                              ? Colors.green
                              : overallPercentage >= 50
                                  ? Colors.orange
                                  : Colors.red,
                        ),
                      ),
                      const Text(
                        'Overall Rate',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const Expanded(child: SizedBox()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}