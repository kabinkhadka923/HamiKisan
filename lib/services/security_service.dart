import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/security_utils.dart';

class SecurityService {
  static const String _sessionKey = 'secure_session';
  static const String _securityLogKey = 'security_logs';
  static const Duration sessionTimeout = Duration(hours: 2);

  // Session Management
  static Future<String> createSecureSession(String userId) async {
    final sessionId = SecurityUtils.generateSessionId();
    final sessionData = {
      'sessionId': sessionId,
      'userId': userId,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'lastActivity': DateTime.now().millisecondsSinceEpoch,
      'ipAddress': 'localhost', // In production, get real IP
      'userAgent': 'HamiKisan-App',
    };

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, json.encode(sessionData));
    
    SecurityUtils.logSecurityEvent('SESSION_CREATED', userId, {
      'sessionId': sessionId,
      'timestamp': DateTime.now().toIso8601String(),
    });

    return sessionId;
  }

  static Future<bool> validateSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionStr = prefs.getString(_sessionKey);
      if (sessionStr == null) return false;

      final sessionData = json.decode(sessionStr);
      final lastActivity = DateTime.fromMillisecondsSinceEpoch(sessionData['lastActivity']);
      
      if (DateTime.now().difference(lastActivity) > sessionTimeout) {
        await invalidateSession();
        return false;
      }

      // Update last activity
      sessionData['lastActivity'] = DateTime.now().millisecondsSinceEpoch;
      await prefs.setString(_sessionKey, json.encode(sessionData));
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> invalidateSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  // Security Logging
  static Future<void> logSecurityEvent(String event, String userId, Map<String, dynamic> details) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsStr = prefs.getString(_securityLogKey) ?? '[]';
      final logs = json.decode(logsStr) as List;

      final logEntry = {
        'event': event,
        'userId': userId,
        'timestamp': DateTime.now().toIso8601String(),
        'details': details,
      };

      logs.add(logEntry);
      
      // Keep only last 100 logs
      if (logs.length > 100) {
        logs.removeRange(0, logs.length - 100);
      }

      await prefs.setString(_securityLogKey, json.encode(logs));
      SecurityUtils.logSecurityEvent(event, userId, details);
    } catch (e) {
      // Fail silently for logging
    }
  }

  // Input Validation
  static Map<String, String> validateRegistrationInput({
    required String username,
    required String email,
    required String phoneNumber,
    required String name,
    required String password,
  }) {
    final errors = <String, String>{};

    print('DEBUG - Phone validation: phoneNumber="$phoneNumber"');
    
    // Email validation
    if (!SecurityUtils.isValidEmail(email)) {
      errors['email'] = 'Invalid email format';
    }

    // Phone validation (Nepal format: 10 digits starting with 9, or with +977 country code)
    var cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Remove country code if present
    if (cleanPhone.startsWith('977') && cleanPhone.length == 13) {
      cleanPhone = cleanPhone.substring(3);
    }
    
    print('DEBUG - Cleaned phone: "$cleanPhone", length: ${cleanPhone.length}, starts with 9: ${cleanPhone.startsWith('9')}');
    
    if (cleanPhone.length != 10 || !cleanPhone.startsWith('9')) {
      errors['phoneNumber'] = 'Invalid Nepal phone number (got: $cleanPhone)';
    }

    // Name validation
    final cleanName = SecurityUtils.sanitizeInput(name);
    if (cleanName.length < 2 || cleanName.length > 50) {
      errors['name'] = 'Name must be 2-50 characters';
    }

    // Password validation
    if (!SecurityUtils.isPasswordStrong(password)) {
      errors['password'] = 'Password must be 8+ characters with uppercase, lowercase, number, and special character';
    }

    return errors;
  }

  // CSRF Protection
  static String generateCSRFToken() {
    return SecurityUtils.generateSecureToken();
  }

  // Content Security Policy
  static Map<String, String> getSecurityHeaders() {
    return {
      'X-Content-Type-Options': 'nosniff',
      'X-Frame-Options': 'DENY',
      'X-XSS-Protection': '1; mode=block',
      'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
      'Content-Security-Policy': "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'",
    };
  }
}