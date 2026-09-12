import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// ITENDLY branding logo widget — logo mark, app name, and optional subtitle.
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
    final color = primaryColor ?? AppColors.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo mark — rounded square with "IT" initials
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color,
                Color.lerp(color, Colors.black, 0.2)!,
              ],
            ),
            borderRadius: BorderRadius.circular(size * 0.22),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'IT',
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.36,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
          ),
        ),

        SizedBox(height: size * 0.18),

        // App name
        Text(
          'ITENDLY',
          style: TextStyle(
            fontSize: size * 0.38,
            fontWeight: FontWeight.w900,
            color: color,
            letterSpacing: size * 0.06,
          ),
        ),

        if (showSubtitle) ...[
          const SizedBox(height: 4),
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
