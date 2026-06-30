import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';

class DottedBackground extends StatelessWidget {
  const DottedBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DottedBackgroundPainter(),
      size: Size.infinite,
    );
  }
}

class _DottedBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.borderGray.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    for (double x = 0; x <= size.width; x += 24) {
      for (double y = 0; y <= size.height; y += 24) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
