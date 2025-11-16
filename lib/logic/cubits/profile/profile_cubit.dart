import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:text_extraction_app/data/services/storage_service.dart';
import 'package:text_extraction_app/logic/cubits/profile/profile_state.dart';
import 'package:text_extraction_app/data/services/firebase_firestore_service.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final FirebaseFirestoreService _firestoreService;
  final StorageService _storageService;
  ProfileCubit(
    this._firestoreService,
    this._storageService,
  ) : super(ProfileInitial());
  Future<void> loadUserProfile(String userId) async {
    emit(ProfileLoading());
    try {
      final user = await _firestoreService.getUserProfile(userId);
      emit(ProfileLoaded(user));
    } catch (e) {
      emit(ProfileError('Failed to load profile: ${e.toString()}'));
    }
  }
  Future<void> updateProfile({
    required String userId,
    String? fullName,
    File? profileImagePath,
  }) async {
    emit(ProfileLoading());
    try {
      String? imageUrl;
      if (profileImagePath != null) {
        imageUrl = await _storageService.uploadProfileImage(userId, profileImagePath);
      }
      await _firestoreService.updateUserProfile(
        userId: userId,
        fullName: fullName,
        profileImageUrl: imageUrl,
      );
     await loadUserProfile(userId);
    } catch (e) {
      emit(ProfileError('Failed to update profile: ${e.toString()}'));
    }
  }
}