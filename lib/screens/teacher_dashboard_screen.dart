import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/auth_provider.dart';
import '../providers/class_provider.dart';
import '../providers/attendance_provider.dart';
import '../providers/quiz_provider.dart';
import '../providers/notification_provider.dart';
import '../services/analytics_service.dart';
import 'create_class_screen.dart';
import 'classes_screen.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  late AnalyticsService _analyticsService;
  Map<String, dynamic> _overviewStats = {};
  List<Map<String, dynamic>> _attendanceTrends = [];
  Map<String, int> _gradeDistribution = {};
  Map<String, dynamic> _engagementMetrics = {};
  List<Map<String, dynamic>> _studentPerformanceData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final classProvider = Provider.of<ClassProvider>(context, listen: false);
    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);

    _analyticsService = AnalyticsService(classProvider, attendanceProvider, quizProvider);

    final teacherId = authProvider.user?.id ?? '';

    // Load classes first
    await classProvider.loadClasses(teacherId, 'teacher');

    // Load analytics data
    _overviewStats = await _analyticsService.getOverviewStats(teacherId);
    _attendanceTrends = await _analyticsService.getAttendanceTrends(teacherId, 7);
    _gradeDistribution = await _analyticsService.getGradeDistribution(teacherId);
    _engagementMetrics = await _analyticsService.getEngagementMetrics(teacherId);
    _studentPerformanceData = await _analyticsService.getStudentPerformanceData(teacherId);

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Cards
            _buildOverviewCards(),

            const SizedBox(height: 32),

            // Charts Section
            const Text(
              'Analytics',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Attendance Trends Chart
            _buildAttendanceTrendsChart(),

            const SizedBox(height: 32),

            // Grade Distribution Chart
            _buildGradeDistributionChart(),

            const SizedBox(height: 32),

            // Engagement Metrics
            _buildEngagementMetrics(),

            const SizedBox(height: 32),

            // Student Performance Table
            _buildStudentPerformanceTable(),

            const SizedBox(height: 32),

            // Quick Actions
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildOverviewCard(
          'Total Students',
          _overviewStats['totalStudents'].toString(),
          Icons.people,
          Colors.blue,
        ),
        _buildOverviewCard(
          'Total Classes',
          _overviewStats['totalClasses'].toString(),
          Icons.class_,
          Colors.green,
        ),
        _buildOverviewCard(
          'Avg Attendance',
          '${_overviewStats['averageAttendanceRate'].toStringAsFixed(1)}%',
          Icons.check_circle,
          Colors.orange,
        ),
        _buildOverviewCard(
          'Avg Grade',
          '${_overviewStats['averageGrade'].toStringAsFixed(1)}%',
          Icons.grade,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildOverviewCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
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

  Widget _buildAttendanceTrendsChart() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Attendance Trends (Last 7 Days)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text('${value.toInt()}%'),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < _attendanceTrends.length) {
                            final date = _attendanceTrends[value.toInt()]['date'] as DateTime;
                            return Text('${date.month}/${date.day}');
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _attendanceTrends.asMap().entries.map((entry) {
                        final rate = entry.value['attendanceRate'] as double;
                        return FlSpot(entry.key.toDouble(), rate);
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeDistributionChart() {
    final grades = ['A', 'B', 'C', 'D', 'F'];
    final colors = [Colors.green, Colors.blue, Colors.yellow, Colors.orange, Colors.red];

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Grade Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _gradeDistribution.values.isNotEmpty
                      ? _gradeDistribution.values.reduce((a, b) => a > b ? a : b).toDouble() + 5
                      : 10,
                  barGroups: grades.asMap().entries.map((entry) {
                    final grade = entry.value;
                    final count = _gradeDistribution[grade] ?? 0;
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: count.toDouble(),
                          color: colors[entry.key],
                          width: 20,
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(value.toInt().toString()),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < grades.length) {
                            return Text(grades[value.toInt()]);
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngagementMetrics() {
    final quizCompletionRate = _engagementMetrics['quizCompletionRate'] as double? ?? 0.0;
    final averageQuizzesPerStudent = _engagementMetrics['averageQuizzesPerStudent'] as double? ?? 0.0;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Engagement Metrics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    'Quiz Completion Rate',
                    '${(quizCompletionRate * 100).toStringAsFixed(1)}%',
                    Icons.assignment_turned_in,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricItem(
                    'Avg Quizzes/Student',
                    averageQuizzesPerStudent.toStringAsFixed(1),
                    Icons.trending_up,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
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
    );
  }

  Widget _buildStudentPerformanceTable() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Student Performance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Student')),
                  DataColumn(label: Text('Class')),
                  DataColumn(label: Text('Attendance %')),
                  DataColumn(label: Text('Avg Grade %')),
                  DataColumn(label: Text('Quizzes')),
                ],
                rows: _studentPerformanceData.map((student) {
                  return DataRow(cells: [
                    DataCell(Text(student['studentName'] ?? 'Unknown')),
                    DataCell(Text(student['className'] ?? '')),
                    DataCell(Text('${(student['attendanceRate'] as double).toStringAsFixed(1)}%')),
                    DataCell(Text('${(student['averageGrade'] as double).toStringAsFixed(1)}%')),
                    DataCell(Text(student['quizzesCompleted'].toString())),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildQuickActionButton(
                  'Create Class',
                  Icons.add_box,
                  Colors.blue,
                  () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CreateClassScreen()),
                  ),
                ),
                _buildQuickActionButton(
                  'Create Lesson',
                  Icons.library_books,
                  Colors.green,
                  () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ClassesScreen()),
                  ),
                ),
                _buildQuickActionButton(
                  'Create Quiz',
                  Icons.quiz,
                  Colors.orange,
                  () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ClassesScreen()),
                  ),
                ),
                _buildQuickActionButton(
                  'Send Announcement',
                  Icons.announcement,
                  Colors.purple,
                  _showAnnouncementDialog,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(String title, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  void _showAnnouncementDialog() {
    final titleController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Announcement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(labelText: 'Message'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);

              final title = titleController.text.trim();
              final message = messageController.text.trim();

              if (title.isNotEmpty && message.isNotEmpty) {
                await notificationProvider.createAnnouncement(
                  userId: authProvider.user?.id ?? '',
                  title: title,
                  message: message,
                );

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Announcement sent successfully')),
                );
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}