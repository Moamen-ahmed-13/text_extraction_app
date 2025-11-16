import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:text_extraction_app/core/constants/app_constants.dart';
import 'package:text_extraction_app/data/models/user_model.dart';

class FirebaseFirestoreService {
  final FirebaseFirestore _firestore;
  FirebaseFirestoreService(this._firestore);

  Future<void> createUserProfile({
    required String userId,
    required String email,
    required String fullName,
  }) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .set({
            'id': userId,
            'email': email,
            'full_name': fullName,
            'profile_image_url': null,
            'created_at': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Failed to create user profile: ${e.toString()}');
    }
  }

  Future<UserModel> getUserProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc.data()!);
      } else {
        throw Exception('User profile not found');
      }
    } catch (e) {
      throw Exception('Failed to fetch user profile: ${e.toString()}');
    }
  }

  Future<void> updateUserProfile({
    required String userId,
    String? fullName,
    String? profileImageUrl,
  }) async {
    try {
      final Map<String, dynamic> updates = {
        'updated_at': FieldValue.serverTimestamp(),
      };
      if (fullName != null) {
        updates['full_name'] = fullName;
      }
      if (profileImageUrl != null) {
        updates['profile_image_url'] = profileImageUrl;
      }
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update(updates);
    } catch (e) {
      throw Exception('Failed to update user profile: ${e.toString()}');
    }
  }

  Future<void> deleteUserProfile(String userId) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete profile: ${e.toString()}');
    }
  }

  Future<void> saveExtractionToCloud({
    required String userId,
    required String imageUrl,
    required String extractedText,
  }) async {
    try {
      await _firestore
          .collection(AppConstants.extractionHistoryCollection)
          .add({
            'user_id': userId,
            'image_url': imageUrl,
            'extracted_text': extractedText,
            'created_at': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Failed to save extraction to cloud: ${e.toString()}');
    }
  }
}
