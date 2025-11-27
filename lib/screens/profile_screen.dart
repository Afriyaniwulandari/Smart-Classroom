import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../models/user.dart';

const Color pastelBlue = Color(0xFFAEC6CF);
const Color pastelPink = Color(0xFFFFB6C1);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _classController;
  String? _selectedRole;
  List<String> _interests = [];
  bool _notificationsEnabled = true;
  Map<String, bool> _notificationSettings = {
    'task': true,
    'announcement': true,
    'live_class': true,
    'ai_reminder': true,
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _classController = TextEditingController();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone ?? '';
      _classController.text = user.className ?? '';
      _selectedRole = user.role;
      _interests = user.interests ?? [];
    }
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );
    _notificationsEnabled = await notificationProvider
        .areNotificationsEnabled();
    _notificationSettings = await notificationProvider
        .getNotificationSettings();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('User not found')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: pastelBlue,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [pastelBlue, pastelPink],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(204),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(26),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: user.profilePicture != null
                            ? NetworkImage(user.profilePicture!)
                            : null,
                        child: user.profilePicture == null
                            ? Icon(
                                Icons.camera_alt,
                                size: 30,
                                color: pastelBlue,
                              )
                            : null,
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: pastelBlue,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.person, color: pastelBlue),
                      filled: true,
                      fillColor: Colors.white.withAlpha(229),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: pastelBlue,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.email, color: pastelBlue),
                      filled: true,
                      fillColor: Colors.white.withAlpha(229),
                    ),
                    enabled: false, // Email cannot be changed
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: pastelBlue,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.phone, color: pastelBlue),
                      filled: true,
                      fillColor: Colors.white.withAlpha(229),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Role management - only admins can change roles
                  if (Provider.of<AuthProvider>(context).isAdmin)
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: InputDecoration(
                        labelText: 'Role',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: pastelBlue,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(
                          Icons.admin_panel_settings,
                          color: pastelBlue,
                        ),
                        filled: true,
                        fillColor: Colors.white.withAlpha(229),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'student',
                          child: Text('Student'),
                        ),
                        DropdownMenuItem(
                          value: 'teacher',
                          child: Text('Teacher'),
                        ),
                        DropdownMenuItem(value: 'admin', child: Text('Admin')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value!;
                        });
                      },
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(204),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(26),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.badge),
                          const SizedBox(width: 8),
                          Text('Role: ${user.role.toUpperCase()}'),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (_selectedRole == 'student')
                    TextFormField(
                      controller: _classController,
                      decoration: InputDecoration(
                        labelText: 'Class',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: pastelBlue,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.school, color: pastelBlue),
                        filled: true,
                        fillColor: Colors.white.withAlpha(229),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(204),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(26),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Interests',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Wrap(
                    spacing: 8.0,
                    children:
                        [
                          'Mathematics',
                          'Science',
                          'History',
                          'English',
                          'Art',
                          'Music',
                          'Sports',
                          'Technology',
                        ].map((interest) {
                          final isSelected = _interests.contains(interest);
                          return FilterChip(
                            label: Text(interest),
                            selected: isSelected,
                            selectedColor: pastelBlue,
                            checkmarkColor: Colors.white,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _interests.add(interest);
                                } else {
                                  _interests.remove(interest);
                                }
                              });
                            },
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(204),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(26),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Notification Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(204),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(26),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: SwitchListTile(
                      title: const Text('Enable Notifications'),
                      subtitle: const Text(
                        'Receive push notifications from the app',
                      ),
                      value: _notificationsEnabled,
                      onChanged: (value) async {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                        final notificationProvider =
                            Provider.of<NotificationProvider>(
                              context,
                              listen: false,
                            );
                        await notificationProvider.setNotificationsEnabled(
                          value,
                        );
                      },
                    ),
                  ),
                  if (_notificationsEnabled) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(204),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(26),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Notification Types',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(204),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(26),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: SwitchListTile(
                        title: const Text('Task Deadlines'),
                        subtitle: const Text(
                          'Reminders for upcoming task deadlines',
                        ),
                        value: _notificationSettings['task'] ?? true,
                        onChanged: (value) async {
                          setState(() {
                            _notificationSettings['task'] = value;
                          });
                          final notificationProvider =
                              Provider.of<NotificationProvider>(
                                context,
                                listen: false,
                              );
                          await notificationProvider.setNotificationSettings(
                            _notificationSettings,
                          );
                        },
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(204),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(26),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: SwitchListTile(
                        title: const Text('Announcements'),
                        subtitle: const Text(
                          'Important announcements from teachers',
                        ),
                        value: _notificationSettings['announcement'] ?? true,
                        onChanged: (value) async {
                          setState(() {
                            _notificationSettings['announcement'] = value;
                          });
                          final notificationProvider =
                              Provider.of<NotificationProvider>(
                                context,
                                listen: false,
                              );
                          await notificationProvider.setNotificationSettings(
                            _notificationSettings,
                          );
                        },
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(204),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(26),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: SwitchListTile(
                        title: const Text('Live Classes'),
                        subtitle: const Text(
                          'Reminders for scheduled live classes',
                        ),
                        value: _notificationSettings['live_class'] ?? true,
                        onChanged: (value) async {
                          setState(() {
                            _notificationSettings['live_class'] = value;
                          });
                          final notificationProvider =
                              Provider.of<NotificationProvider>(
                                context,
                                listen: false,
                              );
                          await notificationProvider.setNotificationSettings(
                            _notificationSettings,
                          );
                        },
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(204),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(26),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: SwitchListTile(
                        title: const Text('AI Learning Suggestions'),
                        subtitle: const Text(
                          'Personalized learning recommendations',
                        ),
                        value: _notificationSettings['ai_reminder'] ?? true,
                        onChanged: (value) async {
                          setState(() {
                            _notificationSettings['ai_reminder'] = value;
                          });
                          final notificationProvider =
                              Provider.of<NotificationProvider>(
                                context,
                                listen: false,
                              );
                          await notificationProvider.setNotificationSettings(
                            _notificationSettings,
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [pastelBlue, pastelPink],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(51),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Save Profile'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // In a real app, you would upload the image and get the URL
      // For now, we'll just show a message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image selected (upload not implemented)'),
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final updatedUser = User(
        id: authProvider.user!.id,
        email: authProvider.user!.email,
        name: _nameController.text,
        role: _selectedRole!,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        className: _classController.text.isEmpty ? null : _classController.text,
        interests: _interests.isEmpty ? null : _interests,
        profilePicture: authProvider.user!.profilePicture,
        createdAt: authProvider.user!.createdAt,
        isEmailVerified: authProvider.user!.isEmailVerified,
      );

      final success = await authProvider.updateProfile(updatedUser);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _classController.dispose();
    super.dispose();
  }
}
