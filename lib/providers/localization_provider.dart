import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationProvider with ChangeNotifier {
  String _currentLanguage = 'English';

  String get currentLanguage => _currentLanguage;
  bool get isNepali => _currentLanguage == 'Nepali';
  bool get isEnglish => _currentLanguage == 'English';

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('app_language') ?? 'English';
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    if (language != _currentLanguage) {
      _currentLanguage = language;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_language', language);
      notifyListeners();
    }
  }

  String translate(String key) {
    return _translations[_currentLanguage]?[key] ?? key;
  }

  // Comprehensive translation dictionary
  static final Map<String, Map<String, String>> _translations = {
    'English': {
      // App Name
      'app_name': 'HamiKisan',
      'app_tagline': 'Together We Farm',

      // Navigation
      'home': 'Home',
      'marketplace': 'Marketplace',
      'community': 'Community',
      'learn': 'Learn',
      'profile': 'Profile',

      // Common
      'continue': 'Continue',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'submit': 'Submit',
      'search': 'Search',
      'filter': 'Filter',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'yes': 'Yes',
      'no': 'No',
      'ok': 'OK',
      'close': 'Close',

      // Language Selection
      'choose_language': 'Choose Your Language',
      'select_language': 'Select Language',
      'language': 'Language',
      'english': 'English',
      'nepali': 'नेपाली',

      // Authentication & Profile - Standard Terms
      'login': 'Login',
      'register': 'Register',
      'logout': 'Logout',
      'username': 'Username',
      'password': 'Password',
      'confirm_password': 'Confirm Password',
      'forgot_password': 'Forgot Password?',
      'remember_me': 'Remember Me',
      'sign_in': 'Sign In',
      'sign_up': 'Sign Up',
      'create_account': 'Create Account',
      'already_have_account': 'Already have an account?',
      'dont_have_account': "Don't have an account?",
      'reset_password': 'Reset Password',

      // Agriculture Specific Input Fields
      'kisan_id': 'Kisan ID',
      'phone_number': 'Mobile Number',
      'full_name': 'Full Name',
      'farm_type': 'Farm Type',
      'land_area': 'Land Area (Ropani/Bigha)',
      
      // Location Structure
      'province': 'Province',
      'district': 'District',
      'local_level': 'Local Level (Municipality/Rural)',
      'ward_no': 'Ward No.',
      'address': 'Address',

      // Hints & Placeholders
      'enter_phone_number': 'Enter your mobile number',
      'enter_password': 'Enter your password',
      'enter_name': 'Enter your full name',
      'enter_kisan_id': 'Enter your Kisan ID (Optional)',
      'select_province': 'Select Province',
      'select_district': 'Select District',
      'select_local_level': 'Select Local Level',
      'enter_ward': 'Enter Ward No.',
      'farming_category_hint': 'e.g. Vegetables, Livestock, Grains',

      // Roles
      'select_role': 'Select your role',
      'farmer': 'Farmer',
      'kisan_doctor': 'Kisan Doctor',
      'admin': 'Admin',
      'super_admin': 'Super Admin',
      'farmer_desc': 'Access farming tools & market',
      'doctor_desc': 'Provide expert consultation',
      'login_as': 'Login as:',

      // Validation & Messages
      'required_field': 'This field is required',
      'invalid_phone': 'Invalid mobile number',
      'password_too_short': 'Password must be at least 6 characters',
      'password_mismatch': 'Passwords do not match',
      'fill_all_fields': 'Please fill all required fields',
      'welcome': 'Welcome',
      'welcome_back': 'Welcome Back',
      'please_login': 'Please log in to continue',
      'registration_successful': 'Registration Successful',
      'login_successful': 'Login Successful',
      'logout_successful': 'Logout Successful',
      'click_to_register': 'Click here to register',
      'tap_to_use': 'Tap to use',
      'demo_accounts': 'Demo Accounts',
      'warning_attempts': 'Warning: {attempts} attempts remaining',
      'password_hint': 'Min 8 chars with letters & numbers',

      // Marketplace & Other Features
      'buy': 'Buy',
      'sell': 'Sell',
      'price': 'Price',
      'quantity': 'Quantity',
      'description': 'Description',
      'category': 'Category',
      'my_products': 'My Products',
      'add_product': 'Add Product',
      
      // Weather
      'temperature': 'Temperature',
      'forecast': 'Forecast',
      'today_weather': "Today's Weather",
      
      // Community
      'post': 'Post',
      'comment': 'Comment',
      'like': 'Like',
      'share': 'Share',
      'no_posts_yet': 'No posts yet',
      
      // Doctor
      'consult': 'Consult',
      'ai_diagnosis': 'AI Diagnosis',
      'find_doctor': 'Find Doctor',
    },
    'Nepali': {
      // App Name
      'app_name': 'हामीकिसान',
      'app_tagline': 'सँगै हामी खेती गर्छौं',

      // Navigation
      'home': 'गृहपृष्ठ',
      'marketplace': 'बजार',
      'community': 'समुदाय',
      'learn': 'सिक्नुहोस्',
      'profile': 'प्रोफाइल',

      // Common
      'continue': 'जारी राख्नुहोस्',
      'cancel': 'रद्द गर्नुहोस्',
      'save': 'सुरक्षित गर्नुहोस्',
      'delete': 'मेटाउनुहोस्',
      'edit': 'सम्पादन गर्नुहोस्',
      'submit': 'पेश गर्नुहोस्',
      'search': 'खोज्नुहोस्',
      'filter': 'फिल्टर',
      'loading': 'लोड हुँदैछ...',
      'error': 'त्रुटि',
      'success': 'सफल',
      'yes': 'हो',
      'no': 'होइन',
      'ok': 'ठीक छ',
      'close': 'बन्द गर्नुहोस्',

      // Language Selection
      'choose_language': 'आफ्नो भाषा छान्नुहोस्',
      'select_language': 'भाषा छान्नुहोस्',
      'language': 'भाषा',
      'english': 'English',
      'nepali': 'नेपाली',

      // Authentication & Profile - Professional Terms
      'login': 'लगइन / प्रवेश गर्नुहोस्',
      'register': 'दर्ता गर्नुहोस्',
      'logout': 'बाहिरिनुहोस्',
      'username': 'प्रयोगकर्ताको नाम',
      'password': 'पासवर्ड / गोप्य शब्द',
      'confirm_password': 'पासवर्ड पुष्टि गर्नुहोस्',
      'forgot_password': 'पासवर्ड बिर्सनुभयो?',
      'remember_me': 'मलाई सम्झनुहोस्',
      'sign_in': 'साइन इन गर्नुहोस्',
      'sign_up': 'साइन अप गर्नुहोस्',
      'create_account': 'खाता सिर्जना गर्नुहोस्',
      'already_have_account': 'पहिले नै खाता छ?',
      'dont_have_account': 'खाता छैन?',
      'reset_password': 'पासवर्ड रिसेट गर्नुहोस्',

      // Agriculture Specific Input Fields
      'kisan_id': 'किसान परिचयपत्र नं.',
      'phone_number': 'मोबाइल नम्बर',
      'full_name': 'पूरा नाम',
      'farm_type': 'कृषि फार्मको प्रकार',
      'land_area': 'जग्गाको क्षेत्रफल (रोपनी/विघा)',
      
      // Location Structure
      'province': 'प्रदेश',
      'district': 'जिल्ला',
      'local_level': 'स्थानीय तह',
      'ward_no': 'वडा नं.',
      'address': 'ठेगाना',

      // Hints & Placeholders
      'enter_phone_number': 'तपाईंको मोबाइल नम्बर राख्नुहोस्',
      'enter_password': 'तपाईंको पासवर्ड राख्नुहोस्',
      'enter_name': 'तपाईंको पूरा नाम राख्नुहोस्',
      'enter_kisan_id': 'तपाईंको किसान परिचयपत्र नं. (वैकल्पिक)',
      'select_province': 'प्रदेश छान्नुहोस्',
      'select_district': 'जिल्ला छान्नुहोस्',
      'select_local_level': 'स्थानीय तह छान्नुहोस्',
      'enter_ward': 'वडा नं. राख्नुहोस्',
      'farming_category_hint': 'जस्तै: तरकारी, पशुपालन, अन्न',
      'password_hint': 'कम्तिमा ८ अक्षर (अक्षर र अंक सहित)',

      // Roles
      'select_role': 'आफ्नो भूमिका छान्नुहोस्',
      'farmer': 'किसान',
      'kisan_doctor': 'किसान डाक्टर',
      'admin': 'प्रशासक',
      'super_admin': 'सुपर प्रशासक',
      'farmer_desc': 'कृषि औजार र बजार पहुँच',
      'doctor_desc': 'विशेषज्ञ परामर्श सेवा',
      'login_as': 'यसरी लगइन गर्नुहोस्:',

      // Validation & Messages (Polite Form)
      'required_field': 'यो विवरण अनिवार्य छ',
      'invalid_phone': 'अमान्य मोबाइल नम्बर',
      'password_too_short': 'पासवर्ड कम्तिमा ६ अक्षरको हुनुपर्छ',
      'password_mismatch': 'पासवर्डहरू मेल खाँदैनन्',
      'fill_all_fields': 'कृपया सबै अनिवार्य विवरणहरू भर्नुहोस्',
      'welcome': 'स्वागत छ',
      'welcome_back': 'फेरि स्वागत छ',
      'please_login': 'कृपया अगाडि बढ्न लगइन गर्नुहोस्',
      'registration_successful': 'दर्ता सफल भयो',
      'login_successful': 'लगइन सफल भयो',
      'logout_successful': 'लगआउट सफल भयो',
      'click_to_register': 'दर्ता गर्न यहाँ क्लिक गर्नुहोस्',
      'tap_to_use': 'प्रयोग गर्न थिच्नुहोस्',
      'demo_accounts': 'डेमो खाताहरू',
      'warning_attempts': 'चेतावनी: {attempts} प्रयासहरू बाँकी छन्',

      // Marketplace & Other Features
      'buy': 'किन्नुहोस्',
      'sell': 'बेच्नुहोस्',
      'price': 'मूल्य',
      'quantity': 'परिमाण',
      'description': 'विवरण',
      'category': 'वर्ग',
      'my_products': 'मेरा उत्पादनहरू',
      'add_product': 'उत्पादन थप्नुहोस्',
      
      // Weather
      'temperature': 'तापक्रम',
      'forecast': 'पूर्वानुमान',
      'today_weather': 'आजको मौसम',
      
      // Community
      'post': 'पोस्ट',
      'comment': 'टिप्पणी',
      'like': 'मन पराउनुहोस्',
      'share': 'साझा गर्नुहोस्',
      'no_posts_yet': 'कुनै पोस्ट छैन',
      
      // Doctor
      'consult': 'परामर्श',
      'ai_diagnosis': 'AI निदान',
      'find_doctor': 'डाक्टर खोज्नुहोस्',
    },
  };
}
