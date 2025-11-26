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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
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
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${user?.name ?? 'User'}!',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Role: ${user?.role ?? 'Unknown'}'),
                const SizedBox(height: 32),

                // Common buttons for all users
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ClassesScreen()),
                    );
                  },
                  child: const Text('View Classes'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RecommendationsScreen()),
                    );
                  },
                  child: const Text('AI Recommendations'),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const DigitalLibraryScreen()),
                    );
                  },
                  icon: const Icon(Icons.library_books),
                  label: const Text('Digital Library'),
                ),

                // Student-specific buttons
                if (user?.role == 'student') ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const StudentDashboardScreen()),
                      );
                    },
                    icon: const Icon(Icons.dashboard),
                    label: const Text('My Dashboard'),
                  ),
                ],

                // Student-specific buttons (continued)
                if (user?.role == 'student') ...[
                  const SizedBox(height: 32),
                  const Text(
                    'Attendance',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AttendanceHistoryScreen()),
                      );
                    },
                    icon: const Icon(Icons.history),
                    label: const Text('View My Attendance'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const QrScannerScreen()),
                      );
                    },
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Scan QR Code'),
                  ),
                ],

                // Teacher-specific section
                if (user?.role == 'teacher') ...[
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const TeacherDashboardScreen()),
                      );
                    },
                    child: const Text('View Teacher Dashboard'),
                  ),
                ],

                const SizedBox(height: 32),
                const Text('Use these credentials to test:'),
                const Text('Student: student@example.com / password123'),
                const Text('Teacher: teacher@example.com / password123'),
              ],
            ),
          ),
          const VoiceAssistantOverlay(),
        ],
      ),
    );
  }

}