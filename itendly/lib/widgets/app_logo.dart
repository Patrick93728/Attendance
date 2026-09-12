import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// ATTENDLY branding logo — person figure + "TTENDLY" text.
/// The person icon acts as the "A" in "ATTENDLY".
class AppLogo extends StatelessWidget {
  final double size;
  final bool showSubtitle;
  final Color? primaryColor;

  const AppLogo({
    super.key,
    this.size = 80,
    this.showSubtitle = true,
    this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    // Person figure color = steel blue, text color = dark navy
    const personColor = Color(0xFF5B9BD5);
    final textColor = primaryColor ?? const Color(0xFF0D2E4D);

    final personWidth = size * 0.38;
    final textSize = size * 0.46;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Row: person icon + "TTENDLY" text (person acts as the "A")
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Person figure drawn with CustomPaint
            SizedBox(
              width: personWidth,
              height: size,
              child: CustomPaint(
                painter: _PersonFigurePainter(color: personColor),
              ),
            ),

            // "TTENDLY" — the person above is the "A"
            Text(
              'TTENDLY',
              style: TextStyle(
                fontSize: textSize,
                fontWeight: FontWeight.w900,
                color: textColor,
                letterSpacing: 1.5,
                height: 1.0,
              ),
            ),
          ],
        ),

        if (showSubtitle) ...[
          const SizedBox(height: 6),
          Text(
            'Smart Attendance System',
            style: AppTextStyles.bodySmall.copyWith(
              letterSpacing: 0.8,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ],
    );
  }
}

/// Paints a simple person figure (circle head + body with arch legs).
class _PersonFigurePainter extends CustomPainter {
  final Color color;

  const _PersonFigurePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Head — circle at top center
    final headRadius = w * 0.28;
    final headCenterY = headRadius + h * 0.02;
    canvas.drawCircle(Offset(w / 2, headCenterY), headRadius, paint);

    // Body — rounded rect that tapers into the "arch" legs shape
    // We draw the body as two rectangles forming a pill-like torso
    // then two rounded legs with an arch cut in the middle.

    final torsoTop = headCenterY + headRadius + h * 0.03;
    final torsoBottom = h * 0.60;
    final torsoLeft = w * 0.15;
    final torsoRight = w * 0.85;

    // Torso
    final torsoRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(torsoLeft, torsoTop, torsoRight, torsoBottom),
      Radius.circular(w * 0.18),
    );
    canvas.drawRRect(torsoRect, paint);

    // Left leg
    final legWidth = (w * 0.70) / 2 - w * 0.04;
    final legTop = torsoBottom - w * 0.06;
    final legBottom = h * 0.98;

    final leftLegRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(torsoLeft, legTop, torsoLeft + legWidth, legBottom),
      Radius.circular(w * 0.12),
    );
    canvas.drawRRect(leftLegRect, paint);

    // Right leg
    final rightLegRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(
          torsoRight - legWidth, legTop, torsoRight, legBottom),
      Radius.circular(w * 0.12),
    );
    canvas.drawRRect(rightLegRect, paint);

    // Cut arch between legs (erase center)
    final archPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final archLeft = torsoLeft + legWidth;
    final archRight = torsoRight - legWidth;
    final archTop = torsoBottom;
    final archBottom = legBottom + w * 0.10;

    final archRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(archLeft, archTop, archRight, archBottom),
      Radius.circular(w * 0.10),
    );
    canvas.drawRRect(archRect, archPaint);
  }

  @override
  bool shouldRepaint(_PersonFigurePainter old) => old.color != color;
}
