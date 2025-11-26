import 'dart:convert';
import 'dart:io';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
class SecurityService {
  static const String _encryptionKey = 'your32characterencryptionkeyhere'; // In production, use secure key management
  static const String _activityLogKey = 'activity_logs';

  late final encrypt.Encrypter _encrypter;
  late final encrypt.IV _iv;

  SecurityService() {
    final key = encrypt.Key.fromUtf8(_encryptionKey);
    _iv = encrypt.IV.fromLength(16);
    _encrypter = encrypt.Encrypter(encrypt.AES(key));
  }

  // JWT Token Management
  Map<String, dynamic>? decodeJWT(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      return json.decode(resp);
    } catch (e) {
      print('Error decoding JWT: $e');
      return null;
    }
  }

  bool isTokenExpired(String token) {
    final payload = decodeJWT(token);
    if (payload == null || !payload.containsKey('exp')) return true;

    final exp = payload['exp'] as int;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return now >= exp;
  }

  String? getTokenSubject(String token) {
    final payload = decodeJWT(token);
    return payload?['sub'] as String?;
  }

  // Data Encryption Utilities
  String encryptData(String data) {
    final encrypted = _encrypter.encrypt(data, iv: _iv);
    return encrypted.base64;
  }

  String decryptData(String encryptedData) {
    final encrypted = encrypt.Encrypted.fromBase64(encryptedData);
    return _encrypter.decrypt(encrypted, iv: _iv);
  }

  // Secure Storage for Sensitive Data
  Future<void> storeEncryptedData(String key, String data) async {
    final prefs = await SharedPreferences.getInstance();
    final encrypted = encryptData(data);
    await prefs.setString(key, encrypted);
  }

  Future<String?> retrieveEncryptedData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final encrypted = prefs.getString(key);
    if (encrypted == null) return null;

    try {
      return decryptData(encrypted);
    } catch (e) {
      print('Error decrypting data: $e');
      return null;
    }
  }

  Future<void> removeEncryptedData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // Password Hashing (for additional security, though Firebase handles this)
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // Upload Content Validation
  bool validateFileUpload(File file, {int maxSizeMB = 10, List<String> allowedExtensions = const []}) {
    // Check file size
    final fileSizeMB = file.lengthSync() / (1024 * 1024);
    if (fileSizeMB > maxSizeMB) {
      logActivity('File upload rejected: File too large (${fileSizeMB.toStringAsFixed(2)}MB > ${maxSizeMB}MB)');
      return false;
    }

    // Check file extension
    if (allowedExtensions.isNotEmpty) {
      final extension = file.path.split('.').last.toLowerCase();
      if (!allowedExtensions.contains(extension)) {
        logActivity('File upload rejected: Invalid extension .$extension. Allowed: ${allowedExtensions.join(', ')}');
        return false;
      }
    }

    // Basic content type validation (you might want to use a more robust library)
    final mimeType = _getMimeType(file.path);
    if (!_isAllowedMimeType(mimeType)) {
      logActivity('File upload rejected: Invalid MIME type $mimeType');
      return false;
    }

    logActivity('File upload validated: ${file.path} (${fileSizeMB.toStringAsFixed(2)}MB)');
    return true;
  }

  String _getMimeType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    final mimeTypes = {
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xls': 'application/vnd.ms-excel',
      'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'ppt': 'application/vnd.ms-powerpoint',
      'pptx': 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'txt': 'text/plain',
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'mp4': 'video/mp4',
      'avi': 'video/x-msvideo',
      'mov': 'video/quicktime',
    };
    return mimeTypes[extension] ?? 'application/octet-stream';
  }

  bool _isAllowedMimeType(String mimeType) {
    const allowedTypes = [
      'application/pdf',
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'application/vnd.ms-excel',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'application/vnd.ms-powerpoint',
      'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'text/plain',
      'image/jpeg',
      'image/png',
      'image/gif',
      'video/mp4',
      'video/x-msvideo',
      'video/quicktime',
    ];
    return allowedTypes.contains(mimeType);
  }

  // Activity Logging
  Future<void> logActivity(String activity, {String? userId, Map<String, dynamic>? metadata}) async {
    final logEntry = {
      'timestamp': DateTime.now().toIso8601String(),
      'activity': activity,
      'userId': userId,
      'metadata': metadata,
    };

    final prefs = await SharedPreferences.getInstance();
    final existingLogs = prefs.getStringList(_activityLogKey) ?? [];
    existingLogs.add(json.encode(logEntry));

    // Keep only last 1000 entries to prevent storage bloat
    if (existingLogs.length > 1000) {
      existingLogs.removeRange(0, existingLogs.length - 1000);
    }

    await prefs.setStringList(_activityLogKey, existingLogs);
  }

  Future<List<Map<String, dynamic>>> getActivityLogs({int limit = 100}) async {
    final prefs = await SharedPreferences.getInstance();
    final logs = prefs.getStringList(_activityLogKey) ?? [];

    return logs.reversed.take(limit).map((log) {
      try {
        return json.decode(log) as Map<String, dynamic>;
      } catch (e) {
        return {'error': 'Invalid log entry', 'raw': log};
      }
    }).toList();
  }

  Future<void> clearActivityLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activityLogKey);
  }

  // Security Headers for API Calls
  Map<String, String> getSecurityHeaders(String? token) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
      'X-Content-Type-Options': 'nosniff',
      'X-Frame-Options': 'DENY',
      'X-XSS-Protection': '1; mode=block',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Input Validation Helpers
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  static bool isValidPassword(String password) {
    // At least 8 characters, 1 uppercase, 1 lowercase, 1 number, 1 special character
    final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    return passwordRegex.hasMatch(password);
  }

  static bool isValidName(String name) {
    // Allow letters, spaces, hyphens, apostrophes, minimum 2 characters
    final nameRegex = RegExp(r"^[a-zA-Z\s\-']{2,}$");
    return nameRegex.hasMatch(name) && name.trim().length >= 2;
  }

  static String sanitizeInput(String input) {
    // Basic sanitization - remove potentially dangerous characters
    return input.replaceAll(RegExp(r'[<>"/\\]'), '');
  }

  // Rate Limiting (simple implementation)
  static final Map<String, List<DateTime>> _requestTimes = {};

  bool isRateLimited(String identifier, {int maxRequests = 10, Duration window = const Duration(minutes: 1)}) {
    final now = DateTime.now();
    final times = _requestTimes[identifier] ?? [];

    // Remove old requests outside the window
    times.removeWhere((time) => now.difference(time) > window);

    if (times.length >= maxRequests) {
      logActivity('Rate limit exceeded for $identifier');
      return true;
    }

    times.add(now);
    _requestTimes[identifier] = times;
    return false;
  }
}