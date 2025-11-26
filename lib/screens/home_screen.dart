import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import 'profile_screen.dart';
import 'classes_screen.dart';
import 'recommendations_screen.dart';
import 'attendance_history_screen.dart';
import 'qr_scanner_screen.dart';
import 'notifications_screen.dart';
import 'teacher_dashboard_screen.dart';
import 'student_dashboard_screen.dart';
import 'digital_library_screen.dart';
import '../widgets/voice_assistant_overlay.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Custom color scheme
  static const Color primaryColor = Color(0xFF4A90E2);
  static const Color secondaryColor = Color(0xFF7B68EE);
  static const Color backgroundColor = Color(0xFFF5F7FA);
  static const List<Color> pastelBlueGradient = [Color(0xFFB3E5FC), Color(0xFF81D4FA)];
  static const List<Color> pastelPinkGradient = [Color(0xFFF8BBD9), Color(0xFFF48FB1)];

  Widget _buildHomeTab() {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    // Define features based on user role
    List<Map<String, dynamic>> features = [
      {
        'title': 'View Classes',
        'icon': Icons.class_,
        'iconColor': Colors.white,
        'gradientColors': pastelBlueGradient,
        'onTap': () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ClassesScreen()),
        ),
      },
      {
        'title': 'AI Recommendations',
        'icon': Icons.lightbulb_outline,
        'iconColor': Colors.white,
        'gradientColors': pastelPinkGradient,
        'onTap': () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RecommendationsScreen()),
        ),
      },
      {
        'title': 'Digital Library',
        'icon': Icons.library_books,
        'iconColor': Colors.white,
        'gradientColors': pastelBlueGradient,
        'onTap': () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DigitalLibraryScreen()),
        ),
      },
    ];

    // Add student-specific features
    if (user?.role == 'student') {
      features.addAll([
        {
          'title': 'My Dashboard',
          'icon': Icons.dashboard,
          'iconColor': Colors.white,
          'gradientColors': pastelPinkGradient,
          'onTap': () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const StudentDashboardScreen()),
          ),
        },
        {
          'title': 'View Attendance',
          'icon': Icons.history,
          'iconColor': Colors.white,
          'gradientColors': pastelBlueGradient,
          'onTap': () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AttendanceHistoryScreen()),
          ),
        },
        {
          'title': 'Scan QR Code',
          'icon': Icons.qr_code_scanner,
          'iconColor': Colors.white,
          'gradientColors': pastelPinkGradient,
          'onTap': () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const QrScannerScreen()),
          ),
        },
      ]);
    }

    // Add teacher-specific features
    if (user?.role == 'teacher') {
      features.add({
        'title': 'Teacher Dashboard',
        'icon': Icons.school,
        'iconColor': Colors.white,
        'gradientColors': pastelBlueGradient,
        'onTap': () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const TeacherDashboardScreen()),
        ),
      });
    }

    return Stack(
      children: [
        Container(
          color: backgroundColor,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Card
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, secondaryColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back, ${user?.name ?? 'User'}!',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Role: ${user?.role ?? 'Unknown'}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Features Grid
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: features.map((feature) => _buildFeatureCard(feature)).toList(),
                ),
              ],
            ),
          ),
        ),
        const VoiceAssistantOverlay(),
      ],
    );
  }

  Widget _buildFeatureCard(Map<String, dynamic> feature) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: feature['onTap'],
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: feature['gradientColors'],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                feature['icon'],
                size: 48,
                color: feature['iconColor'],
              ),
              const SizedBox(height: 12),
              Text(
                feature['title'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Smart Classroom'),
      actions: [
        Consumer<NotificationProvider>(
          builder: (context, notificationProvider, child) {
            final unreadCount = notificationProvider.unreadCount;
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                    );
                  },
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            await authProvider.logout();
            if (context.mounted) {
              Navigator.of(context).pushReplacementNamed('/login');
            }
          },
        ),
      ],
    );
  }

  BottomNavigationBar _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.class_),
          label: 'Classes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.library_books),
          label: 'Library',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF81D4FA), // Pastel blue
      unselectedItemColor: const Color(0xFFF48FB1), // Pastel pink
      backgroundColor: const Color(0xFFF5F7FA), // Light background for enhanced appeal
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(),
          const ClassesScreen(),
          const DigitalLibraryScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

}