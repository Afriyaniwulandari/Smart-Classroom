import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/auth_provider.dart';
import '../providers/quiz_provider.dart';
import '../providers/gamification_provider.dart';
import '../providers/career_recommendation_provider.dart';
import '../services/progress_service.dart';
import '../models/student_progress.dart';
import '../models/class_model.dart';
import '../models/quiz_result.dart';
import '../models/gamification.dart';
import 'leaderboard_screen.dart';
import 'career_recommendation_screen.dart';
import 'export_report_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  late ProgressService _progressService;
  StudentStats _stats = StudentStats.empty();
  List<StudySession> _studySessions = [];
  List<DailyTarget> _dailyTargets = [];
  List<Reminder> _upcomingReminders = [];
  List<ClassModel> _enrolledCourses = [];
  List<QuizResult> _quizResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    final gamificationProvider = Provider.of<GamificationProvider>(context, listen: false);

    _progressService = ProgressService();
    final studentId = authProvider.user?.id ?? '';

    // Load all data
    _studySessions = await _progressService.getStudySessions(studentId);
    _dailyTargets = await _progressService.getDailyTargets(studentId);
    _upcomingReminders = await _progressService.getUpcomingReminders(studentId);
    _enrolledCourses = await _progressService.getEnrolledCoursesHistory(studentId);

    // Load quiz results
    await quizProvider.loadQuizResults(studentId);
    _quizResults = quizProvider.quizResults;

    // Load gamification profile
    await gamificationProvider.loadGamificationProfile(studentId);

    // Calculate stats
    _stats = await _progressService.calculateStudentStats(
      studentId,
      _quizResults,
      _enrolledCourses,
      [], // attendance records - need to implement
      _studySessions,
    );

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
        title: const Text('Student Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
              );
            },
            tooltip: 'View Leaderboards',
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ExportReportScreen()),
              );
            },
            tooltip: 'Export Report',
          ),
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
            // Welcome and Gamification Section
            _buildWelcomeSection(),

            const SizedBox(height: 24),

            // Overview Stats Cards
            _buildOverviewCards(),

            const SizedBox(height: 32),

            // Performance Graphs
            const Text(
              'Performance Analytics',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Grade Trends Chart
            _buildGradeTrendsChart(),

            const SizedBox(height: 32),

            // Study Hours by Subject
            _buildStudyHoursChart(),

            const SizedBox(height: 32),

            // Daily Learning Targets
            _buildDailyTargetsSection(),

            const SizedBox(height: 32),

            // Streak Tracking
            _buildStreakSection(),

            const SizedBox(height: 32),

            // Enrolled Courses History
            _buildEnrolledCoursesSection(),

            const SizedBox(height: 32),

            // Upcoming Reminders
            _buildUpcomingRemindersSection(),

            const SizedBox(height: 32),

            // Recent Achievements
            _buildRecentAchievementsSection(),

            const SizedBox(height: 32),

            // Achievement Progress
            _buildAchievementProgressSection(),

            const SizedBox(height: 32),

            // Career Insights
            _buildCareerInsightsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final gamificationProvider = Provider.of<GamificationProvider>(context);
    final currentLevel = gamificationProvider.currentLevel;
    final totalXp = gamificationProvider.totalXp;
    final levelProgress = gamificationProvider.levelProgress;
    final currentLevelInfo = gamificationProvider.currentLevelInfo;
    final nextLevelInfo = gamificationProvider.nextLevelInfo;

    return Card(
      elevation: 4,
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.school, size: 48, color: Colors.blue),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, ${Provider.of<AuthProvider>(context).user?.name ?? 'Student'}!',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'XP: $totalXp | Current Streak: ${_stats.currentStreak} days',
                        style: const TextStyle(color: Colors.blue),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Level $currentLevel: ${currentLevelInfo?.title ?? 'Unknown'}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Level $currentLevel',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Level Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Level Progress',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      '${(levelProgress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: levelProgress,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.amber.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  nextLevelInfo != null
                      ? '${nextLevelInfo.xpRequired - totalXp} XP to ${nextLevelInfo.title}'
                      : 'Max Level Reached!',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
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
          'Total Study Hours',
          '${_stats.totalStudyHours}h',
          Icons.access_time,
          Colors.blue,
        ),
        _buildOverviewCard(
          'Average Grade',
          '${_stats.averageGrade.toStringAsFixed(1)}%',
          Icons.grade,
          Colors.green,
        ),
        _buildOverviewCard(
          'Quizzes Taken',
          _stats.totalQuizzesTaken.toString(),
          Icons.quiz,
          Colors.orange,
        ),
        _buildOverviewCard(
          'Courses Enrolled',
          _stats.totalClassesEnrolled.toString(),
          Icons.class_,
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

  Widget _buildGradeTrendsChart() {
    if (_stats.gradeTrends.isEmpty) {
      return const Card(
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('No grade data available yet'),
          ),
        ),
      );
    }

    final sortedEntries = _stats.gradeTrends.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Grade Trends (Last 30 Days)',
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
                          if (value.toInt() < sortedEntries.length) {
                            final date = sortedEntries[value.toInt()].key;
                            return Text(date.substring(5)); // Show MM-DD
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
                      spots: sortedEntries.asMap().entries.map((entry) {
                        final index = entry.key;
                        final grade = sortedEntries[index].value;
                        return FlSpot(index.toDouble(), grade);
                      }).toList(),
                      isCurved: true,
                      color: Colors.green,
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

  Widget _buildStudyHoursChart() {
    if (_stats.studyHoursBySubject.isEmpty) {
      return const Card(
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('No study hours data available yet'),
          ),
        ),
      );
    }

    final subjects = _stats.studyHoursBySubject.keys.toList();
    final hours = _stats.studyHoursBySubject.values.toList();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Study Hours by Subject',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: hours.isNotEmpty ? hours.reduce((a, b) => a > b ? a : b).toDouble() + 2 : 10,
                  barGroups: subjects.asMap().entries.map((entry) {
                    final index = entry.key;
                    final hour = hours[index];
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: hour.toDouble(),
                          color: Colors.blue,
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
                        getTitlesWidget: (value, meta) => Text('${value.toInt()}h'),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < subjects.length) {
                            final subject = subjects[value.toInt()];
                            return Text(subject.length > 8 ? subject.substring(0, 8) : subject);
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

  Widget _buildDailyTargetsSection() {
    final todaysTarget = _dailyTargets.isNotEmpty ? _dailyTargets.last : null;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Learning Target',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (todaysTarget != null) ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Target: ${todaysTarget.targetMinutes} minutes'),
                        Text('Completed: ${todaysTarget.completedMinutes} minutes'),
                        Text('Progress: ${todaysTarget.progressPercentage.toStringAsFixed(1)}%'),
                      ],
                    ),
                  ),
                  CircularProgressIndicator(
                    value: todaysTarget.progressPercentage / 100,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      todaysTarget.isCompleted ? Colors.green : Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: todaysTarget.progressPercentage / 100,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  todaysTarget.isCompleted ? Colors.green : Colors.blue,
                ),
              ),
            ] else ...[
              const Text('No target set for today'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _setTodaysTarget,
                child: const Text('Set Today\'s Target'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStreakSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Study Streaks',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStreakItem(
                    'Current Streak',
                    '${_stats.currentStreak} days',
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStreakItem(
                    'Longest Streak',
                    '${_stats.longestStreak} days',
                    Icons.emoji_events,
                    Colors.amber,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakItem(String title, String value, IconData icon, Color color) {
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

  Widget _buildEnrolledCoursesSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enrolled Courses',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_enrolledCourses.isEmpty)
              const Text('No courses enrolled yet')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _enrolledCourses.length,
                itemBuilder: (context, index) {
                  final course = _enrolledCourses[index];
                  return ListTile(
                    leading: const Icon(Icons.class_, color: Colors.blue),
                    title: Text(course.name),
                    subtitle: Text(course.description),
                    trailing: Text('${course.enrolledStudents.length} students'),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingRemindersSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upcoming Reminders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_upcomingReminders.isEmpty)
              const Text('No upcoming reminders')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _upcomingReminders.length,
                itemBuilder: (context, index) {
                  final reminder = _upcomingReminders[index];
                  return ListTile(
                    leading: Icon(
                      reminder.isDueToday
                          ? Icons.today
                          : reminder.isOverdue
                              ? Icons.warning
                              : Icons.schedule,
                      color: reminder.isOverdue ? Colors.red : Colors.blue,
                    ),
                    title: Text(reminder.title),
                    subtitle: Text(reminder.description),
                    trailing: Text(
                      reminder.isDueToday
                          ? 'Today'
                          : '${reminder.dueDate.day}/${reminder.dueDate.month}',
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAchievementsSection() {
    final gamificationProvider = Provider.of<GamificationProvider>(context);
    final recentAchievements = gamificationProvider.recentAchievements;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Achievements',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (recentAchievements.isNotEmpty)
                  TextButton(
                    onPressed: () => gamificationProvider.clearRecentAchievements(),
                    child: const Text('Clear'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (recentAchievements.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No recent achievements. Keep learning to unlock more!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentAchievements.length,
                itemBuilder: (context, index) {
                  final achievement = recentAchievements[index];
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(achievement.category),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getCategoryIcon(achievement.category),
                        color: Colors.white,
                      ),
                    ),
                    title: Text(achievement.name),
                    subtitle: Text(achievement.description),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '+${achievement.xpReward} XP',
                        style: TextStyle(
                          color: Colors.amber.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementProgressSection() {
    final gamificationProvider = Provider.of<GamificationProvider>(context);
    final unlockedCount = gamificationProvider.unlockedAchievementsCount;
    final totalAchievements = GamificationService.getDefaultAchievements().length;
    final progress = totalAchievements > 0 ? unlockedCount / totalAchievements : 0.0;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Achievement Progress',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$unlockedCount / $totalAchievements',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple.shade400),
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).toInt()}% Complete',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildCategoryProgress('Quiz', gamificationProvider.getAchievementsByCategory('quiz')),
                const SizedBox(width: 16),
                _buildCategoryProgress('Study', gamificationProvider.getAchievementsByCategory('study')),
                const SizedBox(width: 16),
                _buildCategoryProgress('Streak', gamificationProvider.getAchievementsByCategory('streak')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryProgress(String category, List<Achievement> achievements) {
    final unlocked = achievements.where((a) => a.isUnlocked).length;
    final total = achievements.length;
    final progress = total > 0 ? unlocked / total : 0.0;

    return Expanded(
      child: Column(
        children: [
          Text(
            category,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(_getCategoryColor(category.toLowerCase())),
          ),
          const SizedBox(height: 2),
          Text(
            '$unlocked/$total',
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'quiz':
        return Colors.blue;
      case 'study':
        return Colors.green;
      case 'streak':
        return Colors.orange;
      case 'social':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'quiz':
        return Icons.quiz;
      case 'study':
        return Icons.book;
      case 'streak':
        return Icons.local_fire_department;
      case 'social':
        return Icons.people;
      default:
        return Icons.star;
    }
  }

  void _setTodaysTarget() {
    final targetController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Today\'s Study Target'),
        content: TextField(
          controller: targetController,
          decoration: const InputDecoration(
            labelText: 'Target minutes',
            hintText: 'e.g., 120',
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final targetMinutes = int.tryParse(targetController.text) ?? 0;
              if (targetMinutes > 0) {
                final studentId = Provider.of<AuthProvider>(context, listen: false).user?.id ?? '';
                await _progressService.setTodaysTarget(studentId, targetMinutes);
                await _initializeData(); // Refresh data
                Navigator.of(context).pop();
              }
            },
            child: const Text('Set Target'),
          ),
        ],
      ),
    );
  }

  Widget _buildCareerInsightsSection() {
    final careerProvider = Provider.of<CareerRecommendationProvider>(context);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Career Insights',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CareerRecommendationScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.explore),
                  label: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (careerProvider.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (careerProvider.hasRecommendations) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCareerStat(
                    '${careerProvider.recommendations.length}',
                    'Careers Found',
                    Icons.work,
                    Colors.blue,
                  ),
                  _buildCareerStat(
                    careerProvider.getCareerInsights()['averageMatch'] != null
                        ? '${careerProvider.getCareerInsights()['averageMatch'].toStringAsFixed(1)}%'
                        : 'N/A',
                    'Avg Match',
                    Icons.trending_up,
                    Colors.green,
                  ),
                  _buildCareerStat(
                    careerProvider.getCareerInsights()['topCategory'] ?? 'None',
                    'Top Category',
                    Icons.star,
                    Colors.amber,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Your top career recommendations:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              ...careerProvider.getTopRecommendations(limit: 2).map((rec) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          rec.careerName,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getMatchColor(rec.matchPercentage).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${rec.matchPercentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getMatchColor(rec.matchPercentage),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ] else ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.lightbulb_outline, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Complete more quizzes and classes to unlock personalized career recommendations!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCareerStat(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getMatchColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.blue;
    if (percentage >= 40) return Colors.orange;
    return Colors.red;
  }
}