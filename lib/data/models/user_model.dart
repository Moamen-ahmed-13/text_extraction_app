import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
  });
  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      id: data['id']??'',
      email: data['email']??'',
      fullName: data['full_name']??'',
      profileImageUrl: data['profile_image_url'],
      createdAt: (data['created_at'] as Timestamp?)?.toDate()??DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate()??DateTime.now(),
    );
  }
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'profile_image_url': profileImageUrl,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }
}