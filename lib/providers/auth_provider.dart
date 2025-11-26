import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/security_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _token;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null && _token != null;
  String? get token => _token;

  final AuthService _authService = AuthService();
  final SecurityService _securityService = SecurityService();

  Future<void> initializeAuth() async {
    final token = await _securityService.retrieveEncryptedData('token');
    final userDataString = await _securityService.retrieveEncryptedData('user');

    if (token != null && userDataString != null) {
      _token = token;
      final userData = jsonDecode(userDataString) as Map<String, dynamic>;
      _user = User.fromJson(userData);
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.login(email, password);
      if (result['success']) {
        _user = User.fromJson(result['user']);
        _token = result['token'];

        await _securityService.storeEncryptedData('token', _token!);
        await _securityService.storeEncryptedData('user', jsonEncode(result['user']));

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, String name, String role) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.register(email, password, name, role);
      if (result['success']) {
        _user = User.fromJson(result['user']);
        _token = result['token'];

        await _securityService.storeEncryptedData('token', _token!);
        await _securityService.storeEncryptedData('user', jsonEncode(result['user']));

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      return await _authService.resetPassword(email);
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    _token = null;

    await _securityService.removeEncryptedData('token');
    await _securityService.removeEncryptedData('user');

    notifyListeners();
  }

  Future<bool> updateProfile(User updatedUser) async {
    if (_user == null || _token == null) return false;

    try {
      final result = await _authService.updateProfile(_token!, updatedUser);
      if (result['success']) {
        _user = User.fromJson(result['user']);

        await _securityService.storeEncryptedData('user', jsonEncode(result['user']));

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.signInWithGoogle();
      if (result['success']) {
        _user = User.fromJson(result['user']);
        _token = result['token'];

        await _securityService.storeEncryptedData('token', _token!);
        await _securityService.storeEncryptedData('user', jsonEncode(result['user']));

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithMicrosoft() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.signInWithMicrosoft();
      if (result['success']) {
        _user = User.fromJson(result['user']);
        _token = result['token'];

        await _securityService.storeEncryptedData('token', _token!);
        await _securityService.storeEncryptedData('user', jsonEncode(result['user']));

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendVerificationEmail() async {
    if (_user == null) return false;
    try {
      return await _authService.sendVerificationEmail(_user!.email);
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyEmail() async {
    if (_token == null) return false;
    try {
      final success = await _authService.verifyEmail(_token!);
      if (success && _user != null) {
        // Update user email verification status
        final updatedUser = _user!.copyWith(isEmailVerified: true);
        _user = updatedUser;

        await _securityService.storeEncryptedData('user', jsonEncode(updatedUser.toJson()));

        notifyListeners();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  // Role-based access control helpers
  bool get isStudent => _user?.role == 'student';
  bool get isTeacher => _user?.role == 'teacher';
  bool get isAdmin => _user?.role == 'admin';

  bool hasPermission(String permission) {
    if (_user == null) return false;

    switch (_user!.role) {
      case 'admin':
        return true; // Admins have all permissions
      case 'teacher':
        return ['create_class', 'edit_class', 'delete_class', 'create_lesson', 'edit_lesson', 'delete_lesson'].contains(permission);
      case 'student':
        return ['view_class', 'view_lesson', 'take_quiz'].contains(permission);
      default:
        return false;
    }
  }
}