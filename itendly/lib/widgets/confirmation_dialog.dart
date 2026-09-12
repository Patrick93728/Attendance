import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable confirmation dialog for destructive or important actions.
///
/// Usage:
/// ```dart
/// final confirmed = await ConfirmationDialog.show(
///   context: context,
///   title: 'Delete student?',
///   message: 'This will remove the student from the current mock data.',
///   confirmLabel: 'Delete',
///   isDestructive: true,
/// );
/// if (confirmed == true) { ... }
/// ```
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;
  final IconData? icon;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.isDestructive = false,
    this.icon,
  });

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
    IconData? icon,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ConfirmationDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
        icon: icon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final confirmColor = isDestructive ? AppColors.error : AppColors.primary;

    return AlertDialog(
      icon: icon != null
          ? Icon(
              icon,
              color: isDestructive ? AppColors.error : AppColors.primary,
              size: 32,
            )
          : null,
      title: Text(title, style: AppTextStyles.titleLarge, textAlign: TextAlign.center),
      content: Text(
        message,
        style: AppTextStyles.bodyMedium,
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel, style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(foregroundColor: confirmColor),
          child: Text(confirmLabel, style: AppTextStyles.labelLarge.copyWith(color: confirmColor)),
        ),
      ],
    );
  }
}
