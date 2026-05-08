import 'package:flutter/material.dart';
import 'package:insight_hub/core/constant/app_colors.dart';

class AnalyticsLogo extends StatelessWidget {
  const AnalyticsLogo({super.key, this.size = 130});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _AnalyticsLogoPainter(),
      ),
    );
  }
}

class _AnalyticsLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bluePaint =
        Paint()
          ..color = AppColors.primaryBlue
          ..style = PaintingStyle.fill;

    final whitePaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = size.width * 0.05;

    // Background
    final bg = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.width * 0.18),
    );

    canvas.drawRRect(bg, bluePaint);

    // Axes
    final axis = Path()
      ..moveTo(size.width * 0.28, size.height * 0.28)
      ..lineTo(size.width * 0.28, size.height * 0.72)
      ..lineTo(size.width * 0.72, size.height * 0.72);

    canvas.drawPath(axis, whitePaint);

    // Small bar
    canvas.drawLine(
      Offset(size.width * 0.40, size.height * 0.62),
      Offset(size.width * 0.40, size.height * 0.55),
      whitePaint,
    );

    // Tall bar
    canvas.drawLine(
      Offset(size.width * 0.52, size.height * 0.62),
      Offset(size.width * 0.52, size.height * 0.36),
      whitePaint,
    );

    // Medium bar
    canvas.drawLine(
      Offset(size.width * 0.65, size.height * 0.62),
      Offset(size.width * 0.65, size.height * 0.46),
      whitePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}