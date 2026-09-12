import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/teacher.dart';
import '../../services/fruitask_database_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/attendance_record_tile.dart';
import '../../widgets/empty_state.dart';

/// Teacher Records Tab — view attendance by today or a selected date.
class TeacherRecordsTab extends StatefulWidget {
  final Teacher teacher;
  final VoidCallback onLogout;

  const TeacherRecordsTab({
    super.key,
    required this.teacher,
    required this.onLogout,
  });

  @override
  State<TeacherRecordsTab> createState() => _TeacherRecordsTabState();
}

class _TeacherRecordsTabState extends State<TeacherRecordsTab> {
  DateTime _selectedDate = DateTime.now();
  bool _isToday = true;

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _isToday = _isSameDay(picked, DateTime.now());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = context.watch<FruitaskDatabaseService>();
    final records = db.getAttendanceForDate(_selectedDate);
    final students = db.students;

    // Count stats
    final presentCount = records.where((r) => r.isPresent).length;
    final absentCount = records.where((r) => r.isAbsent).length;
    final lateCount = records.where((r) => r.isLate).length;

    // Build display list with student names
    final studentsById = {for (final student in students) student.id: student};
    final displayRecords = records.map((r) {
      final student = studentsById[r.studentId];
      final studentName =
          student?.displayName ?? 'Deleted student (${r.studentId})';
      return (record: r, studentName: studentName);
    }).toList()
      ..sort((a, b) => a.studentName.compareTo(b.studentName));

    final dateLabel = _isToday
        ? "Today's Attendance"
        : DateFormat('MMMM d, yyyy').format(_selectedDate);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Attendance Records'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh from Fruitask',
            onPressed: () async {
              await context.read<FruitaskDatabaseService>().initialize();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Sign out',
            onPressed: widget.onLogout,
          ),
        ],
      ),
      body: Column(
        children: [
          // Date selector
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.horizontal,
              vertical: 8,
            ),
            child: Row(
              children: [
                // Today button
                Expanded(
                  child: _DateButton(
                    label: 'Today',
                    isSelected: _isToday,
                    icon: Icons.today,
                    onTap: () => setState(() {
                      _selectedDate = DateTime.now();
                      _isToday = true;
                    }),
                  ),
                ),
                const SizedBox(width: 12),
                // Select date button
                Expanded(
                  child: _DateButton(
                    label: _isToday
                        ? 'Select Date'
                        : DateFormat('MMM d').format(_selectedDate),
                    isSelected: !_isToday,
                    icon: Icons.calendar_month_outlined,
                    onTap: _pickDate,
                  ),
                ),
              ],
            ),
          ),

          // Summary stats
          if (records.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.horizontal,
                vertical: 4,
              ),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _StatChip(
                              label: 'Present',
                              count: presentCount,
                              color: AppColors.successAccent,
                            ),
                          ),
                          Expanded(
                            child: _StatChip(
                              label: 'Absent',
                              count: absentCount,
                              color: AppColors.absent,
                            ),
                          ),
                          Expanded(
                            child: _StatChip(
                              label: 'Late',
                              count: lateCount,
                              color: AppColors.late,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dateLabel,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Records list
          Expanded(
            child: records.isEmpty
                ? EmptyState(
                    icon: Icons.event_busy_outlined,
                    title: 'No Records',
                    description: _isToday
                        ? 'No attendance has been recorded today.\nGenerate a QR code to start a session.'
                        : 'No attendance records for ${DateFormat('MMMM d, yyyy').format(_selectedDate)}.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.horizontal,
                      vertical: 8,
                    ),
                    itemCount: displayRecords.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => AttendanceRecordTile(
                      record: displayRecords[i].record,
                      studentName: displayRecords[i].studentName,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final IconData icon;
  final VoidCallback onTap;

  const _DateButton({
    required this.label,
    required this.isSelected,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
