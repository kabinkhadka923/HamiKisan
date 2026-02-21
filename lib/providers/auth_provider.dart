import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/security_service.dart';

class AuthResult {
  final bool success;
  final String error;

  AuthResult({required this.success, this.error = ''});
}

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isAuthenticated => _currentUser != null;
  bool get isFarmer => _currentUser?.role == UserRole.farmer;
  bool get isDoctor => _currentUser?.role == UserRole.kisanDoctor;
  bool get isAdmin => _currentUser?.role == UserRole.kisanAdmin;
  bool get isSuperAdmin => _currentUser?.role == UserRole.superAdmin;

  Future<void> initialize() async {
    try {
      // Validate session security
      final isValidSession = await SecurityService.validateSession();
      if (!isValidSession) {
        _currentUser = null;
        _error = null;
        return;
      }

      final userData = await _authService.getCurrentUser();
      if (userData != null) {
        _currentUser = User.fromJson(userData);
        await _currentUser?.loadPreferences();

        // Log session restoration
        unawaited(SecurityService.logSecurityEvent(
            'SESSION_RESTORED', _currentUser!.id, {
          'name': _currentUser!.name,
        }));
      }
    } catch (e) {
      _error = 'Failed to initialize auth: $e';
      _currentUser = null;
    }
  }

  Future<bool> loginWithUsername(String username, String password,
      {UserRole? role}) async {
    _setLoading(true);
    _clearError();

    try {
      final userData = await _authService.loginWithUsername(username, password);
      if (userData == null) {
        _error = 'Invalid credentials';
        return false;
      }

      final user = User.fromJson(userData);

      // Verify user role matches selected role if specified
      if (role != null && user.role != role) {
        _error = 'Invalid role for this user';
        return false;
      }

      _currentUser = user;
      await saveSession();

      // Create secure session
      await SecurityService.createSecureSession(_currentUser!.id);

      return true;
    } catch (e) {
      _error = 'Login failed: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Admin login through URL access only
  Future<bool> adminLogin(
    String username,
    String password,
    String adminKey, {
    String? superAdminToken,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Define security keys based on admin type
      const String normalAdminKey = 'HAMIKISAN_KRISHI_ADMIN_2024';
      const String superAdminKey = 'HAMIKISAN_SUPER_ADMIN_MASTER_2024';
      const String superAdminSecurityToken =
          'NEPAL_AGRICULTURE_SUPREME_ACCESS_TOKEN_2024';

      // Check if this is a super admin login attempt (based on username)
      final isSuperAdminAttempt = username.toLowerCase().contains('super');

      // Verify admin access keys based on type
      if (isSuperAdminAttempt) {
        // Allow either the super admin specific key or the general admin key that the UI sends
        if (adminKey != superAdminKey && adminKey != normalAdminKey) {
          _error = 'Invalid super admin access key';
          return false;
        }
        // If it was the specific super admin key, check the token (this path might be used by a specialized unrelated UI in future)
        if (adminKey == superAdminKey &&
            superAdminToken != superAdminSecurityToken) {
          _error = 'Invalid super admin security token';
          return false;
        }
      } else {
        // Regular admin login
        if (adminKey != normalAdminKey) {
          _error = 'Invalid admin access key';
          return false;
        }
      }

      final userData = await _authService.loginWithUsername(username, password);
      if (userData == null) {
        print('Admin login failed: userData is null');
        _error = 'Invalid admin credentials';
        return false;
      }

      print('Admin login: userData received - role: ${userData['role']}');

      final user = User.fromJson(userData);
      print('Admin login: User parsed - role: ${user.role}');

      // Verify user has appropriate admin role
      if (isSuperAdminAttempt) {
        if (user.role != UserRole.superAdmin) {
          print('Admin login failed: Expected superAdmin but got ${user.role}');
          _error = 'Access denied: Super Admin privileges required';
          return false;
        }
      } else {
        // Regular admin login
        if (user.role != UserRole.kisanAdmin &&
            user.role != UserRole.superAdmin) {
          print(
              'Admin login failed: Expected kisanAdmin or superAdmin but got ${user.role}');
          _error = 'Access denied: Admin privileges required';
          return false;
        }
      }

      print('Admin login: Role verification passed');
      _currentUser = user;
      await saveSession();

      // Create secure admin session
      await SecurityService.createSecureSession(_currentUser!.id);
      await SecurityService.logSecurityEvent('ADMIN_LOGIN_SUCCESS', user.id, {
        'name': user.name,
      });

      return true;
    } catch (e) {
      print('Admin login error: $e');
      _error = 'Admin login failed: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<AuthResult> registerFarmer({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
    String? address,
    String? farmingCategory,
  }) async {
    final username = email.split('@')[0];
    final success = await register(
      username: username,
      email: email,
      phoneNumber: phoneNumber ?? '',
      name: name,
      role: UserRole.farmer,
      password: password,
      address: address,
      farmingCategory: farmingCategory,
    );
    return AuthResult(success: success, error: _error ?? '');
  }

  Future<AuthResult> registerDoctor({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
    required String specialization,
  }) async {
    final username = email.split('@')[0];
    final success = await register(
      username: username,
      email: email,
      phoneNumber: phoneNumber ?? '',
      name: name,
      role: UserRole.kisanDoctor,
      password: password,
      specialization: specialization,
    );
    return AuthResult(success: success, error: _error ?? '');
  }

  Future<bool> register({
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
    // Block admin registration through public interface
    if (role == UserRole.kisanAdmin || role == UserRole.superAdmin) {
      _error = 'Admin registration not allowed through public interface';
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final userData = await _authService.register(
        username: username,
        email: email,
        phoneNumber: phoneNumber,
        name: name,
        role: role,
        password: password,
        address: address,
        language: language,
        farmingCategory: farmingCategory,
        specialization: specialization,
      );

      if (userData == null) {
        _error = 'Registration failed';
        _setLoading(false);
        return false;
      }

      _currentUser = User.fromJson(userData);

      // Auto login after registration
      await saveSession();
      await _currentUser?.setupDefaultPreferences();

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Registration failed: $e';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> verifyOTP(String phoneNumber, String otp) async {
    _setLoading(true);
    _clearError();

    try {
      final isVerified = await _authService.verifyOTP(phoneNumber, otp);
      if (!isVerified) {
        _error = 'Invalid OTP';
        _setLoading(false);
        return false;
      }

      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(isVerified: true);
        await _authService.updateUser(_currentUser!);
      }

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'OTP verification failed: $e';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> resendOTP(String phoneNumber) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _authService.resendOTP(phoneNumber);
      _setLoading(false);
      return success;
    } catch (e) {
      _error = 'Failed to resend OTP: $e';
      _setLoading(false);
      return false;
    }
  }

  Future<void> updateProfile({
    String? name,
    String? profilePicture,
    String? address,
    String? farmingCategory,
    String? specialization,
  }) async {
    if (_currentUser == null) return;

    _setLoading(true);
    _clearError();

    try {
      final updatedUser = _currentUser!.copyWith(
        name: name,
        profilePicture: profilePicture,
        address: address,
        farmingCategory: farmingCategory,
        specialization: specialization,
      );

      await _authService.updateUser(updatedUser);
      _currentUser = updatedUser;
      await saveSession();

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update profile: $e';
      _setLoading(false);
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_currentUser == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final success = await _authService.changePassword(
        _currentUser!.id,
        currentPassword,
        newPassword,
      );

      _setLoading(false);
      return success;
    } catch (e) {
      _error = 'Failed to change password: $e';
      _setLoading(false);
      return false;
    }
  }

  Future<void> saveSession() async {
    if (_currentUser == null) return;
    await _authService.saveSession(_currentUser!);
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      final userId = _currentUser?.id ?? 'unknown';

      await _authService.logout();
      await SecurityService.invalidateSession();

      // Log logout event
      await SecurityService.logSecurityEvent('LOGOUT', userId, {
        'timestamp': DateTime.now().toIso8601String(),
      });

      _currentUser = null;
      _error = null;
    } catch (e) {
      _error = 'Logout failed: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateLanguage(String language) async {
    if (_currentUser != null) {
      _currentUser =
          _currentUser!.copyWith(language: language, hasSelectedLanguage: true);
      await _authService.updateUserLanguage(_currentUser!.id, language);
      await _authService.updateUserLanguageSelection(_currentUser!.id, true);
      notifyListeners();
    }
  }

  Future<String?> getSavedUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('saved_username');
    } catch (e) {
      return null;
    }
  }

  Future<void> saveUsername(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_username', username);
    } catch (e) {}
  }

  Future<void> clearSavedUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('saved_username');
    } catch (e) {}
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  // Check permissions
  bool hasPermission(String permission) {
    if (_currentUser == null) return false;
    if (_currentUser!.role == UserRole.superAdmin) return true;
    if (_currentUser!.role == UserRole.kisanAdmin) {
      return permission.contains('admin') ||
          permission.contains('moderate') ||
          permission.contains('manage');
    }
    final permissions = _currentUser!.permissions ?? [];
    return permissions.contains(permission);
  }

  String get displayName => _currentUser?.name ?? 'Guest';

  int get profileCompletion {
    if (_currentUser == null) return 0;
    int score = 0;
    if (_currentUser!.name.isNotEmpty) score += 25;
    if (_currentUser!.profilePicture != null) score += 20;
    if (_currentUser!.address != null) score += 20;
    if (_currentUser!.isVerified) score += 15;
    if (_currentUser!.farmingCategory != null) score += 10;
    if (_currentUser!.specialization != null) score += 10;
    return score.clamp(0, 100);
  }
}
