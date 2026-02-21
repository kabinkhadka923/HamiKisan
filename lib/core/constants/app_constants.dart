import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// 📱 HamiKisan - Complete Application Constants
/// Production-ready with enhanced organization and maintainability
class AppConstants {
  // 🔒 Private constructor to prevent instantiation
  AppConstants._();

  // ==============================================
  // 📊 APP INFORMATION & METADATA
  // ==============================================
  static const String appName = 'HamiKisan';
  static const String appTagline = 'Together Farmers, Better Harvest';
  static const String appDescription = 'Agricultural Marketplace, Community & Expert Platform';
  static const String appSlogan = 'Connecting Farmers, Empowering Agriculture';
  
  static const String appVersion = '2.0.0';
  static const String buildNumber = '200';
  static const String appPackage = 'com.hamikisan.app';
  
  static String get copyright => '© ${DateTime.now().year} HamiKisan. All rights reserved.';
  static const String privacyPolicyUrl = 'https://hamikisan.com/privacy';
  static const String termsOfServiceUrl = 'https://hamikisan.com/terms';
  static const String supportEmail = 'support@hamikisan.com';
  static const String websiteUrl = 'https://hamikisan.com';

  // ==============================================
  // 🎨 DESIGN SYSTEM - COLORS
  // ==============================================
  /// Primary Brand Colors
  static const Color primaryGreen = Color(0xFF2E7D32); // Agriculture Green
  static const Color primaryGreenDark = Color(0xFF005005);
  static const Color primaryGreenLight = Color(0xFF60AD5E);
  
  /// Secondary Colors
  static const Color secondaryGold = Color(0xFFFFC107); // Harvest Gold
  static const Color secondaryOrange = Color(0xFFFF9800); // Soil Orange
  static const Color secondaryBrown = Color(0xFF8D6E63); // Earth Brown
  
  /// Neutral Colors
  static const Color neutralBlack = Color(0xFF212121);
  static const Color neutralGrayDark = Color(0xFF424242);
  static const Color neutralGray = Color(0xFF757575);
  static const Color neutralGrayLight = Color(0xFFBDBDBD);
  static const Color neutralWhite = Color(0xFFFFFFFF);
  static const Color neutralOffWhite = Color(0xFFFAFAFA);
  
  /// Semantic Colors
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningAmber = Color(0xFFFFA000);
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color infoBlue = Color(0xFF1976D2);
  static const Color disabledGray = Color(0xFFE0E0E0);
  
  /// Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF2E7D32),
    Color(0xFF4CAF50),
    Color(0xFF81C784),
  ];
  
  static const List<Color> sunsetGradient = [
    Color(0xFFFF9800),
    Color(0xFFFFC107),
    Color(0xFFFFE082),
  ];

  // ==============================================
  // 📐 DESIGN SYSTEM - SPACING
  // ==============================================
  /// Atomic spacing system (4px base)
  static const double spaceBase = 4.0;
  static const double spaceXs = spaceBase;      // 4px
  static const double spaceSm = spaceBase * 2;  // 8px
  static const double spaceMd = spaceBase * 4;  // 16px
  static const double spaceLg = spaceBase * 6;  // 24px
  static const double spaceXl = spaceBase * 8;  // 32px
  static const double spaceXxl = spaceBase * 12; // 48px
  static const double spaceXxxl = spaceBase * 16; // 64px
  
  /// App-specific spacing
  static const double screenPadding = spaceMd;
  static const double cardPadding = spaceMd;
  static const double buttonPaddingVertical = spaceSm;
  static const double buttonPaddingHorizontal = spaceLg;
  static const double inputFieldPadding = spaceMd;
  static const double listItemSpacing = spaceMd;
  static const double sectionSpacing = spaceXl;

  // ==============================================
  // 📐 DESIGN SYSTEM - BORDER RADIUS
  // ==============================================
  static const double borderRadiusNone = 0;
  static const double borderRadiusXs = 4.0;
  static const double borderRadiusSm = 8.0;
  static const double borderRadiusMd = 12.0;
  static const double borderRadiusLg = 16.0;
  static const double borderRadiusXl = 20.0;
  static const double borderRadiusXxl = 24.0;
  static const double borderRadiusCircle = 1000.0; // For circular shapes
  
  /// Component-specific border radius
  static const double buttonBorderRadius = borderRadiusMd;
  static const double cardBorderRadius = borderRadiusMd;
  static const double inputBorderRadius = borderRadiusSm;
  static const double avatarBorderRadius = borderRadiusCircle;
  static const double imageBorderRadius = borderRadiusMd;

  // ==============================================
  // 🖋️ DESIGN SYSTEM - TYPOGRAPHY
  // ==============================================
  /// Font Families
  static const String fontFamilyPrimary = 'Roboto';
  static const String fontFamilySecondary = 'Poppins';
  static const String fontFamilyMonospace = 'RobotoMono';
  
  /// Font Sizes (scaled)
  static const double fontSizeXs = 10.0;   // Captions, labels
  static const double fontSizeSm = 12.0;   // Small text, footnotes
  static const double fontSizeMd = 14.0;   // Body text
  static const double fontSizeLg = 16.0;   // Body large, buttons
  static const double fontSizeXl = 18.0;   // Subheadings
  static const double fontSizeXxl = 20.0;  // Headings
  static const double fontSizeXxxl = 24.0; // Large headings
  static const double fontSizeDisplaySm = 32.0;
  static const double fontSizeDisplayMd = 40.0;
  static const double fontSizeDisplayLg = 48.0;
  
  /// Font Weights
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;
  static const FontWeight fontWeightExtraBold = FontWeight.w800;
  
  /// Line Heights
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.8;

  // ==============================================
  // 🎨 DESIGN SYSTEM - ICONS
  // ==============================================
  static const double iconSizeXs = 12.0;
  static const double iconSizeSm = 16.0;
  static const double iconSizeMd = 24.0;
  static const double iconSizeLg = 32.0;
  static const double iconSizeXl = 40.0;
  static const double iconSizeXxl = 48.0;
  
  /// Navigation icons
  static const double bottomNavIconSize = 24.0;
  static const double appBarIconSize = 24.0;
  static const double buttonIconSize = 20.0;

  // ==============================================
  // 🎭 DESIGN SYSTEM - ELEVATION
  // ==============================================
  static const double elevationNone = 0;
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
  static const double elevationXhigh = 16.0;
  
  /// Component elevations
  static const double appBarElevation = elevationLow;
  static const double cardElevation = elevationLow;
  static const double buttonElevation = elevationLow;
  static const double dialogElevation = elevationHigh;
  static const double snackbarElevation = elevationMedium;

  // ==============================================
  // ⚡ ANIMATION & TRANSITIONS
  // ==============================================
  static const Duration animationDurationXs = Duration(milliseconds: 100);
  static const Duration animationDurationSm = Duration(milliseconds: 200);
  static const Duration animationDurationMd = Duration(milliseconds: 300);
  static const Duration animationDurationLg = Duration(milliseconds: 500);
  static const Duration animationDurationXl = Duration(milliseconds: 700);
  
  /// Curves
  static const Curve animationCurveLinear = Curves.linear;
  static const Curve animationCurveEase = Curves.easeInOut;
  static const Curve animationCurveFastOutSlowIn = Curves.fastOutSlowIn;
  static const Curve animationCurveDecelerate = Curves.decelerate;
  
  /// Page transitions
  static const Duration pageTransitionDuration = animationDurationMd;
  static const Curve pageTransitionCurve = Curves.fastOutSlowIn;
  
  /// Button animations
  static const Duration buttonPressDuration = animationDurationXs;
  static const Duration buttonHoverDuration = animationDurationSm;

  // ==============================================
  // 🌐 NETWORK & API CONFIGURATION
  // ==============================================
  /// API Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.hamikisan.com/v1',
  );
  
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration apiConnectTimeout = Duration(seconds: 10);
  static const Duration apiReceiveTimeout = Duration(seconds: 30);
  static const Duration apiSendTimeout = Duration(seconds: 10);
  
  static const int apiMaxRetries = 3;
  static const Duration apiRetryDelay = Duration(seconds: 1);
  
  /// API Endpoints
  static const String apiAuthLogin = '/auth/login';
  static const String apiAuthRegister = '/auth/register';
  static const String apiAuthLogout = '/auth/logout';
  static const String apiAuthRefresh = '/auth/refresh';
  static const String apiAuthVerify = '/auth/verify';
  
  static const String apiFarmers = '/farmers';
  static const String apiProducts = '/products';
  static const String apiMarketPrices = '/market-prices';
  static const String apiWeather = '/weather';
  static const String apiCommunityPosts = '/community/posts';
  static const String apiKisanDoctors = '/kisan-doctors';
  static const String apiAdmin = '/admin';
  
  /// Third-party APIs
  static const String weatherApiBaseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String marketApiBaseUrl = 'https://market.hamikisan.com/api';
  static const String kalimatiApiBaseUrl = 'https://kalimati.gov.np/api';
  
  /// Headers
  static const Map<String, String> apiHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Platform': 'flutter',
    'X-App-Version': appVersion,
  };

  // ==============================================
  // 💾 STORAGE & DATABASE
  // ==============================================
  /// Local Database
  static const String databaseName = 'hamikisan.db';
  static const int databaseVersion = 2;
  static const int databaseBackupCount = 3;
  
  /// Cache Configuration
  static const Duration cacheDurationShort = Duration(minutes: 5);
  static const Duration cacheDurationMedium = Duration(hours: 1);
  static const Duration cacheDurationLong = Duration(hours: 24);
  static const Duration cacheDurationPermanent = Duration(days: 7);
  
  static const int cacheMaxSizeMemory = 50; // MB
  static const int cacheMaxSizeDisk = 500; // MB
  
  /// Secure Storage Keys
  static const String secureKeyAuthToken = 'auth_token';
  static const String secureKeyRefreshToken = 'refresh_token';
  static const String secureKeyUserData = 'user_data';
  static const String secureKeyBiometricKey = 'biometric_key';
  static const String secureKeyEncryptionKey = 'encryption_key';
  
  /// Shared Preferences Keys
  static const String prefKeyThemeMode = 'theme_mode';
  static const String prefKeyLocale = 'locale';
  static const String prefKeyNotifications = 'notifications_enabled';
  static const String prefKeyBiometrics = 'biometrics_enabled';
  static const String prefKeyFirstLaunch = 'first_launch';
  static const String prefKeyAnalytics = 'analytics_enabled';

  // ==============================================
  // 🔐 SECURITY & AUTHENTICATION
  // ==============================================
  static const int passwordMinLength = 8;
  static const int passwordMaxLength = 128;
  static const int otpLength = 6;
  static const Duration otpValidityDuration = Duration(minutes: 10);
  
  /// Session Management
  static const Duration sessionDuration = Duration(hours: 24);
  static const Duration refreshTokenDuration = Duration(days: 7);
  static const Duration sessionInactivityTimeout = Duration(minutes: 30);
  
  /// Encryption
  static const String encryptionAlgorithm = 'AES-256-GCM';
  static const int encryptionKeySize = 32; // 256 bits
  static const int encryptionIvSize = 12; // 96 bits for GCM
  
  /// Rate Limiting
  static const int rateLimitLoginAttempts = 5;
  static const Duration rateLimitLoginWindow = Duration(minutes: 15);
  static const int rateLimitApiRequests = 100;
  static const Duration rateLimitApiWindow = Duration(minutes: 1);

  // ==============================================
  // 📱 APP CONFIGURATION
  // ==============================================
  /// Feature Flags
  static const bool enableDebugLogging = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashlytics = true;
  static const bool enablePerformanceMonitoring = true;
  static const bool enableBiometricAuth = true;
  static const bool enableOfflineMode = true;
  static const bool enablePushNotifications = true;
  static const bool enableDarkMode = true;
  
  /// Performance
  static const int imageCacheSize = 100; // Number of images
  static const int listPageSize = 20;
  static const int searchDebounceMs = 300;
  static const int autoSaveIntervalMs = 5000;
  
  /// File Upload Limits
  static const int maxImageSizeBytes = 10 * 1024 * 1024; // 10MB
  static const int maxVideoSizeBytes = 50 * 1024 * 1024; // 50MB
  static const int maxDocumentSizeBytes = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  static const List<String> allowedVideoTypes = ['mp4', 'mov', 'avi'];
  
  /// Validation Limits
  static const int maxNameLength = 100;
  static const int maxEmailLength = 254;
  static const int maxPhoneLength = 15;
  static const int maxAddressLength = 200;
  static const int maxBioLength = 500;
  static const int maxProductTitleLength = 100;
  static const int maxProductDescriptionLength = 1000;
  static const int maxPostContentLength = 5000;
  static const int maxCommentLength = 1000;

  // ==============================================
  // 🚦 APP ROUTES & NAVIGATION
  // ==============================================
  /// Authentication Routes
  static const String routeSplash = '/splash';
  static const String routeOnboarding = '/onboarding';
  static const String routeLogin = '/auth/login';
  static const String routeRegister = '/auth/register';
  static const String routeForgotPassword = '/auth/forgot-password';
  static const String routeVerifyOtp = '/auth/verify-otp';
  static const String routeResetPassword = '/auth/reset-password';
  static const String routeAdminLogin = '/auth/admin-login';
  
  /// Main App Routes
  static const String routeHome = '/home';
  static const String routeFarmerDashboard = '/dashboard/farmer';
  static const String routeDoctorDashboard = '/dashboard/doctor';
  static const String routeAdminDashboard = '/dashboard/admin';
  
  /// Feature Routes
  static const String routeMarketplace = '/marketplace';
  static const String routeMarketplaceSell = '/marketplace/sell';
  static const String routeMarketplaceProduct = '/marketplace/product';
  static const String routeMarketplaceCart = '/marketplace/cart';
  static const String routeMarketplaceOrders = '/marketplace/orders';
  
  static const String routeWeather = '/weather';
  static const String routeWeatherDetail = '/weather/detail';
  
  static const String routeMarketPrices = '/market-prices';
  static const String routeMarketPricesDetail = '/market-prices/detail';
  
  static const String routeCommunity = '/community';
  static const String routeCommunityCreate = '/community/create';
  static const String routeCommunityPost = '/community/post';
  static const String routeCommunityProfile = '/community/profile';
  
  static const String routeKisanDoctors = '/kisan-doctors';
  static const String routeDoctorProfile = '/kisan-doctors/profile';
  static const String routeDoctorConsultation = '/kisan-doctors/consultation';
  static const String routeDoctorAppointments = '/kisan-doctors/appointments';
  
  static const String routeTools = '/tools';
  static const String routeLearning = '/learning';
  static const String routeGovernmentSchemes = '/government-schemes';
  static const String routeInsuranceCalculator = '/insurance-calculator';
  
  /// Settings Routes
  static const String routeProfile = '/profile';
  static const String routeProfileEdit = '/profile/edit';
  static const String routeSettings = '/settings';
  static const String routeNotifications = '/notifications';
  static const String routeLanguage = '/language';
  static const String routeHelp = '/help';
  static const String routeAbout = '/about';
  
  /// Admin Routes
  static const String routeAdminUsers = '/admin/users';
  static const String routeAdminFarmers = '/admin/farmers';
  static const String routeAdminDoctors = '/admin/doctors';
  static const String routeAdminProducts = '/admin/products';
  static const String routeAdminPosts = '/admin/posts';
  static const String routeAdminAnalytics = '/admin/analytics';
  static const String routeAdminSettings = '/admin/settings';

  // ==============================================
  // 👥 USER ROLES & PERMISSIONS
  // ==============================================
  static const String roleFarmer = 'farmer';
  static const String roleKisanDoctor = 'kisan_doctor';
  static const String roleKisanAdmin = 'kisan_admin';
  static const String roleSuperAdmin = 'super_admin';
  static const String roleSystemAdmin = 'system_admin';
  
  /// Permission Groups
  static const List<String> permissionsFarmer = [
    'view_marketplace',
    'sell_products',
    'create_posts',
    'view_weather',
    'view_market_prices',
    'consult_doctors',
    'view_learning',
    'use_tools',
  ];
  
  static const List<String> permissionsKisanDoctor = [
    ...permissionsFarmer,
    'answer_questions',
    'schedule_appointments',
    'video_consultations',
    'manage_cases',
  ];
  
  static const List<String> permissionsKisanAdmin = [
    ...permissionsKisanDoctor,
    'manage_farmers',
    'manage_products',
    'manage_posts',
    'send_notifications',
    'view_analytics',
  ];
  
  static const List<String> permissionsSuperAdmin = [
    ...permissionsKisanAdmin,
    'manage_doctors',
    'manage_admins',
    'system_configuration',
    'database_management',
    'security_management',
  ];

  // ==============================================
  // 🏷️ CATEGORIES & TAXONOMY
  // ==============================================
  /// Product Categories
  static const Map<String, String> productCategories = {
    'vegetables': 'Vegetables',
    'fruits': 'Fruits',
    'grains': 'Grains & Cereals',
    'spices': 'Spices',
    'dairy': 'Dairy Products',
    'livestock': 'Livestock',
    'poultry': 'Poultry',
    'fish': 'Fish & Seafood',
    'fertilizers': 'Fertilizers',
    'seeds': 'Seeds & Seedlings',
    'tools': 'Farming Tools',
    'machinery': 'Machinery & Equipment',
    'other': 'Other',
  };
  
  /// Crop Types
  static const Map<String, String> cropTypes = {
    'rice': 'Rice',
    'wheat': 'Wheat',
    'maize': 'Maize',
    'millet': 'Millet',
    'barley': 'Barley',
    'potato': 'Potato',
    'tomato': 'Tomato',
    'onion': 'Onion',
    'garlic': 'Garlic',
    'ginger': 'Ginger',
    'tea': 'Tea',
    'coffee': 'Coffee',
    'sugarcane': 'Sugarcane',
    'cotton': 'Cotton',
    'tobacco': 'Tobacco',
  };
  
  /// Post Categories
  static const Map<String, String> postCategories = {
    'question': 'Question',
    'tip': 'Farming Tip',
    'story': 'Success Story',
    'alert': 'Alert',
    'event': 'Event',
    'news': 'News',
    'discussion': 'Discussion',
    'help': 'Help Wanted',
  };

  // ==============================================
  // 📏 UNITS & MEASUREMENTS
  // ==============================================
  static const Map<String, String> measurementUnits = {
    'kg': 'किलोग्राम',
    'g': 'ग्राम',
    'l': 'लीटर',
    'ml': 'मिलिलीटर',
    'piece': 'गोटा',
    'dozen': 'दर्जन',
    'bundle': 'बन्डल',
    'sack': 'बोरा',
    'acre': 'एकड',
    'hectare': 'हेक्टर',
    'ropani': 'रोपनी',
    'anna': 'आना',
    'paisa': 'पैसा',
    'dam': 'डम',
  };
  
  static const Map<String, String> currencyUnits = {
    'npr': 'रुपैयाँ',
    'usd': 'डलर',
    'inr': 'रुपिया',
  };

  // ==============================================
  // 🌤️ WEATHER & CLIMATE
  // ==============================================
  static const Map<String, String> weatherConditions = {
    'clear': 'Clear',
    'partly_cloudy': 'Partly Cloudy',
    'cloudy': 'Cloudy',
    'rain': 'Rain',
    'heavy_rain': 'Heavy Rain',
    'thunderstorm': 'Thunderstorm',
    'snow': 'Snow',
    'fog': 'Fog',
    'windy': 'Windy',
    'hail': 'Hail',
  };
  
  static const Map<String, String> weatherIcons = {
    'clear': '☀️',
    'partly_cloudy': '⛅',
    'cloudy': '☁️',
    'rain': '🌧️',
    'heavy_rain': '⛈️',
    'thunderstorm': '⚡',
    'snow': '❄️',
    'fog': '🌫️',
    'windy': '💨',
    'hail': '🌨️',
  };
  
  static const Map<String, String> seasons = {
    'spring': 'Spring',
    'summer': 'Summer',
    'monsoon': 'Monsoon',
    'autumn': 'Autumn',
    'winter': 'Winter',
  };

  // ==============================================
  // 📍 LOCATIONS & REGIONS
  // ==============================================
  static const Map<String, String> nepaleseProvinces = {
    '1': 'Province 1',
    '2': 'Madhesh Province',
    '3': 'Bagmati Province',
    '4': 'Gandaki Province',
    '5': 'Lumbini Province',
    '6': 'Karnali Province',
    '7': 'Sudurpashchim Province',
  };
  
  static const List<String> majorDistricts = [
    'Kathmandu',
    'Lalitpur',
    'Bhaktapur',
    'Pokhara',
    'Chitwan',
    'Biratnagar',
    'Butwal',
    'Bharatpur',
    'Dharan',
    'Hetauda',
    'Janakpur',
    'Nepalgunj',
    'Itahari',
    'Dhading',
    'Kavre',
    'Sindhuli',
  ];

  // ==============================================
  // 🔔 NOTIFICATIONS & ALERTS
  // ==============================================
  static const Map<String, String> notificationTypes = {
    'price_alert': 'Price Alert',
    'market_update': 'Market Update',
    'weather_alert': 'Weather Alert',
    'new_message': 'New Message',
    'doctor_reply': 'Doctor Reply',
    'order_update': 'Order Update',
    'post_comment': 'Post Comment',
    'system': 'System Notification',
  };
  
  static const Duration notificationDisplayDuration = Duration(seconds: 4);
  static const int maxNotificationsDisplayed = 10;

  // ==============================================
  // 🎯 ERROR & SUCCESS MESSAGES
  // ==============================================
  /// Error Messages
  static const Map<String, String> errorMessages = {
    'network_error': 'Network error. Please check your internet connection.',
    'server_error': 'Server error. Please try again later.',
    'timeout_error': 'Request timeout. Please check your connection.',
    'unauthorized': 'Session expired. Please login again.',
    'forbidden': 'You do not have permission to perform this action.',
    'not_found': 'The requested resource was not found.',
    'validation_error': 'Please check your input and try again.',
    'unknown_error': 'An unexpected error occurred. Please try again.',
  };
  
  /// Success Messages
  static const Map<String, String> successMessages = {
    'login_success': 'Login successful!',
    'register_success': 'Registration successful!',
    'logout_success': 'Logout successful!',
    'password_reset_success': 'Password reset successful!',
    'profile_update_success': 'Profile updated successfully!',
    'product_posted_success': 'Product posted successfully!',
    'order_placed_success': 'Order placed successfully!',
    'post_created_success': 'Post created successfully!',
  };
  
  /// Warning Messages
  static const Map<String, String> warningMessages = {
    'password_mismatch': 'Passwords do not match.',
    'email_exists': 'Email already exists.',
    'phone_exists': 'Phone number already registered.',
    'weak_password': 'Password should be at least 8 characters with letters and numbers.',
    'invalid_email': 'Please enter a valid email address.',
    'invalid_phone': 'Please enter a valid phone number.',
  };

  // ==============================================
  // 🎮 APP-SPECIFIC CONSTANTS
  // ==============================================
  /// Marketplace
  static const int marketplaceMaxImages = 5;
  static const Duration marketplaceAutoRefresh = Duration(minutes: 5);
  static const double marketplaceCommissionRate = 0.05; // 5%
  
  /// Community
  static const int communityMaxHashtags = 5;
  static const int communityMaxImages = 10;
  static const Duration communityPostEditWindow = Duration(hours: 1);
  
  /// Kisan Doctors
  static const int doctorMaxSpecializations = 3;
  static const Duration consultationDuration = Duration(minutes: 30);
  static const double doctorMinRating = 4.0;
  
  /// Weather
  static const Duration weatherUpdateInterval = Duration(minutes: 15);
  static const int weatherForecastDays = 7;
  
  /// Market Prices
  static const Duration marketPriceUpdateInterval = Duration(hours: 1);
  static const int marketPriceHistoryDays = 30;

  // ==============================================
  // 🧪 TESTING & DEVELOPMENT
  // ==============================================
  static const bool isDebugMode = bool.fromEnvironment('dart.vm.product') == false;
  static const bool isProfileMode = bool.fromEnvironment('dart.vm.profile') == true;
  static const bool isReleaseMode = bool.fromEnvironment('dart.vm.product') == true;
  
  /// Mock Data Configuration
  static const bool useMockData = bool.fromEnvironment('USE_MOCK_DATA', defaultValue: false);
  static const bool enableMockApi = bool.fromEnvironment('ENABLE_MOCK_API', defaultValue: false);
  
  /// Development Overrides
  static const bool skipSplash = true;
  static const bool skipOnboarding = bool.fromEnvironment('SKIP_ONBOARDING', defaultValue: false);
  static const bool autoLogin = bool.fromEnvironment('AUTO_LOGIN', defaultValue: false);
  
  /// Demo Credentials (Only for development)
  static const Map<String, dynamic> demoCredentials = {
    'farmer': {
      'phone': '9812345678',
      'password': 'Farmer123',
      'name': 'Demo Farmer',
    },
    'doctor': {
      'phone': '9812345679',
      'password': 'Doctor123',
      'name': 'Demo Doctor',
    },
    'admin': {
      'phone': '9812345680',
      'password': 'Admin923',
      'name': 'Demo Admin',
    },
  };

  // ==============================================
  // 📦 ASSET PATHS
  // ==============================================
  /// Images
  static const String assetLogo = 'assets/images/logo.png';
  static const String assetLogoWhite = 'assets/images/logo_white.png';
  static const String assetLogoIcon = 'assets/images/logo_icon.png';
  static const String assetSplash = 'assets/images/splash.png';
  static const String assetOnboarding1 = 'assets/images/onboarding_1.png';
  static const String assetOnboarding2 = 'assets/images/onboarding_2.png';
  static const String assetOnboarding3 = 'assets/images/onboarding_3.png';
  static const String assetPlaceholder = 'assets/images/placeholder.png';
  static const String assetNoImage = 'assets/images/no_image.png';
  static const String assetNoData = 'assets/images/no_data.png';
  static const String assetError = 'assets/images/error.png';
  
  /// Icons
  static const String iconHome = 'assets/icons/home.svg';
  static const String iconMarketplace = 'assets/icons/marketplace.svg';
  static const String iconWeather = 'assets/icons/weather.svg';
  static const String iconCommunity = 'assets/icons/community.svg';
  static const String iconDoctors = 'assets/icons/doctors.svg';
  static const String iconProfile = 'assets/icons/profile.svg';
  static const String iconNotification = 'assets/icons/notification.svg';
  static const String iconSearch = 'assets/icons/search.svg';
  static const String iconFilter = 'assets/icons/filter.svg';
  static const String iconCamera = 'assets/icons/camera.svg';
  static const String iconGallery = 'assets/icons/gallery.svg';
  
  /// Animations
  static const String animLoading = 'assets/animations/loading.json';
  static const String animSuccess = 'assets/animations/success.json';
  static const String animError = 'assets/animations/error.json';
  static const String animEmpty = 'assets/animations/empty.json';
  
  /// Fonts
  static const String fontRoboto = 'assets/fonts/Roboto-Regular.ttf';
  static const String fontRobotoBold = 'assets/fonts/Roboto-Bold.ttf';
  static const String fontPoppins = 'assets/fonts/Poppins-Regular.ttf';
  static const String fontPoppinsBold = 'assets/fonts/Poppins-Bold.ttf';

  // ==============================================
  // 🌍 LOCALIZATION & INTERNATIONALIZATION
  // ==============================================
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'ne', 'name': 'नेपाली', 'nativeName': 'नेपाली'},
    {'code': 'en', 'name': 'English', 'nativeName': 'English'},
    {'code': 'hi', 'name': 'Hindi', 'nativeName': 'हिन्दी'},
    {'code': 'mr', 'name': 'Marathi', 'nativeName': 'मराठी'},
  ];
  
  static const String defaultLocale = 'ne';
  static const String fallbackLocale = 'en';

  // ==============================================
  // 📱 PLATFORM-SPECIFIC CONFIGURATION
  // ==============================================
  /// Android Configuration
  static const Map<String, dynamic> androidConfig = {
    'minSdkVersion': 21,
    'targetSdkVersion': 33,
    'compileSdkVersion': 33,
    'versionCode': 200,
    'versionName': appVersion,
    'applicationId': appPackage,
    'enableMultidex': true,
    'usesCleartextTraffic': false,
    'backupEnabled': false,
  };
  
  /// iOS Configuration
  static const Map<String, dynamic> iosConfig = {
    'deploymentTarget': '11.0',
    'usesNonExemptEncryption': false,
    'requiresFullScreen': false,
    'supportsTablet': true,
  };

  // ==============================================
  // 🛠️ UTILITY METHODS
  // ==============================================
  /// Get platform-specific configuration
  static Map<String, dynamic> getPlatformConfig() {
    if (kIsWeb) return {};
    if (Platform.isAndroid) return androidConfig;
    if (Platform.isIOS) return iosConfig;
    return {};
  }
  
  /// Check if running on mobile
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;
  
  /// Check if running on web
  static bool get isWeb => !isMobile;
  
  /// Get environment-specific API URL
  static String getApiUrl(String endpoint) {
    const baseUrl = apiBaseUrl;
    return '$baseUrl$endpoint';
  }
  
  /// Format currency
  static String formatCurrency(double amount, {String currency = 'npr'}) {
    final normalizedCurrency = currency.toLowerCase();
    final symbol = normalizedCurrency == 'npr'
        ? 'रु'
        : (currencyUnits[normalizedCurrency] ??
            normalizedCurrency.toUpperCase());
    return '$symbol ${amount.toStringAsFixed(2)}';
  }
  
  /// Get product category name
  static String getProductCategory(String categoryId) {
    return productCategories[categoryId] ?? 'Other';
  }
  
  /// Get weather icon
  static String getWeatherIcon(String condition) {
    return weatherIcons[condition] ?? '☀️';
  }
  
  /// Get measurement unit
  static String getMeasurementUnit(String unitId) {
    return measurementUnits[unitId] ?? 'kg';
  }
  
  /// Validate email
  static bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }
  
  /// Validate Nepali phone number
  static bool isValidNepaliPhone(String phone) {
    return RegExp(r'^9[78]\d{8}$').hasMatch(phone);
  }
  
  /// Calculate password strength
  static double calculatePasswordStrength(String password) {
    double strength = 0;
    
    if (password.length >= 8) strength += 0.2;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[a-z]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 0.2;
    
    return strength;
  }
}

/// Platform class for platform detection
class Platform {
  static bool get isAndroid => false;
  static bool get isIOS => false;
  static bool get isWeb => true;
}

/// Extension methods for easier access to constants
extension AppConstantsExtensions on BuildContext {
  /// Quick access to theme colors
  Color get primaryColor => AppConstants.primaryGreen;
  Color get secondaryColor => AppConstants.secondaryGold;
  Color get backgroundColor => AppConstants.neutralOffWhite;
  
  /// Quick access to spacing
  double get smallSpacing => AppConstants.spaceSm;
  double get mediumSpacing => AppConstants.spaceMd;
  double get largeSpacing => AppConstants.spaceLg;
  
  /// Quick access to typography
  TextStyle get bodyText => const TextStyle(
    fontSize: AppConstants.fontSizeMd,
    fontWeight: AppConstants.fontWeightRegular,
    fontFamily: AppConstants.fontFamilyPrimary,
  );
  
  TextStyle get titleText => const TextStyle(
    fontSize: AppConstants.fontSizeXxl,
    fontWeight: AppConstants.fontWeightBold,
    fontFamily: AppConstants.fontFamilySecondary,
  );
  
  /// Responsive helpers
  bool get isMobile => MediaQuery.of(this).size.width < 600;
  bool get isTablet => MediaQuery.of(this).size.width >= 600 && 
                      MediaQuery.of(this).size.width < 1200;
  bool get isDesktop => MediaQuery.of(this).size.width >= 1200;
}

/// Environment-specific constants
class EnvironmentConfig {
  static const String flavor = String.fromEnvironment('FLAVOR', defaultValue: 'development');
  
  static bool get isDevelopment => flavor == 'development';
  static bool get isStaging => flavor == 'staging';
  static bool get isProduction => flavor == 'production';
  
  static String get apiBaseUrl {
    switch (flavor) {
      case 'development':
        return 'http://localhost:3000/api/v1';
      case 'staging':
        return 'https://staging-api.hamikisan.com/v1';
      case 'production':
        return 'https://api.hamikisan.com/v1';
      default:
        return 'http://localhost:3000/api/v1';
    }
  }
  
  static Map<String, dynamic> get firebaseConfig {
    switch (flavor) {
      case 'development':
        return {
          'apiKey': 'AIzaSy...dev',
          'authDomain': 'hamikisan-dev.firebaseapp.com',
          'projectId': 'hamikisan-dev',
        };
      case 'production':
        return {
          'apiKey': 'AIzaSy...prod',
          'authDomain': 'hamikisan-prod.firebaseapp.com',
          'projectId': 'hamikisan-prod',
        };
      default:
        return {};
    }
  }
}

/// Example usage:
/// 
/// ```dart
/// // Accessing constants
/// Text(
///   'Welcome to ${AppConstants.appName}',
///   style: TextStyle(
///     color: AppConstants.primaryGreen,
///     fontSize: AppConstants.fontSizeXl,
///   ),
/// );
/// 
/// // Using spacing
/// SizedBox(height: AppConstants.spaceMd),
/// 
/// // Using routes
/// Navigator.pushNamed(context, AppConstants.routeMarketplace);
/// 
/// // Using utility methods
/// if (AppConstants.isValidEmail(email)) {
///   // Valid email
/// }
/// 
/// // Environment-specific
/// if (EnvironmentConfig.isProduction) {
///   // Production-specific logic
/// }
/// ```
