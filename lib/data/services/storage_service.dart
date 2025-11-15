import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:text_extraction_app/core/constants/app_constants.dart';

class StorageService {
  final SupabaseClient _supabaseClient;
  StorageService(this._supabaseClient);

  Future<String> uploadProfileImage(String userId, File imageFile) async {
    try {
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.png';
      final path='$userId/$fileName';
      await _supabaseClient.storage
          .from(AppConstants.profileImagesBucket)
          .upload(path,imageFile);

      final publicUrl = _supabaseClient.storage
          .from(AppConstants.profileImagesBucket)
          .getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload profile image: ${e.toString()}');
    }
  }
  Future<void> deleteProfileImage(String userId, String imageUrl) async {
    try {
      final uri = Uri.parse(imageUrl);
      final path=uri.pathSegments.skip(4).join('/'); 
      await _supabaseClient.storage
          .from(AppConstants.profileImagesBucket)
          .remove([path]);
    } catch (e) {
      throw Exception('Failed to delete profile image: ${e.toString()}');
    }
  }
}