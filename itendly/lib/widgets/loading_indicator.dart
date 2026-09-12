import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Centered loading indicator with optional label.
class LoadingIndicator extends StatelessWidget {
  final String? label;

  const LoadingIndicator({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            strokeWidth: 3,
            color: AppColors.primary,
          ),
          if (label != null) ...[
            const SizedBox(height: 16),
            Text(label!, style: AppTextStyles.bodyMedium),
          ],
        ],
      ),
    );
  }
}

/// Full-screen overlay loading indicator for async operations.
class FullScreenLoader extends StatelessWidget {
  final String? label;

  const FullScreenLoader({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LoadingIndicator(label: label ?? 'Loading...'),
    );
  }
}
