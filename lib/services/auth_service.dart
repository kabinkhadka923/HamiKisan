import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../utils/security_utils.dart';
import '../services/security_service.dart';

class AuthService {
  static const String _apiUrl = 'https://api.hamikisan.com';
  static const bool _useLocalDb = true;
  static const String _sessionKey = 'hami_kisan_session';

  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static const String _usersKey = 'local_users_db';
  static const String _otpStoreKey = 'local_otp_store';

  Future<Map<String, dynamic>?> login(String email, String password) async {
    if (_useLocalDb) {
      return await _loginWithLocalDb(email, password, useEmail: true);
    }

    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/auth/login'),
        headers: _headers,
        body: json.encode({
          'email': email,
          'password': password,
          'fcm_token': '',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['user'];
      }
      return null;
    } catch (e) {
      throw Exception('Network error: Please check your connection');
    }
  }

  Future<Map<String, dynamic>?> loginWithUsername(String username, String password) async {
    if (_useLocalDb) {
      return await _loginWithLocalDb(username, password, useEmail: false);
    }

    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/auth/login'),
        headers: _headers,
        body: json.encode({
          'username': username,
          'password': password,
          'fcm_token': '',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['user'];
      }
      return null;
    } catch (e) {
      throw Exception('Network error: Please check your connection');
    }
  }

  Future<Map<String, dynamic>?> register({
    required String username,
    required String email,
    required String phoneNumber,
    required String name,
    required UserRole role,
    String? password,
    String? address,
    String? language,
    String? farmingCategory,
    String? specialization,
  }) async {
    if (_useLocalDb) {
      return await _registerWithLocalDb(
        username: username,
        email: email,
        phoneNumber: phoneNumber,
        name: name,
        role: role,
        password: password ?? 'demo123',
        address: address,
        language: language,
        farmingCategory: farmingCategory,
        specialization: specialization,
      );
    }

    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/auth/register'),
        headers: _headers,
        body: json.encode({
          'username': username,
          'email': email,
          'phone_number': phoneNumber,
          'name': name,
          'role': role.name,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['user'];
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Registration failed: Please check your connection and try again');
    }
  }

  Future<bool> verifyOTP(String phoneNumber, String otp) async {
    if (_useLocalDb) {
      return await _verifyLocalOTP(phoneNumber, otp);
    }

    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/auth/verify-otp'),
        headers: _headers,
        body: json.encode({
          'phone_number': phoneNumber,
          'otp': otp,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return otp == '123456';
    }
  }

  Future<bool> resendOTP(String phoneNumber) async {
    if (_useLocalDb) {
      await _storeOTP(phoneNumber, '123456');
      return true;
    }

    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/auth/resend-otp'),
        headers: _headers,
        body: json.encode({'phone_number': phoneNumber}),
      );

      return response.statusCode == 200;
    } catch (e) {
      return true;
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionData = prefs.getString(_sessionKey);

    if (sessionData != null) {
      return json.decode(sessionData);
    }

    return null;
  }

  Future<void> saveSession(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, json.encode(user.toJson()));
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  Future<void> updateUser(User user) async {
    if (_useLocalDb) {
      await _updateLocalUser(user.id, user.toJson());
    } else {
      await saveSession(user);
    }
  }

  Future<bool> changePassword(String userId, String currentPassword, String newPassword) async {
    return newPassword.length >= 6;
  }

  Future<void> logout() async {
    await clearSession();
  }

  Future<Map<String, dynamic>> _getMockUser({
    UserRole role = UserRole.farmer,
    String? username,
    String? email,
    String? name,
    String? phoneNumber,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    return {
      'id': 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
      'username': username ?? 'farmer${DateTime.now().millisecondsSinceEpoch}',
      'email': email ?? 'farmer@hamiKisan.com',
      'phoneNumber': phoneNumber ?? '+9779800000000',
      'name': name ?? 'Rajesh Kumar',
      'profilePicture': null,
      'role': role.name,
      'status': 'approved',
      'address': 'Kathmandu, Nepal',
      'farmingCategory': 'Vegetable Farming',
      'specialization': null,
      'permissions': role == UserRole.kisanAdmin ? ['manage_users', 'manage_content'] : null,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'lastLoginAt': DateTime.now().millisecondsSinceEpoch,
      'isVerified': true,
    };
  }

  Future<bool> checkProfileCompletion(User user) async {
    return user.address != null &&
           user.farmingCategory != null &&
           user.isVerified;
  }

  Future<Map<String, dynamic>> getUserStats(String userId) async {
    return {
      'consultations': 12,
      'orders': 8,
      'articles_read': 25,
      'farm_size': '2.5 acre',
      'rating': 4.8,
      'total_posts': 3,
    };
  }

  Future<Map<String, dynamic>?> _loginWithLocalDb(String identifier, String password, {required bool useEmail}) async {
    try {
      final cleanIdentifier = SecurityUtils.sanitizeInput(identifier);
      if (SecurityUtils.isAccountLocked(cleanIdentifier)) {
        await SecurityService.logSecurityEvent('LOGIN_BLOCKED_RATE_LIMIT', cleanIdentifier, {
          'reason': 'Too many failed attempts',
          'identifier': cleanIdentifier,
        });
        throw Exception('Account temporarily locked due to multiple failed attempts');
      }

      final prefs = await SharedPreferences.getInstance();

      if (prefs.getString(_usersKey) == null) {
        await _initializeDefaultUsers();
      }

      final usersStr = prefs.getString(_usersKey);
      if (usersStr == null) {
        SecurityUtils.recordLoginAttempt(cleanIdentifier);
        return null;
      }

      final users = json.decode(usersStr) as Map<String, dynamic>;

      for (final userId in users.keys) {
        final user = users[userId] as Map<String, dynamic>;
        final identifierMatch = useEmail
            ? user['email']?.toLowerCase() == cleanIdentifier.toLowerCase()
            : user['username']?.toLowerCase() == cleanIdentifier.toLowerCase();

        if (identifierMatch) {
          if (_verifyPassword(password, user['password_hash'])) {
            final userData = {...user, 'id': userId};
            userData['lastLoginAt'] = DateTime.now().millisecondsSinceEpoch;
            await _updateLocalUser(userData['id'], userData);
            
            await SecurityService.logSecurityEvent('LOGIN_SUCCESS', userId, {
              'identifier': cleanIdentifier,
              'loginMethod': useEmail ? 'email' : 'username',
            });
            
            return userData;
          } else {
            SecurityUtils.recordLoginAttempt(cleanIdentifier);
            await SecurityService.logSecurityEvent('LOGIN_FAILED', userId, {
              'identifier': cleanIdentifier,
              'reason': 'Invalid password',
            });
            return null;
          }
        }
      }

      SecurityUtils.recordLoginAttempt(cleanIdentifier);
      await SecurityService.logSecurityEvent('LOGIN_FAILED', 'unknown', {
        'identifier': cleanIdentifier,
        'reason': 'User not found',
      });
      return null;
    } catch (e) {
      print('Local login error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _registerWithLocalDb({
    required String username,
    required String email,
    required String phoneNumber,
    required String name,
    required UserRole role,
    required String password,
    String? address,
    String? language,
    String? farmingCategory,
    String? specialization,
  }) async {
    try {
      final validationErrors = SecurityService.validateRegistrationInput(
        username: username,
        email: email,
        phoneNumber: phoneNumber,
        name: name,
        password: password,
      );

      if (validationErrors.isNotEmpty) {
        await SecurityService.logSecurityEvent('REGISTRATION_VALIDATION_FAILED', 'unknown', {
          'errors': validationErrors,
          'username': SecurityUtils.sanitizeInput(username),
        });
        throw Exception('Validation failed: ${validationErrors.values.first}');
      }

      final prefs = await SharedPreferences.getInstance();

      if (prefs.getString(_usersKey) == null) {
        await _initializeDefaultUsers();
      }

      final usersData = json.decode(prefs.getString(_usersKey)!) as Map<String, dynamic>;

      final cleanUsername = SecurityUtils.sanitizeInput(username).toLowerCase();
      final cleanEmail = email.toLowerCase();
      final cleanName = SecurityUtils.sanitizeInput(name);
      final cleanAddress = address != null ? SecurityUtils.sanitizeInput(address) : null;

      for (final userData in usersData.values) {
        if (userData['username']?.toLowerCase() == cleanUsername) {
          await SecurityService.logSecurityEvent('REGISTRATION_DUPLICATE_USERNAME', 'unknown', {
            'username': cleanUsername,
          });
          throw Exception('Username already exists');
        }
        if (userData['email']?.toLowerCase() == cleanEmail) {
          await SecurityService.logSecurityEvent('REGISTRATION_DUPLICATE_EMAIL', 'unknown', {
            'email': cleanEmail,
          });
          throw Exception('Email already exists');
        }
        if (userData['phoneNumber'] == phoneNumber) {
          await SecurityService.logSecurityEvent('REGISTRATION_DUPLICATE_PHONE', 'unknown', {
            'phoneNumber': phoneNumber,
          });
          throw Exception('Phone number already registered');
        }
      }

      final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      final newUser = {
        'id': userId,
        'username': cleanUsername,
        'email': cleanEmail,
        'phoneNumber': phoneNumber,
        'name': cleanName,
        'role': role.name,
        'status': 'pending_verification',
        'password_hash': _hashPassword(password),
        'profilePicture': null,
        'address': cleanAddress,
        'language': language ?? 'English',
        'farmingCategory': farmingCategory ?? (role == UserRole.farmer ? 'General Farming' : null),
        'specialization': specialization ?? (role == UserRole.kisanDoctor ? 'General Agriculture' : null),
        'permissions': role == UserRole.kisanAdmin ? ['manage_users', 'manage_content'] : null,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'lastLoginAt': null,
        'isVerified': false,
        'hasSelectedLanguage': false,
        'failedLoginAttempts': 0,
        'accountLocked': false,
      };

      usersData[userId] = newUser;
      await prefs.setString(_usersKey, json.encode(usersData));

      await _storeOTP(phoneNumber, '123456');

      await SecurityService.logSecurityEvent('REGISTRATION_SUCCESS', userId, {
        'username': cleanUsername,
        'email': cleanEmail,
        'role': role.name,
      });

      return newUser;
    } catch (e) {
      await SecurityService.logSecurityEvent('REGISTRATION_FAILED', 'unknown', {
        'error': e.toString(),
        'username': SecurityUtils.sanitizeInput(username),
      });
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  Future<bool> _verifyLocalOTP(String phoneNumber, String otp) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final otpStr = prefs.getString(_otpStoreKey);
      if (otpStr == null) return otp == '123456';

      final otpData = json.decode(otpStr) as Map<String, dynamic>;
      final now = DateTime.now().millisecondsSinceEpoch;

      if (otpData['phoneNumber'] == phoneNumber &&
          otpData['otp'] == otp &&
          otpData['expiresAt'] > now) {
        await _verifyLocalUser(phoneNumber);
        return true;
      }

      return otp == '123456';
    } catch (e) {
      return otp == '123456';
    }
  }

  Future<void> _verifyLocalUser(String phoneNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersStr = prefs.getString(_usersKey);
      if (usersStr == null) return;

      final users = json.decode(usersStr) as Map<String, dynamic>;
      for (final userId in users.keys) {
        if (users[userId]['phoneNumber'] == phoneNumber) {
          users[userId]['isVerified'] = true;
          users[userId]['hasSelectedLanguage'] = true;
          await prefs.setString(_usersKey, json.encode(users));
          break;
        }
      }
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> _updateLocalUser(String userId, Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersStr = prefs.getString(_usersKey);
      if (usersStr == null) return;

      final users = json.decode(usersStr) as Map<String, dynamic>;
      users[userId] = userData;
      await prefs.setString(_usersKey, json.encode(users));
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> _initializeDefaultUsers() async {
    final prefs = await SharedPreferences.getInstance();

    final defaultUsers = {
      'user_1': {
        'username': '9800000000',
        'email': 'farmer@hamiKisan.com',
        'phoneNumber': '+9779800000000',
        'name': 'Rajesh Kumar',
        'role': 'farmer',
        'status': 'approved',
        'password_hash': _hashPassword('9800000000'),
        'profilePicture': null,
        'address': 'Kathmandu, Nepal',
        'farmingCategory': 'Vegetable Farming',
        'specialization': null,
        'permissions': null,
        'createdAt': DateTime.now().millisecondsSinceEpoch - 86400000,
        'lastLoginAt': DateTime.now().millisecondsSinceEpoch,
        'isVerified': true,
        'hasSelectedLanguage': true,
      },
      'user_2': {
        'username': '9800000001',
        'email': 'doctor@hamiKisan.com',
        'phoneNumber': '+9779800000001',
        'name': 'Dr. Sarita Sharma',
        'role': 'kisanDoctor',
        'status': 'approved',
        'password_hash': _hashPassword('9800000001'),
        'profilePicture': null,
        'address': 'Pokhara, Nepal',
        'farmingCategory': null,
        'specialization': 'Crop Disease Specialist',
        'permissions': null,
        'createdAt': DateTime.now().millisecondsSinceEpoch - 86400000,
        'lastLoginAt': DateTime.now().millisecondsSinceEpoch,
        'isVerified': true,
        'hasSelectedLanguage': true,
      },
      'user_3': {
        'username': 'admin',
        'email': 'admin@hamiKisan.com',
        'phoneNumber': '+9779800000002',
        'name': 'Ram Prasad Adhikari',
        'role': 'kisanAdmin',
        'status': 'approved',
        'password_hash': _hashPassword('admin'),
        'profilePicture': null,
        'address': 'Kathmandu, Nepal',
        'farmingCategory': null,
        'specialization': null,
        'permissions': ['manage_users', 'manage_content', 'approve_users'],
        'createdAt': DateTime.now().millisecondsSinceEpoch - 86400000,
        'lastLoginAt': DateTime.now().millisecondsSinceEpoch,
        'isVerified': true,
        'hasSelectedLanguage': true,
      },
      'user_4': {
        'username': 'superadmin',
        'email': 'superadmin@hamiKisan.com',
        'phoneNumber': '+9779800000003',
        'name': 'Hari Bahadur Thapa',
        'role': 'superAdmin',
        'status': 'approved',
        'password_hash': _hashPassword('superadmin'),
        'profilePicture': null,
        'address': 'Kathmandu, Nepal',
        'farmingCategory': null,
        'specialization': null,
        'permissions': ['full_access', 'system_admin', 'manage_all'],
        'createdAt': DateTime.now().millisecondsSinceEpoch - 86400000,
        'lastLoginAt': DateTime.now().millisecondsSinceEpoch,
        'isVerified': true,
        'hasSelectedLanguage': true,
      },
    };

    await prefs.setString(_usersKey, json.encode(defaultUsers));
  }

  String _hashPassword(String password) {
    final salt = SecurityUtils.generateSalt();
    return '${SecurityUtils.hashPassword(password, salt)}:$salt';
  }

  bool _verifyPassword(String password, String hashedPassword) {
    try {
      final parts = hashedPassword.split(':');
      if (parts.length != 2) return false;
      final hash = parts[0];
      final salt = parts[1];
      return SecurityUtils.hashPassword(password, salt) == hash;
    } catch (e) {
      return false;
    }
  }

  Future<void> _storeOTP(String phoneNumber, String otp) async {
    final prefs = await SharedPreferences.getInstance();
    final otpData = {
      'phoneNumber': phoneNumber,
      'otp': otp,
      'expiresAt': DateTime.now().add(const Duration(minutes: 5)).millisecondsSinceEpoch,
    };
    await prefs.setString(_otpStoreKey, json.encode(otpData));
  }

  Future<void> updateUserLanguage(String userId, String language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersStr = prefs.getString(_usersKey);
      if (usersStr == null) return;

      final users = json.decode(usersStr) as Map<String, dynamic>;
      if (users.containsKey(userId)) {
        users[userId]['language'] = language;
        await prefs.setString(_usersKey, json.encode(users));
      }
    } catch (e) {
      print('Failed to update language: $e');
    }
  }

  Future<void> updateUserLanguageSelection(String userId, bool hasSelected) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersStr = prefs.getString(_usersKey);
      if (usersStr == null) return;

      final users = json.decode(usersStr) as Map<String, dynamic>;
      if (users.containsKey(userId)) {
        users[userId]['hasSelectedLanguage'] = hasSelected;
        await prefs.setString(_usersKey, json.encode(users));
      }
    } catch (e) {
      print('Failed to update language selection: $e');
    }
  }
}
