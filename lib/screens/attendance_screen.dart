import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/attendance_provider.dart';
import '../providers/auth_provider.dart';
import '../models/attendance.dart';

class AttendanceScreen extends StatefulWidget {
  final String classId;
  final String className;

  const AttendanceScreen({super.key, required this.classId, required this.className});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
      attendanceProvider.loadClassAttendance(widget.classId);
      attendanceProvider.loadAttendanceStatistics(widget.classId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = Provider.of<AttendanceProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.className} - Attendance'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Records', icon: Icon(Icons.list)),
            Tab(text: 'QR Code', icon: Icon(Icons.qr_code)),
            Tab(text: 'Statistics', icon: Icon(Icons.bar_chart)),
          ],
        ),
        actions: [
          if (authProvider.isTeacher)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                attendanceProvider.loadClassAttendance(widget.classId);
                attendanceProvider.loadAttendanceStatistics(widget.classId);
              },
            ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAttendanceRecordsTab(attendanceProvider),
          _buildQRCodeTab(attendanceProvider),
          _buildStatisticsTab(attendanceProvider),
        ],
      ),
    );
  }

  Widget _buildAttendanceRecordsTab(AttendanceProvider attendanceProvider) {
    if (attendanceProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final attendance = attendanceProvider.classAttendance;

    if (attendance.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No attendance records found', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }

    // Group attendance by date
    final groupedAttendance = <DateTime, List<Attendance>>{};
    for (final record in attendance) {
      final date = DateTime(record.timestamp.year, record.timestamp.month, record.timestamp.day);
      if (groupedAttendance[date] == null) {
        groupedAttendance[date] = [];
      }
      groupedAttendance[date]!.add(record);
    }

    final sortedDates = groupedAttendance.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final dayAttendance = groupedAttendance[date]!;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            title: Text(
              '${date.day}/${date.month}/${date.year}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${dayAttendance.length} students'),
            children: dayAttendance.map((record) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: record.isPresent ? Colors.green : Colors.red,
                  child: Icon(
                    record.isPresent ? Icons.check : Icons.close,
                    color: Colors.white,
                  ),
                ),
                title: Text(record.studentName),
                subtitle: Text('${record.type.name} • ${record.formattedTime}'),
                trailing: record.isLate
                    ? const Chip(
                        label: Text('Late'),
                        backgroundColor: Colors.orange,
                      )
                    : null,
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildQRCodeTab(AttendanceProvider attendanceProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Generate QR Code for Manual Attendance',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Students can scan this QR code to mark their attendance manually.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          if (attendanceProvider.currentAttendanceCode != null)
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: attendanceProvider.currentAttendanceCode!,
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Code: ${attendanceProvider.currentAttendanceCode}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This code expires in 5 minutes',
                  style: TextStyle(color: Colors.orange),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    attendanceProvider.clearCurrentCode();
                  },
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear Code'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            )
          else
            ElevatedButton.icon(
              onPressed: attendanceProvider.isLoading
                  ? null
                  : () async {
                      final success = await attendanceProvider.generateAttendanceCode(widget.classId);
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('QR Code generated successfully')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to generate QR Code')),
                        );
                      }
                    },
              icon: const Icon(Icons.qr_code),
              label: const Text('Generate QR Code'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab(AttendanceProvider attendanceProvider) {
    final stats = attendanceProvider.attendanceStatistics;

    if (attendanceProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attendance Statistics',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Students',
                  stats['totalStudents']?.toString() ?? '0',
                  Icons.people,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Present Today',
                  stats['presentToday']?.toString() ?? '0',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Absent Today',
                  stats['absentToday']?.toString() ?? '0',
                  Icons.cancel,
                  Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Avg Attendance',
                  '${stats['averageAttendance']?.toStringAsFixed(1) ?? '0'}%',
                  Icons.trending_up,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'Recent Attendance Trends',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Mock chart - in a real app, you'd use a charting library
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('Attendance Chart\n(Chart library integration needed)'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}