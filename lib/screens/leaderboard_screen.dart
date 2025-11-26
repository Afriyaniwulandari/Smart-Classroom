import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/gamification_provider.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load leaderboards
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gamificationProvider = Provider.of<GamificationProvider>(context, listen: false);
      gamificationProvider.loadLeaderboards();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final gamificationProvider = Provider.of<GamificationProvider>(context);
    final currentUserId = authProvider.user?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboards'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'XP Points', icon: Icon(Icons.star)),
            Tab(text: 'Grades', icon: Icon(Icons.grade)),
            Tab(text: 'Streaks', icon: Icon(Icons.local_fire_department)),
          ],
        ),
      ),
      body: gamificationProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildLeaderboardTab(
                  gamificationProvider.xpLeaderboard,
                  currentUserId,
                  'XP',
                  (item) => '${item['xp'] ?? 0} XP',
                  Icons.star,
                  Colors.amber,
                ),
                _buildLeaderboardTab(
                  gamificationProvider.gradeLeaderboard,
                  currentUserId,
                  'Grade',
                  (item) => '${(item['averageGrade'] ?? 0).toStringAsFixed(1)}%',
                  Icons.grade,
                  Colors.green,
                ),
                _buildLeaderboardTab(
                  gamificationProvider.streakLeaderboard,
                  currentUserId,
                  'Streak',
                  (item) => '${item['currentStreak'] ?? 0} days',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
              ],
            ),
    );
  }

  Widget _buildLeaderboardTab(
    List<Map<String, dynamic>> leaderboard,
    String currentUserId,
    String metricName,
    String Function(Map<String, dynamic>) valueFormatter,
    IconData icon,
    Color color,
  ) {
    if (leaderboard.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No $metricName data available yet',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Complete activities to appear on the leaderboard!',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: leaderboard.length,
      itemBuilder: (context, index) {
        final item = leaderboard[index];
        final isCurrentUser = item['studentId'] == currentUserId;
        final position = index + 1;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          elevation: isCurrentUser ? 8 : 2,
          color: isCurrentUser ? color.withOpacity(0.1) : null,
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getPositionColor(position),
              ),
              child: Center(
                child: position <= 3
                    ? Icon(
                        _getPositionIcon(position),
                        color: Colors.white,
                        size: 20,
                      )
                    : Text(
                        position.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    item['name'] ?? 'Unknown Student',
                    style: TextStyle(
                      fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                if (isCurrentUser)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'YOU',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Text(item['className'] ?? 'No Class'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: color, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    valueFormatter(item),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getPositionColor(int position) {
    switch (position) {
      case 1:
        return Colors.amber.shade600; // Gold
      case 2:
        return Colors.grey.shade400; // Silver
      case 3:
        return Colors.brown.shade400; // Bronze
      default:
        return Colors.blue.shade400; // Default
    }
  }

  IconData _getPositionIcon(int position) {
    switch (position) {
      case 1:
        return Icons.emoji_events; // Trophy
      case 2:
        return Icons.military_tech; // Medal
      case 3:
        return Icons.workspace_premium; // Premium
      default:
        return Icons.person;
    }
  }
}