import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/security_service.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final SecurityService _securityService = SecurityService();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Smart Classroom',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    final sanitized = SecurityService.sanitizeInput(value);
                    if (!SecurityService.isValidEmail(sanitized)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    final sanitized = SecurityService.sanitizeInput(value);
                    if (!SecurityService.isValidPassword(sanitized)) {
                      return 'Password must be at least 8 characters with uppercase, lowercase, number and special character';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: authProvider.isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            // Check rate limiting
                            if (_securityService.isRateLimited('login_${_emailController.text.trim()}')) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Too many login attempts. Please wait before trying again.')),
                              );
                              return;
                            }

                            await _securityService.logActivity('Login attempt', userId: _emailController.text.trim());

                            final success = await authProvider.login(
                              SecurityService.sanitizeInput(_emailController.text.trim()),
                              SecurityService.sanitizeInput(_passwordController.text),
                            );

                            if (success && mounted) {
                              await _securityService.logActivity('Login successful', userId: _emailController.text.trim());
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => const HomeScreen()),
                              );
                            } else {
                              await _securityService.logActivity('Login failed', userId: _emailController.text.trim());
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Login failed. Please check your credentials and verify your email.')),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: authProvider.isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Login'),
                ),
                const SizedBox(height: 16),
                const Text('Or continue with', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: authProvider.isLoading
                            ? null
                            : () async {
                                final success = await authProvider.signInWithGoogle();
                                if (success && mounted) {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Google sign in failed')),
                                  );
                                }
                              },
                        icon: const Icon(Icons.g_mobiledata, color: Colors.white),
                        label: const Text('Google'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: authProvider.isLoading
                            ? null
                            : () async {
                                final success = await authProvider.signInWithMicrosoft();
                                if (success && mounted) {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Microsoft sign in failed')),
                                  );
                                }
                              },
                        icon: const Icon(Icons.business, color: Colors.white),
                        label: const Text('Microsoft'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[900],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () async {
                    if (_emailController.text.isNotEmpty) {
                      final success = await authProvider.resetPassword(_emailController.text.trim());
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(success ? 'Password reset email sent' : 'Failed to send reset email')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter your email first')),
                      );
                    }
                  },
                  child: const Text('Forgot Password?'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        );
                      },
                      child: const Text('Register'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}