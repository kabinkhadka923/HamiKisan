import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import '../models/user.dart';
import 'dart:convert';

class WebAuthService {
  static final WebAuthService _instance = WebAuthService._internal();
  factory WebAuthService() => _instance;
  WebAuthService._internal();

  static const String _sessionKey = 'hami_kisan_web_session';
  static const String _emergencyAdminKey = 'emergency_admin_data';

  // Store current user in SharedPreferences for web
  Future<void> storeCurrentUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionKey, json.encode(user.toJson()));
      print('[AUTH] Session stored in SharedPreferences for web');
    } catch (e) {
      print('[AUTH] Error storing current user: $e');
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_sessionKey);
      if (userData != null) {
        return User.fromJson(json.decode(userData));
      }
      return null;
    } catch (e) {
      print('[AUTH] Error getting current user: $e');
      return null;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
    } catch (e) {
      print('[AUTH] Error during logout: $e');
    }
  }

  // Emergency reset for web - creates user in SharedPreferences directly
  Future<void> _emergencyCreateAdmin() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      const adminUsername = 'HamiSuperKisan';
      const adminPassword = '@PhulasiPokhari923.';

      // Store admin data for bypass login
      final adminData = {
        'username': adminUsername,
        'password': adminPassword,
        'role': 'superAdmin',
        'name': 'Emergency Admin',
        'id': 'emergency_super_admin'
      };

      await prefs.setString(_emergencyAdminKey, json.encode(adminData));

      print('================================================');
      print('[SECURITY] Emergency admin created in SharedPreferences');
      print('[SECURITY] THIS IS FOR DEBUGGING ONLY');
      print('================================================');
    } catch (e) {
      print('[AUTH] Error creating emergency admin: $e');
    }
  }

  // Wrapper for public use with debug check
  Future<void> emergencyCreateAdmin() async {
    // Already checked in main.dart but keeping as a second layer
    if (kDebugMode) {
      await _emergencyCreateAdmin();
    }
  }

  Future<Map<String, dynamic>?> getEmergencyAdmin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_emergencyAdminKey);
      if (data != null) {
        return json.decode(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
