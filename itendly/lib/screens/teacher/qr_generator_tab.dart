import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/teacher.dart';
import '../../models/attendance_session.dart';
import '../../services/mock_database_service.dart';
import '../../services/qr_export_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/qr_display_card.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/empty_state.dart';

/// Teacher QR Generator Tab — generates, displays, and manages attendance sessions.
class QrGeneratorTab extends StatefulWidget {
  final Teacher teacher;
  final VoidCallback onLogout;

  const QrGeneratorTab({
    super.key,
    required this.teacher,
    required this.onLogout,
  });

  @override
  State<QrGeneratorTab> createState() => _QrGeneratorTabState();
}

class _QrGeneratorTabState extends State<QrGeneratorTab> {
  bool _isGenerating = false;
  bool _isEnding = false;
  bool _isSaving = false;
  final _qrExportService = const QrExportService();
  final _qrBoundaryKey = GlobalKey();

  Future<void> _generateQr() async {
    // If active session exists, confirm replacement
    final db = context.read<MockDatabaseService>();
    if (db.activeSession != null) {
      final confirmed = await ConfirmationDialog.show(
        context: context,
        title: 'Generate New QR?',
        message:
            'This will end the current session and create a new one.\nStudents will need to scan the new QR.',
        confirmLabel: 'Generate',
        cancelLabel: 'Cancel',
        icon: Icons.refresh,
      );
      if (confirmed != true) return;
    }

    setState(() => _isGenerating = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    context.read<MockDatabaseService>().createSession(widget.teacher.id);
    setState(() => _isGenerating = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('New attendance session created')),
    );
  }

  Future<void> _endSession(AttendanceSession session) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'End Session?',
      message:
          'Students will no longer be able to scan this QR.\nYou can generate a new QR at any time.',
      confirmLabel: 'End Session',
      cancelLabel: 'Cancel',
      isDestructive: true,
      icon: Icons.stop_circle_outlined,
    );
    if (confirmed != true) return;

    setState(() => _isEnding = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    context.read<MockDatabaseService>().endSession(session.id);
    setState(() => _isEnding = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Session ended. QR is now invalid.')),
    );
  }

  Future<void> _saveQr() async {
    setState(() => _isSaving = true);
    final result = await _qrExportService.saveQrImage(_qrBoundaryKey);
    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabaseService>();
    final session = db.activeSession;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const AppLogo(size: 28, showSubtitle: false),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Sign out',
            onPressed: widget.onLogout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.horizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Teacher greeting
            const SizedBox(height: 8),
            Text('Class Attendance', style: AppTextStyles.headlineMedium),
            Text(
              'BSIT 4-5 • ${DateFormat('MMMM d, yyyy').format(DateTime.now())}',
              style: AppTextStyles.bodyMedium,
            ),

            const SizedBox(height: 20),

            // Session status badge
            _SessionStatusBadge(session: session),

            const SizedBox(height: 20),

            // QR display or empty state
            if (session != null) ...[
              RepaintBoundary(
                key: _qrBoundaryKey,
                child: QrDisplayCard(qrData: session.toQrPayload()),
              ),
              const SizedBox(height: 12),
              // Expiry info
              Row(
                children: [
                  const Icon(Icons.timer_outlined,
                      size: 16, color: AppColors.textTertiary),
                  const SizedBox(width: 6),
                  Text(
                    'Expires: ${DateFormat('h:mm a').format(session.expiresAt)}',
                    style: AppTextStyles.bodySmall,
                  ),
                  const Spacer(),
                  Text(
                    'Session ID: ${session.id.split('-').last}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ] else ...[
              const EmptyState(
                icon: Icons.qr_code_outlined,
                title: 'No Active Session',
                description:
                    'Generate a QR code to start an attendance session.\nStudents will scan this QR to mark their presence.',
              ),
            ],

            const SizedBox(height: 24),

            // Action buttons
            PrimaryButton(
              label: session != null ? 'GENERATE NEW QR' : 'GENERATE QR',
              isLoading: _isGenerating,
              icon: Icons.refresh,
              onPressed: _generateQr,
            ),

            if (session != null) ...[
              const SizedBox(height: 12),
              SecondaryButton(
                label: 'SAVE QR',
                icon: Icons.download_outlined,
                isLoading: _isSaving,
                onPressed: _saveQr,
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                label: 'END SESSION',
                icon: Icons.stop_circle_outlined,
                color: AppColors.error,
                isLoading: _isEnding,
                onPressed: () => _endSession(session),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

/// Session status indicator badge.
class _SessionStatusBadge extends StatelessWidget {
  final AttendanceSession? session;

  const _SessionStatusBadge({this.session});

  @override
  Widget build(BuildContext context) {
    final isActive = session?.isActive == true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? AppColors.successBg : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: isActive
              ? AppColors.successAccent.withValues(alpha: 0.4)
              : AppColors.divider,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color:
                  isActive ? AppColors.successAccent : AppColors.textTertiary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isActive ? 'SESSION ACTIVE' : 'NO ACTIVE SESSION',
            style: TextStyle(
              color: isActive ? AppColors.success : AppColors.textTertiary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
