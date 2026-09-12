import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/attendance_record.dart';
import '../theme/app_theme.dart';

/// A list tile showing a single attendance record entry.
class AttendanceRecordTile extends StatelessWidget {
  final AttendanceRecord record;

  /// Optional: student name to show (for teacher's view)
  final String? studentName;

  const AttendanceRecordTile({
    super.key,
    required this.record,
    this.studentName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14,
        ),
        child: Row(
          children: [
            // Status icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _bgColor,
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              child: Icon(_icon, color: _iconColor, size: 22),
            ),

            const SizedBox(width: 12),

            // Date + student name (optional)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (studentName != null)
                    Text(
                      studentName!,
                      style: AppTextStyles.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text(
                    DateFormat('MMMM d, yyyy').format(record.date),
                    style: studentName != null
                        ? AppTextStyles.bodySmall
                        : AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    record.timeIn != null
                        ? DateFormat('h:mm a').format(record.timeIn!)
                        : '—',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),

            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: _bgColor,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(color: _iconColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                _statusLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _iconColor,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _statusLabel => record.status.toUpperCase();

  Color get _bgColor {
    if (record.isPresent) return AppColors.successBg;
    if (record.isLate) return AppColors.lateBg;
    return AppColors.absentBg;
  }

  Color get _iconColor {
    if (record.isPresent) return AppColors.successAccent;
    if (record.isLate) return AppColors.late;
    return AppColors.absent;
  }

  IconData get _icon {
    if (record.isPresent) return Icons.check_circle_outline;
    if (record.isLate) return Icons.watch_later_outlined;
    return Icons.cancel_outlined;
  }
}
