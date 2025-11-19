class AppConstants {

  static const String profileImagesBucket = 'profile_images';
  static const String extractionImagesBucket = 'extraction_images';

  static const String usersCollection = 'users';
  static const String extractionHistoryCollection = 'extraction_history';

  static const String profilesTable = 'profiles';
  static const String extractionHistoryTable = 'extraction_history';

  static const String localDatabaseName = 'text_extractor.db';
  static const int databaseVersion = 3;

  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;

  static const int imageQuality = 85;
  static const double maxImageWidth = 1920;
  static const double maxImageHeight = 1080;

  static const String networkError = 'No internet connection';
  static const String genericError = 'Something went wrong. Please try again.';
  static const String invalidEmail = 'Please enter a valid email address';
  static const String weakPassword = 'Password must be at least 6 characters';
  static const String emptyField = 'This field cannot be empty';

  static const String loginSuccess = 'Welcome back!';
  static const String registerSuccess = 'Account created successfully!';
  static const String resetPasswordEmailSent = 'Password reset email sent!';
  static const String profileUpdateSuccess = 'Profile updated successfully!';
  static const String textExtractionSuccess = 'Text extracted successfully!';
}
