import 'package:flutter/material.dart';
import 'dart:math';
import '../utils/app_colors.dart';

class AdminShield extends StatelessWidget {
  final double size;
  final Color? color;

  const AdminShield({
    super.key,
    this.size = 100,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            (color ?? AppColors.secondary).withValues(alpha: 0.2),
            (color ?? AppColors.secondary).withValues(alpha: 0.05),
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer circle
          Container(
            width: size * 0.9,
            height: size * 0.9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: (color ?? AppColors.secondary).withValues(alpha: 0.3),
                width: 2,
              ),
            ),
          ),

          // Middle circle
          Container(
            width: size * 0.7,
            height: size * 0.7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: (color ?? AppColors.secondary).withValues(alpha: 0.5),
                width: 2,
              ),
            ),
          ),

          // Inner circle with icon
          Container(
            width: size * 0.5,
            height: size * 0.5,
            decoration: BoxDecoration(
              color: (color ?? AppColors.secondary).withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: color ?? AppColors.secondary,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.admin_panel_settings,
              size: size * 0.25,
              color: color ?? AppColors.secondary,
            ),
          ),

          // Shield effect
          CustomPaint(
            size: Size(size, size),
            painter: _ShieldPainter(color: color ?? AppColors.secondary),
          ),
        ],
      ),
    );
  }
}

class _ShieldPainter extends CustomPainter {
  final Color color;

  _ShieldPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw shield pattern
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * (3.1415926535 / 180);
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);

      path.moveTo(center.dx, center.dy);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
