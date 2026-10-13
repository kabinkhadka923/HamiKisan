import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import '../models/user.dart';
import 'dart:convert';
import '../utils/logger.dart';

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
      Logger.debug('Web user session stored', tag: 'Auth');
    } catch (e) {
      Logger.error('Could not store web user session', tag: 'Auth', error: e);
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
      Logger.error('Could not read web user session', tag: 'Auth', error: e);
      return null;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
    } catch (e) {
      Logger.error('Could not clear web user session', tag: 'Auth', error: e);
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

      Logger.debug('Emergency admin created for debug use', tag: 'Auth');
    } catch (e) {
      Logger.error('Could not create emergency admin', tag: 'Auth', error: e);
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
