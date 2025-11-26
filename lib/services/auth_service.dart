// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:oauth2/oauth2.dart' as oauth2;
import '../models/user.dart';

class AuthService {
  static const String baseUrl = 'https://api.smartclassroom.com'; // Replace with actual API URL

  // final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  // final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Mock data for development
  final Map<String, Map<String, dynamic>> _mockUsers = {
    'student@example.com': {
      'password': 'password123',
      'user': {
        'id': '1',
        'email': 'student@example.com',
        'name': 'John Student',
        'role': 'student',
        'className': 'Class 10A',
        'interests': ['Mathematics', 'Science'],
        'createdAt': '2024-01-01T00:00:00.000Z',
        'isEmailVerified': true,
      },
    },
    'teacher@example.com': {
      'password': 'password123',
      'user': {
        'id': '2',
        'email': 'teacher@example.com',
        'name': 'Jane Teacher',
        'role': 'teacher',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'isEmailVerified': true,
      },
    },
  };

  Future<Map<String, dynamic>> login(String email, String password) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock authentication
    if (_mockUsers.containsKey(email) && _mockUsers[email]!['password'] == password) {
      final userData = _mockUsers[email]!['user'];
      if (userData['isEmailVerified'] == false) {
        return {'success': false, 'message': 'Please verify your email before logging in'};
      }
      return {
        'success': true,
        'user': userData,
        'token': 'mock_jwt_token_${userData['id']}',
      };
    }

    // Uncomment below for real API call
    /*
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'user': data['user'],
          'token': data['token'],
        };
      } else {
        return {'success': false, 'message': 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
    */

    return {'success': false, 'message': 'Invalid credentials'};
  }

  Future<Map<String, dynamic>> register(String email, String password, String name, String role) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock registration
    if (_mockUsers.containsKey(email)) {
      return {'success': false, 'message': 'User already exists'};
    }

    final newUser = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'email': email,
      'name': name,
      'role': role,
      'createdAt': DateTime.now().toIso8601String(),
      'isEmailVerified': false,
    };

    _mockUsers[email] = {
      'password': password,
      'user': newUser,
    };

    return {
      'success': true,
      'user': newUser,
      'token': 'mock_jwt_token_${newUser['id']}',
    };

    // Uncomment below for real API call
    /*
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'role': role,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'user': data['user'],
          'token': data['token'],
        };
      } else {
        return {'success': false, 'message': 'Registration failed'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
    */
  }

  Future<bool> resetPassword(String email) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock reset password - send email if user exists
    if (_mockUsers.containsKey(email)) {
      // Simulate sending reset email
      return true;
    }
    return false;

    // Uncomment below for real API call
    /*
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
    */
  }

  Future<Map<String, dynamic>> updateProfile(String token, User user) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock update profile
    final userData = user.toJson();
    return {
      'success': true,
      'user': userData,
    };

    // Uncomment below for real API call
    /*
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'user': data['user'],
        };
      } else {
        return {'success': false, 'message': 'Update failed'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
    */
  }

  Future<bool> verifyEmail(String token) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock email verification
    return true;

    // Uncomment below for real API call
    /*
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-email'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
    */
  }

  Future<Map<String, dynamic>> signInWithGoogle() async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock Google SSO
    final mockUser = {
      'id': 'google_${DateTime.now().millisecondsSinceEpoch}',
      'email': 'googleuser@example.com',
      'name': 'Google User',
      'role': 'student', // Default role for SSO
      'createdAt': DateTime.now().toIso8601String(),
      'isEmailVerified': true, // SSO emails are verified
    };

    return {
      'success': true,
      'user': mockUser,
      'token': 'mock_google_token_${mockUser['id']}',
    };

    // Uncomment below for real Google SSO
    /*
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return {'success': false, 'message': 'Google sign in cancelled'};
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final userData = {
          'id': user.uid,
          'email': user.email,
          'name': user.displayName,
          'role': 'student', // Default role
          'isEmailVerified': user.emailVerified,
          'createdAt': DateTime.now().toIso8601String(),
        };

        return {
          'success': true,
          'user': userData,
          'token': await user.getIdToken(),
        };
      } else {
        return {'success': false, 'message': 'Google sign in failed'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
    */
  }

  Future<Map<String, dynamic>> signInWithMicrosoft() async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock Microsoft SSO
    final mockUser = {
      'id': 'microsoft_${DateTime.now().millisecondsSinceEpoch}',
      'email': 'microsoftuser@example.com',
      'name': 'Microsoft User',
      'role': 'student', // Default role for SSO
      'createdAt': DateTime.now().toIso8601String(),
      'isEmailVerified': true, // SSO emails are verified
    };

    return {
      'success': true,
      'user': mockUser,
      'token': 'mock_microsoft_token_${mockUser['id']}',
    };

    // Uncomment below for real Microsoft SSO
    /*
    // This would require Microsoft Azure AD setup
    // For simplicity, using OAuth2 package
    try {
      // Placeholder for Microsoft OAuth implementation
      return {'success': false, 'message': 'Microsoft SSO not implemented'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
    */
  }

  Future<bool> sendVerificationEmail(String email) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock sending verification email
    return true;

    // Uncomment below for real email sending
    /*
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-verification-email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
    */
  }
}