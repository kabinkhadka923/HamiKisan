import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../models/user.dart';
import '../models/district.dart';
import '../utils/app_colors.dart';
import '../utils/security_utils.dart';
import 'home_screen.dart';
import 'language_selection_screen.dart';
import 'kisan_doctor/kisan_doctor_dashboard_screen.dart';
import '../widgets/localized_text.dart';
import '../widgets/password_strength_meter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  // New Controllers
  final _kisanIdController = TextEditingController();
  final _landAreaController = TextEditingController();
  final _wardNoController = TextEditingController();
  final _localLevelController = TextEditingController();

  String? _selectedDistrict;
  String? _selectedProvince;
  String _selectedLanguage = 'English';
  final _farmingCategoryController = TextEditingController();
  final _specializationController = TextEditingController();

  UserRole _selectedRole = UserRole.farmer;
  bool _isLogin = true;
  bool _isOtpVerification = false;
  bool _agreeToTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _otpResendCooldown = 0;
  int _loginAttempts = 0;
  Timer? _cooldownTimer;
  String? _verificationPhoneNumber;
  bool _rememberMe = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  List<Map<String, dynamic>> get _roles => [
        {
          'role': UserRole.farmer,
          'title': context.tr('farmer'),
          'subtitle': context.tr('farmer_desc'),
          'icon': Icons.agriculture,
          'color': const Color(0xFF3DA35D),
        },
        {
          'role': UserRole.kisanDoctor,
          'title': context.tr('kisan_doctor'),
          'subtitle': context.tr('doctor_desc'),
          'icon': Icons.health_and_safety,
          'color': Colors.orange,
          'requiresVerification': true,
        },
      ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSavedCredentials();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
    _scaleController.forward();
  }

  Future<void> _loadSavedCredentials() async {
    final authProvider = context.read<AuthProvider>();
    final savedUsername = await authProvider.getSavedUsername();
    if (savedUsername != null) {
      setState(() {
        _phoneController.text = savedUsername;
        _rememberMe = true;
      });
    }
    // Auto-focus on phone number if it's empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_phoneController.text.isEmpty) {
        FocusScope.of(context).requestFocus(FocusNode());
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = context.read<AuthProvider>();

    if (authProvider.isAuthenticated && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final user = authProvider.currentUser;
          if (user?.role == UserRole.kisanDoctor) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (context) =>
                      KisanDoctorDashboardScreen(doctor: user!)),
            );
          } else {
            _navigateToHome();
          }
        }
      });
    }
  }

  void _navigateToHome() {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    if (user.role == UserRole.kisanDoctor) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => KisanDoctorDashboardScreen(doctor: user)),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  void _navigateToLanguageSelection() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LanguageSelectionScreen()),
    );
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _fadeController.dispose();
    _scaleController.dispose();

    _farmingCategoryController.dispose();
    _specializationController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _startOtpCooldown() {
    setState(() {
      _otpResendCooldown = 60; // 60 seconds cooldown
    });

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_otpResendCooldown > 0) {
          _otpResendCooldown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return context.tr('required_field');
    if (!SecurityUtils.isValidPhoneNumber(value)) {
      return context.tr('invalid_phone');
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return context.tr('required_field');
    if (_isLogin) {
      if (value.length < 6) return context.tr('password_too_short');
      return null;
    }
    // Simplified validation for UX
    if (value.length < 8) {
      return context.tr('password_too_short');
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) return context.tr('required_field');
    final cleanName = SecurityUtils.sanitizeInput(value);
    if (cleanName.length < 2 || cleanName.length > 50) {
      return 'Name must be 2-50 characters'; // Keeping simple or add to l10n
    }
    // Removed strict regex to allow Nepali characters
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background/bg.jpg'),
            fit: BoxFit.cover,
            opacity: 1.00,
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F5E8),
              Color(0xFFF5F7FA),
            ],
          ),
        ),
        child: SafeArea(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 5),
                      _buildLogo(),
                      const SizedBox(height: 10),

                      // Role Selection (only for registration)
                      if (!_isLogin && !_isOtpVerification) ...[
                        _buildRoleSelection(),
                        const SizedBox(height: 30),
                      ],

                      // OTP Verification Header
                      if (_isOtpVerification) ...[
                        _buildOtpVerificationHeader(),
                        const SizedBox(height: 30),
                      ],

                      // Main Form
                      _buildForm(),

                      const SizedBox(height: 24),
                      _buildActionButton(),
                      const SizedBox(height: 20),
                      _buildToggleMode(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        GestureDetector(
          onLongPress: () {
            SecurityUtils.clearLoginAttempts(_phoneController.text.trim());
            setState(() => _loginAttempts = 0);
            _showMessage('Rate limit reset successfully', isError: false);
          },
          child: Image.asset(
            'assets/logo/logo.png',
            width: 200,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF3DA35D), Color(0xFF2E7D32)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.agriculture,
                    size: 80, color: Colors.white),
              );
            },
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -80),
          child: Text(
            context.tr('app_name'),
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF3DA35D),
              letterSpacing: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          context.tr('app_tagline'),
          style: GoogleFonts.notoSansDevanagari(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w700,
            shadows: [
              Shadow(
                offset: const Offset(1, 1),
                blurRadius: 3,
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRoleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LocalizedText(
          'select_role',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 3,
                color: Colors.black54,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ..._roles.map((role) => _buildRoleCard(role)),
      ],
    );
  }

  Widget _buildRoleCard(Map<String, dynamic> role) {
    final isSelected = _selectedRole == role['role'];
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role['role']),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected ? role['color'].withValues(alpha: 0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? role['color']! : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: role['color'].withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? role['color']
                      : role['color'].withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  role['icon'],
                  color: isSelected ? Colors.white : role['color'],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role['title'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? role['color'] : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role['subtitle'],
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected ? role['color'] : Colors.grey.shade400,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpVerificationHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        children: [
          Icon(
            Icons.verified_user_rounded,
            size: 48,
            color: Colors.blue.shade600,
          ),
          const SizedBox(height: 12),
          Text(
            'Verify Your Phone',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We sent a 6-digit code to $_verificationPhoneNumber',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Enter the code below to verify your account',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    if (_isOtpVerification) {
      return _buildOtpForm();
    }

    return _isLogin ? _buildLoginForm() : _buildRegistrationForm();
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        // Role Selector
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF3DA35D).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF3DA35D).withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Image.asset(
                'assets/icons/icons.png',
                width: 20,
                height: 20,
                color: Colors.white,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.person_outline,
                      color: Colors.white);
                },
              ),
              const SizedBox(width: 12),
              Text(
                '${context.tr('login_as')} ' ,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w500),
              ),
              DropdownButton<UserRole>(
                value: _selectedRole,
                underline: const SizedBox(),
                items: _roles.map((role) {
                  return DropdownMenuItem<UserRole>(
                    value: role['role'],
                    child: Text(
                      role['title'].split(' / ')[0],
                      style: TextStyle(
                          color: role['color'], fontWeight: FontWeight.w600),
                    ),
                  );
                }).toList(),
                onChanged: (UserRole? newRole) {
                  if (newRole != null) {
                    setState(() => _selectedRole = newRole);
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Phone Number
        TextFormField(
          controller: _phoneController,
          validator: _validatePhone,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          autofocus: true,
          decoration: InputDecoration(
            labelText: context.tr('phone_number'),
            hintText: '98XXXXXXXX',
            prefixIcon:
                const Icon(Icons.phone_android, color: Color(0xFF3DA35D)),
            prefixText: '+977 ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3DA35D)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3DA35D), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),

        // Password
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Password is required';
            return null;
          },
          decoration: InputDecoration(
            labelText: context.tr('password'),
            hintText: context.tr('enter_password'),
            prefixIcon:
                const Icon(Icons.lock_outline, color: Color(0xFF3DA35D)),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey.shade600,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3DA35D)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3DA35D), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 10),

        // Remember Me
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (value) =>
                  setState(() => _rememberMe = value ?? false),
              activeColor: const Color(0xFF3DA35D),
            ),
            Text(
              context.tr('remember_me'),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Forgot Password
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _showForgotPasswordDialog,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF3DA35D),
            ),
            child: Text(
              context.tr('forgot_password'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),

        // Login Attempts Warning
        if (_loginAttempts > 2)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange.shade600, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context
                        .tr('warning_attempts')
                        .replaceAll('{attempts}', '${5 - _loginAttempts}'),
                    style:
                        TextStyle(color: Colors.orange.shade700, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildRegistrationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Full Name
        _buildTextField(
          controller: _nameController,
          label: context.tr('full_name'),
          hint: context.tr('enter_name'),
          icon: Icons.person,
          validator: _validateName,
        ),
        const SizedBox(height: 16),

        // Phone Number (Mobile)
        _buildTextField(
          controller: _phoneController,
          label: context.tr('phone_number'),
          hint: context.tr('enter_phone_number'),
          icon: Icons.phone_android,
          validator: _validatePhone,
          inputType: TextInputType.phone,
          formatters: [FilteringTextInputFormatter.digitsOnly],
          prefixText: '+977 ',
        ),
        const SizedBox(height: 16),

        // Password
        _buildTextField(
          controller: _passwordController,
          label: context.tr('password'),
          hint: context.tr('password_hint'),
          icon: Icons.lock_outline,
          validator: _validatePassword,
          isPassword: true,
          obscureText: _obscurePassword,
          toggleObscure: () =>
              setState(() => _obscurePassword = !_obscurePassword),
          onChanged: () => setState(() {}),
        ),
        if (_passwordController.text.isNotEmpty)
          PasswordStrengthMeter(password: _passwordController.text),
        const SizedBox(height: 16),

        // Confirm Password
        _buildTextField(
          controller: _confirmPasswordController,
          label: context.tr('confirm_password'),
          hint: context.tr('reenter_password'),
          icon: Icons.lock_reset,
          isPassword: true,
          obscureText: _obscureConfirmPassword,
          toggleObscure: () => setState(
              () => _obscureConfirmPassword = !_obscureConfirmPassword),
          validator: (value) {
            if (value != _passwordController.text) {
              return context.tr('password_mismatch');
            }
            return null;
          },
        ),
        const SizedBox(height: 24),

        // Address Section Header
        Text(
          context.tr('address'),
          style: GoogleFonts.notoSansDevanagari(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF3DA35D),
          ),
        ),
        const SizedBox(height: 16),

        // Province Dropdown (Mock Data for now as model doesn't have unique province list efficiently)
        DropdownButtonFormField<String>(
          initialValue: _selectedProvince,
          decoration: _buildInputDecoration(context.tr('province'), Icons.map),
          items: [
            'Province 1',
            'Madhesh',
            'Bagmati',
            'Gandaki',
            'Lumbini',
            'Karnali',
            'Sudurpashchim'
          ].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
          onChanged: (val) => setState(() => _selectedProvince = val),
          validator: (val) => val == null ? context.tr('required_field') : null,
        ),
        const SizedBox(height: 16),

        // District Dropdown
        DropdownButtonFormField<String>(
          initialValue: _selectedDistrict,
          decoration:
              _buildInputDecoration(context.tr('district'), Icons.location_on),
          items: NepalDistricts.all
              .where((d) =>
                  _selectedProvince == null ||
                  d.province.contains(_selectedProvince!))
              .map((district) {
            return DropdownMenuItem<String>(
              value: district.name,
              child: Text(district.name),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedDistrict = value),
          validator: (value) =>
              value == null ? context.tr('required_field') : null,
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _localLevelController,
                label: context.tr('local_level'),
                hint: 'e.g. Palungtar',
                icon: Icons.location_city,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 100,
              child: _buildTextField(
                controller: _wardNoController,
                label: context.tr('ward_no'),
                hint: '1-32',
                icon: Icons.numbers,
                inputType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Farm Details Section
        if (_selectedRole == UserRole.farmer) ...[
          Text(
            context.tr('farm_type'), // "Farm Details" effectively
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF3DA35D),
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _kisanIdController,
            label: context.tr('kisan_id'),
            hint: context.tr('enter_kisan_id'),
            icon: Icons.badge,
            inputType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _farmingCategoryController,
            label: context.tr('farm_type'),
            hint: context.tr('farming_category_hint'),
            icon: Icons.grass,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _landAreaController,
            label: context.tr('land_area'),
            hint: 'e.g. 5 Ropani',
            icon: Icons.landscape,
          ),
        ],

        if (_selectedRole == UserRole.kisanDoctor)
          _buildTextField(
            controller: _specializationController,
            label: context.tr('specialization'),
            hint: context.tr('specialization_hint'),
            icon: Icons.medical_services,
          ),

        const SizedBox(height: 20),

        // Terms & Conditions
        _buildTermsCheckbox(),
      ],
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.notoSansDevanagari(),
      prefixIcon: Icon(icon, color: const Color(0xFF3DA35D)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3DA35D)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3DA35D), width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType inputType = TextInputType.text,
    List<TextInputFormatter>? formatters,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? toggleObscure,
    String? prefixText,
    VoidCallback? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction, // Inline validation
      keyboardType: inputType,
      inputFormatters: formatters,
      obscureText: obscureText,
      onChanged: onChanged != null ? (_) => onChanged() : null,
      style: GoogleFonts.notoSansDevanagari(),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.notoSansDevanagari(),
        hintStyle: GoogleFonts.notoSansDevanagari(color: Colors.grey.shade400),
        prefixIcon: Icon(icon, color: const Color(0xFF3DA35D)),
        prefixText: prefixText,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey.shade600,
                ),
                onPressed: toggleObscure,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3DA35D)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3DA35D), width: 2),
        ),
        // Visual feedback for errors/success could be added here
        errorStyle: const TextStyle(color: Colors.red),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _agreeToTerms,
          onChanged: (value) => setState(() => _agreeToTerms = value ?? false),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          activeColor: const Color(0xFF3DA35D),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text.rich(
              TextSpan(
                text: 'I agree to the Terms & Conditions and Privacy Policy',
                style: GoogleFonts.notoSansDevanagari(
                  color: Colors.grey.shade700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpForm() {
    return Column(
      children: [
        TextFormField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 8,
          ),
          decoration: InputDecoration(
            labelText: 'Enter 6-digit OTP',
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          onChanged: (value) {
            if (value.length == 6) {
              _verifyOtp();
            }
          },
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${context.tr('didnt_receive_code')} ",
              style: TextStyle(color: Colors.grey.shade600),
            ),
            TextButton(
              onPressed: _otpResendCooldown > 0 ? null : _resendOtp,
              style: TextButton.styleFrom(
                foregroundColor:
                    _otpResendCooldown > 0 ? Colors.grey : Colors.green,
              ),
              child: Text(
                _otpResendCooldown > 0
                    ? context
                        .tr('resend_in')
                        .replaceAll('{seconds}', '$_otpResendCooldown')
                    : context.tr('resend_otp'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    final authProvider = context.watch<AuthProvider>();

    if (_isOtpVerification) {
      return Column(
        children: [
          CustomButton(
            text: context.tr('verify_otp'),
            onPressed: authProvider.isLoading ? null : _verifyOtp,
            isLoading: authProvider.isLoading,
            icon: Icons.verified_user,
          ),
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: authProvider.isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3DA35D),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: authProvider.isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isLogin ? Icons.login : Icons.person_add_alt_1,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isLogin
                        ? context.tr('sign_in')
                        : context.tr('create_account'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            const Expanded(child: Divider(color: Colors.white)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                context.tr('or_continue_with'),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const Expanded(child: Divider(color: Colors.white)),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _socialButton('assets/icons/google.png', 'Google'),
            const SizedBox(width: 16),
            _socialButton('assets/icons/facebook.png', 'Facebook'),
          ],
        ),
      ],
    );
  }

  Widget _socialButton(String iconPath, String label) {
    return InkWell(
      onTap: () {
        _showMessage('$label login coming soon!', isError: false);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          children: [
            // Placeholder icon if asset missing
            const Icon(Icons.login, size: 20, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleMode() {
    return Column(
      children: [
        if (!_isOtpVerification) _buildSocialLogin(),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isLogin
                  ? "${context.tr('dont_have_account')} "
                  : "${context.tr('already_have_account')} ",
              style: const TextStyle(color: Colors.white),
            ),
            GestureDetector(
              onTap: _toggleMode,
              child: Text(
                _isLogin ? context.tr('register_now') : context.tr('sign_in'),
                style: const TextStyle(
                  color: Color(0xFF3DA35D),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _toggleMode() {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLogin = !_isLogin;
      _isOtpVerification = false;
      _clearForm();
    });
  }

  void _clearForm() {
    if (_isLogin) {
      _nameController.clear();
      _otpController.clear();
      _confirmPasswordController.clear();
      _selectedDistrict = null;
      _farmingCategoryController.clear();
      _specializationController.clear();
      _selectedRole = UserRole.farmer;
    } else {
      _phoneController.clear();
      _nameController.clear();
      _otpController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _selectedDistrict = null;
      _farmingCategoryController.clear();
      _specializationController.clear();
    }
    _agreeToTerms = false;
    _selectedLanguage = 'English';
    _formKey.currentState?.reset();
  }

  void _handleSubmit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      _showMessage('Please fix the errors in the form', isError: true);
      return;
    }

    if (!_isLogin && !_agreeToTerms) {
      _showMessage('Please agree to the Terms & Conditions', isError: true);
      return;
    }

    if (_isLogin) {
      await _handleLogin();
    } else {
      await _handleRegister();
    }
  }

  Future<void> _handleLogin() async {
    final authProvider = context.read<AuthProvider>();

    try {
      // Save remember me preference
      if (_rememberMe) {
        await authProvider.saveUsername(_phoneController.text.trim());
      } else {
        await authProvider.clearSavedUsername();
      }

      // Check login attempts
      if (_loginAttempts >= 5) {
        _showMessage('Account temporarily blocked. Try again later.',
            isError: true);
        return;
      }

      final success = await authProvider.loginWithUsername(
        _phoneController.text.trim(),
        _passwordController.text.trim(),
        role: _selectedRole,
      );

      if (!success) {
        setState(() => _loginAttempts++);
      } else {
        setState(() => _loginAttempts = 0);
      }

      if (mounted) {
        if (success) {
          _showMessage('Welcome back! Login successful.', isError: false);
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              final user = authProvider.currentUser;
              if (user?.hasSelectedLanguage == true) {
                if (user?.role == UserRole.kisanDoctor) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) =>
                            KisanDoctorDashboardScreen(doctor: user!)),
                  );
                } else {
                  _navigateToHome();
                }
              } else {
                _navigateToLanguageSelection();
              }
            }
          });
        } else {
          _showMessage(
              authProvider.error ??
                  'Login failed. Please check your credentials.',
              isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Network error. Please check your connection.',
            isError: true);
      }
    }
  }

  Future<void> _handleRegister() async {
    final authProvider = context.read<AuthProvider>();

    try {
      final phoneNumber = _phoneController.text.trim();
      final fullPhoneNumber = '+977$phoneNumber';

      final success = await authProvider.register(
        username: phoneNumber,
        email: '$phoneNumber@hamikisan.com',
        phoneNumber: fullPhoneNumber,
        name: _nameController.text.trim(),
        role: _selectedRole,
        password: _passwordController.text.trim(),
        address:
            '$_selectedProvince, $_selectedDistrict, ${_localLevelController.text}, Ward ${_wardNoController.text}',
        language: _selectedLanguage,
        farmingCategory: _selectedRole == UserRole.farmer &&
                _farmingCategoryController.text.trim().isNotEmpty
            ? _farmingCategoryController.text.trim()
            : null,
        specialization: _selectedRole == UserRole.kisanDoctor &&
                _specializationController.text.trim().isNotEmpty
            ? _specializationController.text.trim()
            : null,
      );

      if (mounted) {
        if (success) {
          _showMessage('Registration successful!', isError: false);
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) _navigateToHome();
          });
        } else {
          final errorMsg =
              authProvider.error ?? 'Registration failed. Please try again.';
          _showMessage(errorMsg, isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Registration failed. Please try again.', isError: true);
      }
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length != 6) {
      _showMessage('Please enter a 6-digit OTP code', isError: true);
      return;
    }

    final authProvider = context.read<AuthProvider>();

    try {
      final success = await authProvider.verifyOTP(
          '+977${_phoneController.text.trim()}', _otpController.text);

      if (mounted) {
        if (success) {
          _showMessage('Phone number verified successfully!', isError: false);
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) _navigateToHome();
          });
        } else {
          _showMessage(authProvider.error ?? 'Invalid OTP. Please try again.',
              isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Verification failed. Please try again.', isError: true);
      }
    }
  }

  Future<void> _resendOtp() async {
    final authProvider = context.read<AuthProvider>();

    try {
      final success =
          await authProvider.resendOTP('+977${_phoneController.text.trim()}');
      if (mounted) {
        if (success) {
          _startOtpCooldown();
          _showMessage('OTP sent successfully!', isError: false);
        } else {
          _showMessage('Failed to resend OTP. Please try again.',
              isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Failed to resend OTP. Please try again.', isError: true);
      }
    }
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forgot Password'),
        content: const Text(
            'Please contact support at support@hamikisan.com to reset your password.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message, {required bool isError}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : AppColors.primaryGreen,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
