import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import '../providers/auth_provider.dart';
import '../services/database.dart';
import 'admin/admin_dashboard_screen.dart';
import 'super_admin_secure_panel.dart';
import '../widgets/password_strength_meter.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  int _failedAttempts = 0;
  bool _isLocked = false;
  DateTime? _lockUntil;
  bool _showTwoFactor = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final _db = DatabaseService();
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );
    _animationController.forward();
    _checkLockStatus();
    _debugAuthState();
  }

  Future<void> _debugAuthState() async {
    if (!kDebugMode) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final usersStr = prefs.getString('local_users_db_v4');
      if (usersStr == null) {
        print('[DEBUG] No users found in SharedPreferences DB');
        return;
      }

      final users = json.decode(usersStr) as Map<String, dynamic>;
      print('========================================');
      print('[DEBUG] AUTH STATE');
      print('Total users: ${users.length}');
      users.forEach((id, data) {
        print(
            'User: ${data['username']}, Role: ${data['role']}, Hash: ${data['password_hash']?.toString().substring(0, 20)}...');
      });
      print('========================================');
    } catch (e) {
      print('[DEBUG] Error checking auth state: $e');
    }
  }

  Future<void> _checkLockStatus() async {
    try {
      final lockTime = await _db.getAdminLockTime(_usernameController.text);
      if (lockTime != null && lockTime.isAfter(DateTime.now())) {
        setState(() {
          _isLocked = true;
          _lockUntil = lockTime;
        });
      }
    } catch (e) {
      // Database might not be available on web, ignore lock check
      print('Lock status check failed (database unavailable): $e');
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header Section
                _buildHeader(),
                const SizedBox(height: 48),

                if (_isLocked) _buildLockedMessage(),
                if (!_isLocked) ...[
                  if (_showTwoFactor)
                    _buildTwoFactorForm()
                  else
                    _buildLoginForm(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A237E), Color(0xFF283593)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A237E).withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 2),
          ),
          child: Stack(
            children: [
              Center(
                child: Icon(
                  Icons.security,
                  size: 60,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Admin Portal',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Secure Management System',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning,
                size: 12,
                color: Colors.red.shade300,
              ),
              const SizedBox(width: 4),
              const Text(
                'RESTRICTED ACCESS',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLockedMessage() {
    final remainingTime = _lockUntil?.difference(DateTime.now());
    final minutes = remainingTime?.inMinutes ?? 0;
    final seconds = (remainingTime?.inSeconds ?? 0) % 60;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.lock_clock,
            size: 64,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'Account Temporarily Locked',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Too many failed login attempts',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  'Account will be unlocked in:',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$minutes:${seconds.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: _contactSupport,
            icon: const Icon(Icons.support_agent),
            label: const Text('Contact System Administrator'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue.shade300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Username Field
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextFormField(
              controller: _usernameController,
              focusNode: _usernameFocus,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Admin Username',
                labelStyle: const TextStyle(color: Colors.white70),
                hintText: 'Enter admin username',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                prefixIcon:
                    Icon(Icons.person, color: Colors.white.withValues(alpha: 0.7)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.08),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF1A237E), width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Username is required';
                }
                if (value.length < 3) {
                  return 'Username must be at least 3 characters';
                }
                return null;
              },
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
            ),
          ),
          const SizedBox(height: 20),

          // Password Field
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextFormField(
              controller: _passwordController,
              focusNode: _passwordFocus,
              obscureText: _obscurePassword,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Admin Password',
                labelStyle: const TextStyle(color: Colors.white70),
                hintText: 'Enter your password',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                prefixIcon:
                    Icon(Icons.lock, color: Colors.white.withValues(alpha: 0.7)),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.08),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF1A237E), width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                if (value.length < 8) {
                  return 'Password must be at least 8 characters';
                }
                return null;
              },
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleLogin(),
            ),
          ),

          if (_passwordController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: PasswordStrengthMeter(
                password: _passwordController.text,
              ),
            ),

          const SizedBox(height: 32),

          // Failed Attempts Warning
          if (_failedAttempts > 0)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber,
                    color: Colors.red.shade300,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$_failedAttempts failed attempt${_failedAttempts > 1 ? 's' : ''}. '
                      'Account will be locked after ${3 - _failedAttempts} more attempt${_failedAttempts == 2 ? '' : 's'}.',
                      style: TextStyle(
                        color: Colors.red.shade200,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Login Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: const Color(0xFF1A237E).withValues(alpha: 0.5),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.login, size: 20),
                        const SizedBox(width: 12),
                        const Text(
                          'Secure Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_failedAttempts > 0)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$_failedAttempts',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 20),

          // Additional Options
          _buildAdditionalOptions(),
        ],
      ),
    );
  }

  Widget _buildTwoFactorForm() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Icon(
                Icons.verified_user,
                size: 64,
                color: Colors.blue.shade400,
              ),
              const SizedBox(height: 16),
              const Text(
                'Two-Factor Authentication',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the 6-digit code sent to your email',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    letterSpacing: 8,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.blue.withValues(alpha: 0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.blue, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.08),
                    hintText: '000000',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      letterSpacing: 8,
                    ),
                  ),
                  onChanged: (value) {
                    if (value.length == 6) {
                      _verifyTwoFactorCode(value);
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive code? ",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                  TextButton(
                    onPressed: _resendTwoFactorCode,
                    child: const Text(
                      'Resend Code',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => _showTwoFactor = false),
                child: const Text(
                  '← Back to Login',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalOptions() {
    return Column(
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _showForgotPasswordDialog,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.lock_reset, size: 18),
                label: const Text(
                  'Reset Password',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text(
                  'User Login',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Colors.white.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'For security reasons, this session will timeout after 15 minutes of inactivity.',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.6),
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;
      final authProvider = context.read<AuthProvider>();

      // Use admin login method with security keys
      final success = await authProvider.adminLogin(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
        'HAMIKISAN_KRISHI_ADMIN_2024', // Default admin key
      );

      if (success) {
        // Reset failed attempts on success
        setState(() => _failedAttempts = 0);

        try {
          await _db.resetAdminLock(_usernameController.text);
        } catch (e) {
          // Database might not be available on web, ignore
          print('Failed to reset admin lock (database unavailable): $e');
        }

        // Check if user is admin
        if (authProvider.isAdmin || authProvider.isSuperAdmin) {
          // For admin accounts, require 2FA
          setState(() {
            _showTwoFactor = true;
            _isLoading = false;
          });
        } else {
          // Not an admin
          setState(() => _isLoading = false);
          _showErrorDialog(
              'Access Denied', 'Only admin accounts can access this portal.');
        }
      } else {
        // Increment failed attempts
        setState(() => _failedAttempts++);

        if (_failedAttempts >= 3) {
          // Lock account for 15 minutes
          final lockUntil = DateTime.now().add(const Duration(minutes: 15));

          try {
            await _db.lockAdminAccount(_usernameController.text, lockUntil);
          } catch (e) {
            // Database might not be available on web, ignore
            print('Failed to lock admin account (database unavailable): $e');
          }

          setState(() {
            _isLocked = true;
            _lockUntil = lockUntil;
          });
        }

        setState(() => _isLoading = false);
        _showErrorDialog(
            'Login Failed', authProvider.error ?? 'Invalid credentials');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog(
          'Network Error', 'Please check your connection and try again.');
    }
  }

  Future<void> _verifyTwoFactorCode(String code) async {
    setState(() => _isLoading = true);

    try {
      // Simulate 2FA verification
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      // In real app, verify with backend
      if (code == '123456') {
        // Demo code - replace with actual verification
        final authProvider = context.read<AuthProvider>();
        // Navigate based on role
        if (mounted) {
          if (authProvider.isSuperAdmin) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const SuperAdminSecurePanel()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const AdminDashboardScreen(isSuperAdmin: false)),
            );
          }
        }
      } else {
        _showErrorDialog(
            'Invalid Code', 'Please enter the correct 6-digit code.');
      }
    } catch (e) {
      _showErrorDialog('Verification Failed', 'Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resendTwoFactorCode() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('New verification code sent to your email'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showForgotPasswordDialog() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      _showErrorDialog(
          'Username Required', 'Please enter your admin username first.');
      return;
    }

    final user = await _db.getUserByUsername(username);
    if (!mounted) return;
    if (user == null ||
        (user['role'] != 'kisanAdmin' && user['role'] != 'superAdmin')) {
      _showErrorDialog(
          'Account Not Found', 'No admin account found with this username.');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.password, color: Colors.blue.shade300),
            const SizedBox(width: 8),
            const Text(
              'Reset Admin Password',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.email_outlined, size: 48, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              'Send password reset link to:',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                user['email'] as String,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'An email with password reset instructions will be sent to this address.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _sendPasswordResetEmail(user['email'] as String);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendPasswordResetEmail(String email) async {
    try {
      final resetToken = _generateResetToken();

      // Log reset request (in production, send actual email)
      await _db.logPasswordResetRequest(email, resetToken);

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade300),
              const SizedBox(width: 8),
              const Text(
                'Reset Link Sent',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.mark_email_read, size: 64, color: Colors.green),
              const SizedBox(height: 16),
              const Text(
                'Check Your Email',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Password reset instructions have been sent to your registered email address.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.timer, size: 16, color: Colors.blue),
                    SizedBox(height: 8),
                    Text(
                      'Reset link will expire in 1 hour',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'For security, please reset your password immediately.',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      _showErrorDialog(
          'Sending Failed', 'Could not send reset email. Please try again.');
    }
  }

  void _contactSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: const Text('Contact Support',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.support_agent, size: 48, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              'System Administrator Contact',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildContactInfo('Email:', 'admin@hamikisan.com'),
                  _buildContactInfo('Phone:', '+977 9800000000'),
                  _buildContactInfo('Hours:', 'Mon-Fri, 9AM-5PM'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              // Open email client
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send Email'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade300),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  String _generateResetToken() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(64, (index) => chars[random.nextInt(chars.length)])
        .join();
  }
}

// Add these methods to your DatabaseService class:
/*
class DatabaseService {
  Future<void> lockAdminAccount(String username, DateTime lockUntil) async {
    // Implement account locking
  }

  Future<void> resetAdminLock(String username) async {
    // Implement lock reset
  }

  Future<DateTime?> getAdminLockTime(String username) async {
    // Get lock time from database
    return null;
  }

  Future<void> logPasswordResetRequest(String email, String token) async {
    // Log reset request
  }
}
*/
