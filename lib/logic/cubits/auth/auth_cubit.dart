import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:text_extraction_app/data/services/database_helper.dart';
import 'package:text_extraction_app/data/services/firebase_auth_service.dart';
import 'package:text_extraction_app/data/services/firebase_firestore_service.dart';
import 'package:text_extraction_app/logic/cubits/auth/auth_state.dart';

class AuthCubit extends Cubit<AuthenState> {
  final FirebaseAuthService _authService;
  final FirebaseFirestoreService _firestoreService;
  final DatabaseHelper  _databaseHelper;

  AuthCubit(
    this._authService,
    this._firestoreService,
    this._databaseHelper,
  ) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    
    try {
      final user = _authService.currentUser;
      
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    
    try {
      final user = await _authService.signIn(email, password);
      
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthError('Login failed. Please try again.'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signUp(String email, String password, String fullName) async {
    emit(AuthLoading());
    
    try {
      final user = await _authService.signUp(email, password);
      
      if (user != null) {
        await _firestoreService.createUserProfile(
          userId: user.uid,
          email: email,
          fullName: fullName,
        );
        
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthError('Registration failed. Please try again.'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> resetPassword(String email) async {
    emit(AuthLoading());
    
    try {
      await _authService.resetPassword(email);
      emit(AuthPasswordResetSent());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _authService.updatePassword(newPassword);
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      await _databaseHelper.clearAllData();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Logout failed. Please try again.'));
    }
  }
}