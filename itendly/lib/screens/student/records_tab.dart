import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/student.dart';
import '../../models/attendance_record.dart';
import '../../services/mock_database_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/attendance_record_tile.dart';
import '../../widgets/empty_state.dart';

/// Student Records Tab — shows attendance summary and history.
class RecordsTab extends StatefulWidget {
  final Student student;

  const RecordsTab({super.key, required this.student});

  @override
  State<RecordsTab> createState() => _RecordsTabState();
}

class _RecordsTabState extends State<RecordsTab> {
  String _filter = 'All'; // All | Present | Absent | Late
  final List<String> _filters = ['All', 'Present', 'Absent', 'Late'];

  List<AttendanceRecord> _applyFilter(List<AttendanceRecord> records) {
    if (_filter == 'All') return records;
    return records
        .where((r) => r.status.toLowerCase() == _filter.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabaseService>();
    final history = db.getStudentAttendanceHistory(widget.student.id);
    final summary = db.getStudentAttendanceSummary(widget.student.id);
    final filtered = _applyFilter(history);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Records'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Sign out',
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/role-selection'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary card
          Container(
            margin: const EdgeInsets.all(AppSpacing.horizontal),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(AppRadius.large),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.student.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.student.id,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _SummaryChip(
                        label: 'Present',
                        count: summary['present'] ?? 0,
                        color: Colors.greenAccent.shade700),
                    const SizedBox(width: 12),
                    _SummaryChip(
                        label: 'Absent',
                        count: summary['absent'] ?? 0,
                        color: Colors.redAccent.shade100),
                    const SizedBox(width: 12),
                    _SummaryChip(
                        label: 'Late',
                        count: summary['late'] ?? 0,
                        color: Colors.orangeAccent.shade100),
                  ],
                ),
              ],
            ),
          ),

          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.horizontal, vertical: 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters
                    .map(
                      (f) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(f),
                          selected: _filter == f,
                          onSelected: (_) => setState(() => _filter = f),
                          selectedColor: AppColors.primaryContainer,
                          labelStyle: TextStyle(
                            color: _filter == f
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight: _filter == f
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),

          // Records list
          Expanded(
            child: filtered.isEmpty
                ? EmptyState(
                    icon: Icons.history_toggle_off_outlined,
                    title: 'No Records',
                    description: _filter == 'All'
                        ? 'No attendance records yet.\nScan a QR code to get started.'
                        : 'No "$_filter" records found.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.horizontal,
                      vertical: 8,
                    ),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, index) => AttendanceRecordTile(
                      record: filtered[index],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SummaryChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            color: color,
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
