import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Displays the current attendance status for a student on the Scan tab.
enum AttendanceStatusType { notRecorded, present, late, absent }

class AttendanceStatusCard extends StatelessWidget {
  final AttendanceStatusType status;
  final String? timeIn;
  final String? studentName;
  final String? sessionInfo;

  const AttendanceStatusCard({
    super.key,
    required this.status,
    this.timeIn,
    this.studentName,
    this.sessionInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: _borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_icon, color: _iconColor, size: 22),
              const SizedBox(width: 8),
              Text(
                "Today's Attendance",
                style: AppTextStyles.titleMedium.copyWith(color: _iconColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _statusLabel,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _iconColor,
              letterSpacing: 0.5,
            ),
          ),
          if (timeIn != null) ...[
            const SizedBox(height: 4),
            Text(
              timeIn!,
              style: AppTextStyles.bodyMedium.copyWith(color: _iconColor.withValues(alpha: 0.8)),
            ),
          ],
          if (sessionInfo != null && status == AttendanceStatusType.notRecorded) ...[
            const SizedBox(height: 6),
            Text(
              sessionInfo!,
              style: AppTextStyles.bodySmall.copyWith(color: _iconColor.withValues(alpha: 0.7)),
            ),
          ],
        ],
      ),
    );
  }

  String get _statusLabel {
    switch (status) {
      case AttendanceStatusType.notRecorded:
        return 'NOT YET RECORDED';
      case AttendanceStatusType.present:
        return 'PRESENT ✓';
      case AttendanceStatusType.late:
        return 'LATE';
      case AttendanceStatusType.absent:
        return 'ABSENT';
    }
  }

  Color get _bgColor {
    switch (status) {
      case AttendanceStatusType.notRecorded:
        return AppColors.surfaceVariant;
      case AttendanceStatusType.present:
        return AppColors.successBg;
      case AttendanceStatusType.late:
        return AppColors.lateBg;
      case AttendanceStatusType.absent:
        return AppColors.absentBg;
    }
  }

  Color get _iconColor {
    switch (status) {
      case AttendanceStatusType.notRecorded:
        return AppColors.textSecondary;
      case AttendanceStatusType.present:
        return AppColors.success;
      case AttendanceStatusType.late:
        return AppColors.late;
      case AttendanceStatusType.absent:
        return AppColors.absent;
    }
  }

  Color get _borderColor {
    switch (status) {
      case AttendanceStatusType.notRecorded:
        return AppColors.divider;
      case AttendanceStatusType.present:
        return AppColors.successAccent.withValues(alpha: 0.4);
      case AttendanceStatusType.late:
        return AppColors.late.withValues(alpha: 0.4);
      case AttendanceStatusType.absent:
        return AppColors.absent.withValues(alpha: 0.4);
    }
  }

  IconData get _icon {
    switch (status) {
      case AttendanceStatusType.notRecorded:
        return Icons.schedule_outlined;
      case AttendanceStatusType.present:
        return Icons.check_circle_outline;
      case AttendanceStatusType.late:
        return Icons.watch_later_outlined;
      case AttendanceStatusType.absent:
        return Icons.cancel_outlined;
    }
  }
}
