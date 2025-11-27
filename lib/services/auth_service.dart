// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart';

class AuthService {
  static const String baseUrl =
      'https://api.smartclassroom.com'; // Replace with actual API URL

  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final firebase_auth.UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      final firebase_auth.User? firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        final userData = {
          'id': firebaseUser.uid,
          'email': firebaseUser.email,
          'name': firebaseUser.displayName ?? '',
          'role': 'student', // Default role, could be stored in Firestore
          'createdAt':
              firebaseUser.metadata.creationTime?.toIso8601String() ??
              DateTime.now().toIso8601String(),
          'isEmailVerified': true,
        };

        final token = await firebaseUser.getIdToken();

        return {'success': true, 'user': userData, 'token': token};
      } else {
        return {'success': false, 'message': 'Login failed'};
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      return {'success': false, 'message': _getFirebaseAuthErrorMessage(e)};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String name,
    String role,
  ) async {
    try {
      final firebase_auth.UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      final firebase_auth.User? firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        // Update display name
        await firebaseUser.updateDisplayName(name);

        final userData = {
          'id': firebaseUser.uid,
          'email': firebaseUser.email,
          'name': name,
          'role': role,
          'createdAt':
              firebaseUser.metadata.creationTime?.toIso8601String() ??
              DateTime.now().toIso8601String(),
          'isEmailVerified': true,
        };

        final token = await firebaseUser.getIdToken();

        return {'success': true, 'user': userData, 'token': token};
      } else {
        return {'success': false, 'message': 'Registration failed'};
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      return {'success': false, 'message': _getFirebaseAuthErrorMessage(e)};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> updateProfile(String token, User user) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock update profile
    final userData = user.toJson();
    return {'success': true, 'user': userData};

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
    try {
      final firebase_auth.User? user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.reload();
        final updatedUser = _firebaseAuth.currentUser;
        return updatedUser?.emailVerified ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return {'success': false, 'message': 'Google sign in cancelled'};
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final firebase_auth.AuthCredential credential =
          firebase_auth.GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

      final firebase_auth.UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);
      final firebase_auth.User? user = userCredential.user;

      if (user != null) {
        final userData = {
          'id': user.uid,
          'email': user.email,
          'name': user.displayName ?? googleUser.displayName ?? '',
          'role': 'student', // Default role
          'isEmailVerified': user.emailVerified,
          'createdAt':
              user.metadata.creationTime?.toIso8601String() ??
              DateTime.now().toIso8601String(),
        };

        final token = await user.getIdToken();

        return {'success': true, 'user': userData, 'token': token};
      } else {
        return {'success': false, 'message': 'Google sign in failed'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
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

  Future<void> logout() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }

  String _getFirebaseAuthErrorMessage(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed login attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      default:
        return 'An error occurred during authentication.';
    }
  }
}
