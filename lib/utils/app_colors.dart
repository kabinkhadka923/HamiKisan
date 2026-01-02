import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors (Main Branding)
  static const Color primaryGreen = Color(0xFF4CAF50);  // Agriculture main color
  static const Color earthBrown = Color(0xFF795548);    // Soil color
  static const Color sunYellow = Color(0xFFFBC02D);     // Energy & harvest
  
  // Secondary Colors (UI Support)
  static const Color skyBlue = Color(0xFF03A9F4);       // Weather widget
  static const Color himalayanOrange = Color(0xFFFF9800); // Offers & alerts
  static const Color coolGrayLight = Color(0xFFF5F5F5);  // Backgrounds
  static const Color coolGrayDark = Color(0xFF9E9E9E);   // Text icons
  
  // Tertiary Colors (Small elements)
  static const Color leafGreen = Color(0xFF81C784);      // Hover states
  static const Color mountainDarkGreen = Color(0xFF2E7D32); // Header text
  static const Color soilBlack = Color(0xFF212121);      // Text & nav
  
  // Common Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGreen, leafGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient headerGradient = LinearGradient(
    colors: [skyBlue, primaryGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}