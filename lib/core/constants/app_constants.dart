class AppConstants {
  // Supabase Configuration
  static const String supabaseUrl = 'https://slnubgaackcleycvouyv.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNsbnViZ2FhY2tjbGV5Y3ZvdXl2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI5NzU2NjYsImV4cCI6MjA3ODU1MTY2Nn0.9v0XpaR_hMM3N8Vpt0Poa_FrRVUkXlAFeWPKtetF4Nw';
  
  // Storage Buckets
  static const String profileImagesBucket = 'profile_images';
  static const String extractionImagesBucket = 'extraction_images';
   // Firestore Collections
    static const String usersCollection = 'users';
    static const String extractionHistoryCollection = 'extraction_history';
  // Database Tables
  static const String profilesTable = 'profiles';
  static const String extractionHistoryTable = 'extraction_history';
  
  // Local Database
  static const String localDatabaseName = 'text_extractor.db';
  static const int databaseVersion = 1;
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
  
  // Image Picker
  static const int imageQuality = 85;
  static const double maxImageWidth = 1920;
  static const double maxImageHeight = 1080;
  
  // Error Messages
  static const String networkError = 'No internet connection';
  static const String genericError = 'Something went wrong. Please try again.';
  static const String invalidEmail = 'Please enter a valid email address';
  static const String weakPassword = 'Password must be at least 6 characters';
  static const String emptyField = 'This field cannot be empty';
  
  // Success Messages
  static const String loginSuccess = 'Welcome back!';
  static const String registerSuccess = 'Account created successfully!';
  static const String resetPasswordEmailSent = 'Password reset email sent!';
  static const String profileUpdateSuccess = 'Profile updated successfully!';
  static const String textExtractionSuccess = 'Text extracted successfully!';
}