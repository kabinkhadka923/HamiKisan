import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'HamiKisan';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Together We Farm, Together We Grow';

  // Colors
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color lightGreen = Color(0xFF81C784);
  static const Color darkGreen = Color(0xFF388E3C);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color errorRed = Color(0xFFE53935);
  static const Color warningAmber = Color(0xFFFFC107);
  static const Color infoBlue = Color(0xFF2196F3);

  // Dimensions
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 4.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // API Endpoints
  static const String baseUrl = 'https://api.hamikisan.com';
  static const String weatherApiUrl = 'https://api.openweathermap.org/data/2.5';
  static const String marketApiUrl = '$baseUrl/market';

  // Database
  static const String databaseName = 'hamikisan.db';
  static const int databaseVersion = 1;

  // Cache Durations
  static const Duration weatherCacheDuration = Duration(hours: 1);
  static const Duration marketCacheDuration = Duration(minutes: 30);
  static const Duration userCacheDuration = Duration(days: 7);

  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
  static const int minUsernameLength = 3;

  // File Sizes
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB
  static const int maxProfileImageSizeBytes = 2 * 1024 * 1024; // 2MB

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Crop Categories
  static const List<String> cropCategories = [
    'Rice',
    'Wheat',
    'Maize',
    'Potato',
    'Tomato',
    'Vegetables',
    'Fruits',
    'Pulses',
    'Spices',
  ];

  // Product Categories
  static const List<String> productCategories = [
    'All',
    'Crops',
    'Seeds',
    'Fertilizer',
    'Tools',
    'Livestock',
    'Dairy',
  ];

  // User Roles
  static const List<String> userRoles = [
    'farmer',
    'kisanDoctor',
    'kisanAdmin',
    'superAdmin',
  ];

  // Notification Types
  static const String notificationTypeMessage = 'message';
  static const String notificationTypeOrder = 'order';
  static const String notificationTypeDiagnosis = 'diagnosis';
  static const String notificationTypeWeather = 'weather';
  static const String notificationTypePrice = 'price';

  // Error Messages
  static const String networkError = 'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unknownError = 'An unknown error occurred.';
  static const String validationError = 'Please check your input and try again.';

  // Success Messages
  static const String loginSuccess = 'Login successful!';
  static const String registrationSuccess = 'Registration successful!';
  static const String profileUpdateSuccess = 'Profile updated successfully!';
  static const String orderPlacedSuccess = 'Order placed successfully!';

  // Demo Credentials
  static const Map<String, String> demoCredentials = {
    'farmer': 'farmer',
    'doctor': 'doctor',
    'admin': 'admin',
  };

  // Supported Languages
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'ne', 'name': 'नेपाली'},
  ];

  // Weather Icons
  static const Map<String, IconData> weatherIcons = {
    'sunny': Icons.wb_sunny,
    'cloudy': Icons.cloud,
    'rainy': Icons.grain,
    'stormy': Icons.thunderstorm,
    'snowy': Icons.ac_unit,
  };

  // Disease Severity Colors
  static const Map<String, Color> severityColors = {
    'mild': Colors.green,
    'moderate': Colors.orange,
    'severe': Colors.red,
  };
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryGreen,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          elevation: AppConstants.cardElevation,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: AppConstants.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryGreen,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.darkGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}