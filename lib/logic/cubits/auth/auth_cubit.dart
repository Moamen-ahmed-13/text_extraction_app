import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:text_extraction_app/core/utils/logger_service.dart';
import 'package:text_extraction_app/data/services/database_helper.dart';
import 'package:text_extraction_app/data/services/firebase_auth_service.dart';
import 'package:text_extraction_app/data/services/firebase_firestore_service.dart';
import 'package:text_extraction_app/logic/cubits/auth/auth_state.dart';

class AuthCubit extends Cubit<AuthenState> {
  final FirebaseAuthService _authService;
  final FirebaseFirestoreService _firestoreService;
  final DatabaseHelper _databaseHelper;

  AuthCubit(this._authService, this._firestoreService, this._databaseHelper)
    : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());

    try {
      LoggerService.info('Checking authentication status...');
      final user = _authService.currentUser;

      if (user != null) {
        LoggerService.info('User is authenticated: ${user.email}');
        emit(AuthAuthenticated(user));
      } else {
        LoggerService.info('No user authenticated');
        emit(AuthUnauthenticated());
      }
    } catch (e, stackTrace) {
      LoggerService.error('Error checking auth status', e, stackTrace);
      emit(AuthUnauthenticated());
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());

    try {
      LoggerService.info('Attempting to sign in user: $email');
      final user = await _authService.signIn(email, password);

      if (user != null) {
        LoggerService.info('Sign in successful: ${user.email}');
        emit(AuthAuthenticated(user));
      } else {
        LoggerService.warning('Sign in failed: User is null');
        emit(AuthError('Login failed. Please try again.'));
      }
    } catch (e, stackTrace) {
      LoggerService.error('Sign in error', e, stackTrace);
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signUp(String email, String password, String fullName) async {
    emit(AuthLoading());

    try {
      LoggerService.info('Attempting to sign up user: $email');
      final user = await _authService.signUp(email, password);

      if (user != null) {
        LoggerService.info('User created successfully: ${user.email}');

        try {
          await _firestoreService.createUserProfile(
            userId: user.uid,
            email: email,
            fullName: fullName,
          );
          LoggerService.info('User profile created in Firestore');
        } catch (firestoreError) {
          LoggerService.error(
            'Failed to create Firestore profile',
            firestoreError,
          );
        }

        emit(AuthAuthenticated(user));
      } else {
        LoggerService.warning('Sign up failed: User is null');
        emit(AuthError('Registration failed. Please try again.'));
      }
    } catch (e, stackTrace) {
      LoggerService.error('Sign up error', e, stackTrace);
      emit(AuthError(e.toString()));
    }
  }

  Future<void> resetPassword(String email) async {
    final currentState = state;

    try {
      LoggerService.info('Sending password reset email to: $email');
      await _authService.resetPassword(email);
      LoggerService.info('Password reset email sent successfully');

      emit(AuthPasswordResetSent());

      await Future.delayed(const Duration(milliseconds: 500));
      if (state is AuthPasswordResetSent) {
        emit(currentState);
      }
    } catch (e, stackTrace) {
      LoggerService.error('Password reset error', e, stackTrace);
      emit(AuthError(e.toString()));

      await Future.delayed(const Duration(seconds: 2));
      if (state is AuthError) {
        emit(currentState);
      }
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      LoggerService.info('Attempting to update password');
      await _authService.updatePassword(newPassword);
      LoggerService.info('Password updated successfully');
    } catch (e, stackTrace) {
      LoggerService.error('Password update error', e, stackTrace);
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signOut() async {
    try {
      LoggerService.info('Signing out user...');

      await _authService.signOut();

      LoggerService.info('User signed out successfully');
      emit(AuthUnauthenticated());
    } catch (e, stackTrace) {
      LoggerService.error('Sign out error', e, stackTrace);
      emit(AuthError('Logout failed. Please try again.'));
    }
  }
}
