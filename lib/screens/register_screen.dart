import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedRole = 'farmer';
  String? _selectedFarmingCategory;
  String? _selectedSpecialization;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;

  final List<String> _farmingCategories = [
    'Rice / धान',
    'Wheat / गहूँ',
    'Maize / मकै',
    'Potato / आलु',
    'Vegetables / तरकारी',
    'Fruits / फलफूल',
    'Mixed Farming / मिश्रित खेती',
    'Dairy / डेरी',
    'Poultry / कुखुरा',
    'Other / अन्य',
  ];

  final List<String> _doctorSpecializations = [
    'Plant Pathology',
    'Soil Science',
    'Agronomy',
    'Horticulture',
    'Animal Husbandry',
    'Entomology',
    'Plant Breeding',
    'Extension Education',
    'Agricultural Economics',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Header Section
              Container(
                width: double.infinity,
                color: const Color(0xFF4CAF50),
                padding: const EdgeInsets.all(16),
                child: const Column(
                  children: [
                    Icon(
                      Icons.agriculture,
                      size: 40,
                      color: Colors.white,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Join HamiKisan',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'हामीकिसानमा सामेल हुनुहोस्',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              // Form Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Role Selection
                      _buildRoleSelection(),
                      const SizedBox(height: 20),

                      // Basic Info
                      _buildBasicInfoSection(),
                      const SizedBox(height: 20),

                      // Role-specific Info
                      if (_selectedRole == 'farmer') ...[
                        _buildFarmerSpecificSection(),
                        const SizedBox(height: 20),
                      ],

                      if (_selectedRole == 'doctor') ...[
                        _buildDoctorSpecificSection(),
                        const SizedBox(height: 20),
                      ],

                      // Address
                      _buildAddressSection(),
                      const SizedBox(height: 20),

                      // Password
                      _buildPasswordSection(),
                      const SizedBox(height: 20),

                      // Terms
                      _buildTermsAndConditions(),
                      const SizedBox(height: 24),

                      // Register Button
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          return SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: (authProvider.isLoading || !_agreedToTerms) 
                                  ? null 
                                  : _handleRegister,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF50),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: authProvider.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Create Account / खाता बनाउनुहोस्',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                color: Color(0xFF4CAF50),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'I am a:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildRoleCard(
                value: 'farmer',
                icon: Icons.agriculture,
                title: 'Farmer / किसान',
                subtitle: 'For farming activities',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRoleCard(
                value: 'doctor',
                icon: Icons.medical_services,
                title: 'Agriculture Expert / विशेषज्ञ',
                subtitle: 'Provide expert advice',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleCard({
    required String value,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedRole == value;

    return GestureDetector(
      onTap: () => setState(() => _selectedRole = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E8) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade600,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFF4CAF50) : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic Information / आधारभूत जानकारी',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _nameController,
          label: 'Full Name / पूरा नाम',
          hint: 'Enter your full name',
          icon: Icons.person,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: 'Email / इमेल',
          hint: 'Enter your email address',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _phoneController,
          label: 'Phone Number / फोन नम्बर',
          hint: '98XXXXXXXX (10 digits)',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          validator: _validatePhone,
        ),
      ],
    );
  }

  Widget _buildFarmerSpecificSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Farming Information / कृषि सम्बन्धी जानकारी',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          label: 'Farming Category / कृषि विभाग',
          value: _selectedFarmingCategory,
          items: _farmingCategories,
          onChanged: (value) =>
              setState(() => _selectedFarmingCategory = value),
        ),
      ],
    );
  }

  Widget _buildDoctorSpecificSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Professional Information / व्यावसायिक जानकारी',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          label: 'Specialization / विशेषज्ञता',
          value: _selectedSpecialization,
          items: _doctorSpecializations,
          onChanged: (value) => setState(() => _selectedSpecialization = value),
        ),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Address / ठेगाना',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _addressController,
          label: 'Address / ठेगाना',
          hint: 'Enter your address',
          icon: Icons.location_on,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildPasswordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password / पासवर्ड',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _passwordController,
          label: 'Password / पासवर्ड',
          hint: '8+ chars, A-z, 0-9, !@#$',
          icon: Icons.lock,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _confirmPasswordController,
          label: 'Confirm Password / पासवर्ड पुष्टि गर्नुहोस्',
          hint: 'Confirm your password',
          icon: Icons.lock,
          obscureText: _obscureConfirmPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () => setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword),
          ),
        ),
      ],
    );
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    var cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Remove country code if present
    if (cleaned.startsWith('977') && cleaned.length == 13) {
      cleaned = cleaned.substring(3);
    }
    
    if (cleaned.length != 10) {
      return 'Phone number must be 10 digits';
    }
    if (!cleaned.startsWith('9')) {
      return 'Phone number must start with 9';
    }
    return null;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    int maxLines = 1,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        if (label.contains('Email') && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email';
        }
        if (label.contains('Password') && !label.contains('Confirm')) {
          if (value.length < 8) return 'Password must be at least 8 characters';
          if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Must contain uppercase letter';
          if (!RegExp(r'[a-z]').hasMatch(value)) return 'Must contain lowercase letter';
          if (!RegExp(r'[0-9]').hasMatch(value)) return 'Must contain number';
          if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) return 'Must contain special character';
        }
        if (label.contains('Confirm') && value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              ))
          .toList(),
      onChanged: onChanged,
      validator: (value) {
        if (_selectedRole == 'farmer' && label.contains('Farming') && (value == null || value.isEmpty)) {
          return 'Please select farming category';
        }
        if (_selectedRole == 'doctor' && label.contains('Specialization') && (value == null || value.isEmpty)) {
          return 'Please select specialization';
        }
        return null;
      },
    );
  }

  Widget _buildTermsAndConditions() {
    return Row(
      children: [
        Checkbox(
          value: _agreedToTerms,
          onChanged: (bool? newValue) {
            setState(() {
              _agreedToTerms = newValue ?? false;
            });
          },
          activeColor: const Color(0xFF4CAF50),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _agreedToTerms = !_agreedToTerms;
              });
            },
            child: const Text(
              'I agree to the Terms and Conditions',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate() || !_agreedToTerms) {
      if (!_agreedToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must agree to the Terms and Conditions.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    AuthResult result;

    if (_selectedRole == 'farmer') {
      result = await authProvider.registerFarmer(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
        address: _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : null,
        farmingCategory: _selectedFarmingCategory,
      );
    } else {
      result = await authProvider.registerDoctor(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
        specialization: _selectedSpecialization!,
      );
    }

    if (result.success && mounted) {
      // Navigate back to login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! Please login.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
