class ExtractionHistoryModel {
  final int? id;
  final String userId;
  final String imageUrl;
  final String extractedText;
  final DateTime createdAt;
  ExtractionHistoryModel({
    required this.imageUrl,
    this.id,
    required this.userId,
    required this.extractedText,
    required this.createdAt,
  });
  factory ExtractionHistoryModel.fromJson(Map<String, dynamic> json) {
    return ExtractionHistoryModel(
      id: json['id'] as int?,
      userId: json['user_id'] as String,
      imageUrl: json['image_url'] as String,
      extractedText: json['extracted_text'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'image_url': imageUrl,
      'extracted_text': extractedText,
      'created_at': createdAt.toIso8601String(),
    };
  }
}