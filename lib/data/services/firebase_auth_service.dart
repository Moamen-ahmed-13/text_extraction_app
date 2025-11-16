import 'package:firebase_auth/firebase_auth.dart';
import 'package:text_extraction_app/core/utils/logger_service.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth;
  
  FirebaseAuthService(this._auth);
  
  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signUp(String email, String password) async {
    try {
      LoggerService.info('Creating new user account: $email');
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      LoggerService.info('User account created successfully');
      return result.user;
    } on FirebaseAuthException catch (e) {
      LoggerService.error('Firebase Auth Exception during sign up', e);
      throw _handleAuthException(e);
    } catch (e, stackTrace) {
      LoggerService.error('Unexpected error during sign up', e, stackTrace);
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  Future<User?> signIn(String email, String password) async {
    try {
      LoggerService.info('Signing in user: $email');
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      LoggerService.info('User signed in successfully');
      return result.user;
    } on FirebaseAuthException catch (e) {
      LoggerService.error('Firebase Auth Exception during sign in', e);
      throw _handleAuthException(e);
    } catch (e, stackTrace) {
      LoggerService.error('Unexpected error during sign in', e, stackTrace);
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      LoggerService.info('Signing out current user');
      await _auth.signOut();
      LoggerService.info('User signed out successfully');
    } catch (e, stackTrace) {
      LoggerService.error('Error during sign out', e, stackTrace);
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      LoggerService.info('Sending password reset email to: $email');
      await _auth.sendPasswordResetEmail(email: email);
      LoggerService.info('Password reset email sent successfully to: $email');
    } on FirebaseAuthException catch (e) {
      LoggerService.error('Firebase Auth Exception during password reset', e);
      
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No account found with this email address.');
        case 'invalid-email':
          throw Exception('Invalid email address format.');
        case 'too-many-requests':
          throw Exception('Too many attempts. Please try again later.');
        default:
          throw Exception(_handleAuthException(e));
      }
    } catch (e, stackTrace) {
      LoggerService.error('Unexpected error during password reset', e, stackTrace);
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        LoggerService.info('Updating password for user: ${user.email}');
        await user.updatePassword(newPassword);
        LoggerService.info('Password updated successfully');
      } else {
        LoggerService.warning('Cannot update password: No user signed in');
        throw Exception('No user is currently signed in.');
      }
    } on FirebaseAuthException catch (e) {
      LoggerService.error('Firebase Auth Exception during password update', e);
      throw _handleAuthException(e);
    } catch (e, stackTrace) {
      LoggerService.error('Unexpected error during password update', e, stackTrace);
      throw Exception('Password update failed: ${e.toString()}');
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    LoggerService.warning('Firebase Auth Error Code: ${e.code}');
    
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'requires-recent-login':
        return 'Please log in again to continue.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        LoggerService.error('Unhandled Firebase Auth error', e);
        return e.message ?? 'Authentication error occurred.';
    }
  }
}