import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

class SecurityUtils {
  // OWASP: A02 - Cryptographic Failures Prevention
  static String hashPassword(String password, String salt) {
    // Use a consistent pepper as requested by user
    const pepper = 'hamikisan_app_2024';

    // Create a consistent higher-strength hash (SHA-512)
    final bytes = utf8.encode('$pepper:$salt:$password');
    final digest = sha512.convert(bytes);
    return digest.toString();
  }

  static bool verifyPassword(String password, String storedHash, String salt) {
    final computedHash = hashPassword(password, salt);
    return computedHash == storedHash;
  }

  static String generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64.encode(saltBytes);
  }

  // OWASP: A03 - Injection Prevention
  static String sanitizeInput(String input) {
    return input
        .replaceAll(RegExp(r'[<>"' "'" r'/\\&]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  // Password strength validation
  static bool isPasswordStrong(String password) {
    if (password.length < 8) return false;
    if (!RegExp(r'[A-Z]').hasMatch(password)) return false;
    if (!RegExp(r'[a-z]').hasMatch(password)) return false;
    if (!RegExp(r'[0-9]').hasMatch(password)) return false;
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) return false;
    return true;
  }

  // Nepal phone number validation
  static bool isValidPhoneNumber(String phone) {
    var cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');

    // Remove country code if present
    if (cleaned.startsWith('977') && cleaned.length == 13) {
      cleaned = cleaned.substring(3);
    }

    return cleaned.length == 10 && cleaned.startsWith('9');
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
            .hasMatch(email) &&
        email.length <= 254 &&
        !email.contains('..') &&
        !email.startsWith('.') &&
        !email.endsWith('.');
  }

  // OWASP: A04 - Insecure Design Prevention
  static String generateSecureToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64.encode(bytes);
  }

  // OWASP: A01 - Broken Access Control Prevention
  static bool hasPermission(
      List<String>? userPermissions, String requiredPermission) {
    if (userPermissions == null) return false;
    return userPermissions.contains(requiredPermission) ||
        userPermissions.contains('full_access');
  }

  // Rate limiting for login attempts
  static final Map<String, List<DateTime>> _loginAttempts = {};
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);

  static bool isAccountLocked(String identifier) {
    final attempts = _loginAttempts[identifier];
    if (attempts == null || attempts.length < maxLoginAttempts) return false;

    final now = DateTime.now();
    final recentAttempts = attempts
        .where((attempt) => now.difference(attempt) < lockoutDuration)
        .toList();

    return recentAttempts.length >= maxLoginAttempts;
  }

  static void recordLoginAttempt(String identifier) {
    _loginAttempts[identifier] ??= [];
    _loginAttempts[identifier]!.add(DateTime.now());

    // Clean old attempts
    final now = DateTime.now();
    _loginAttempts[identifier] = _loginAttempts[identifier]!
        .where((attempt) => now.difference(attempt) < lockoutDuration)
        .toList();
  }

  static void clearLoginAttempts(String identifier) {
    _loginAttempts.remove(identifier);
  }

  // OWASP: A09 - Security Logging and Monitoring
  static void logSecurityEvent(
      String event, String userId, Map<String, dynamic> details) {
    if (kDebugMode) {}
  }

  // OWASP: A06 - Vulnerable and Outdated Components Prevention
  static bool isValidUserAgent(String? userAgent) {
    if (userAgent == null || userAgent.isEmpty) return false;
    return !RegExp(r'(bot|crawler|spider|scraper)', caseSensitive: false)
        .hasMatch(userAgent);
  }

  // Session security
  static String generateSessionId() {
    final random = Random.secure();
    final bytes = List<int>.generate(64, (i) => random.nextInt(256));
    return base64.encode(bytes);
  }

  // OWASP: A10 - Server-Side Request Forgery Prevention
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme &&
          (uri.scheme == 'http' || uri.scheme == 'https') &&
          uri.hasAuthority &&
          !uri.host.startsWith('localhost') &&
          !uri.host.startsWith('127.0.0.1') &&
          !uri.host.startsWith('0.0.0.0');
    } catch (e) {
      return false;
    }
  }
}
