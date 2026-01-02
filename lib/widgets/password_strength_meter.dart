import 'package:flutter/material.dart';

class PasswordStrengthMeter extends StatelessWidget {
  final String password;

  const PasswordStrengthMeter({super.key, required this.password});

  double get _strength {
    double strength = 0;
    if (password.length > 6) strength += 0.2;
    if (password.length > 10) strength += 0.2;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.2;
    return strength;
  }

  Color get _color {
    if (_strength <= 0.2) return Colors.red;
    if (_strength <= 0.4) return Colors.orange;
    if (_strength <= 0.6) return Colors.yellow;
    if (_strength <= 0.8) return Colors.lightGreen;
    return Colors.green;
  }

  String get _label {
    if (password.isEmpty) return '';
    if (_strength <= 0.2) return 'Weak';
    if (_strength <= 0.4) return 'Fair';
    if (_strength <= 0.6) return 'Good';
    if (_strength <= 0.8) return 'Strong';
    return 'Excellent';
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: _strength,
          backgroundColor: Colors.grey.shade300,
          color: _color,
          minHeight: 5,
          borderRadius: BorderRadius.circular(2.5),
        ),
        const SizedBox(height: 4),
        Text(
          _label,
          style: TextStyle(
            color: _color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
