import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_logo.dart';

/// First screen — the user chooses STUDENT or TEACHER role.
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.horizontal,
          ),
          child: Column(
            children: [
              const SizedBox(height: 72),

              // Branding
              const AppLogo(size: 88),

              const SizedBox(height: 64),

              // Section label
              Text(
                'Choose your role to continue',
                style: AppTextStyles.bodyMedium.copyWith(
                  letterSpacing: 0.3,
                ),
              ),

              const SizedBox(height: 32),

              // STUDENT button
              _RoleCard(
                icon: Icons.school_outlined,
                label: 'STUDENT',
                description: 'Scan QR to record your attendance',
                onTap: () => Navigator.pushNamed(context, '/student/identity'),
              ),

              const SizedBox(height: 16),

              // TEACHER button
              _RoleCard(
                icon: Icons.person_outline,
                label: 'TEACHER',
                description: 'Manage students and generate QR codes',
                onTap: () => Navigator.pushNamed(context, '/teacher/login'),
              ),

              const SizedBox(height: 48),

              // Footer
              const Text(
                'ATTENDLY v1.0 — Prototype',
                style: AppTextStyles.caption,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: Icon(icon, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.primary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
