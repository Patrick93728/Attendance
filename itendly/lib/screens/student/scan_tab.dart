import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/student.dart';
import '../../models/attendance_record.dart';
import '../../services/mock_database_service.dart';
import '../../services/qr_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/attendance_status_card.dart';
import '../../widgets/app_buttons.dart';

enum _ScanResult { success, duplicate, invalid, noSession }

/// Student Scan Tab — shows attendance status and QR scanner button.
class ScanTab extends StatefulWidget {
  final Student student;

  const ScanTab({super.key, required this.student});

  @override
  State<ScanTab> createState() => _ScanTabState();
}

class _ScanTabState extends State<ScanTab> {
  AttendanceRecord? _todayRecord;
  bool _isScanning = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshTodayRecord();
    });
  }

  void _refreshTodayRecord() {
    final db = context.read<MockDatabaseService>();
    final today = DateTime.now();
    final records = db.getAttendanceForDate(today);
    setState(() {
      try {
        _todayRecord = records.firstWhere(
          (r) => r.studentId == widget.student.id,
        );
      } catch (_) {
        _todayRecord = null;
      }
    });
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  AttendanceStatusType get _statusType {
    if (_todayRecord == null) return AttendanceStatusType.notRecorded;
    if (_todayRecord!.isPresent) return AttendanceStatusType.present;
    if (_todayRecord!.isLate) return AttendanceStatusType.late;
    return AttendanceStatusType.absent;
  }

  void _openScanner() {
    setState(() => _isScanning = true);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _QrScannerSheet(
        onScan: (rawValue) {
          Navigator.of(ctx).pop();
          setState(() => _isScanning = false);
          _processScan(rawValue);
        },
        onClose: () {
          Navigator.of(ctx).pop();
          setState(() => _isScanning = false);
        },
      ),
    ).whenComplete(() {
      if (mounted) setState(() => _isScanning = false);
    });
  }

  Future<void> _processScan(String rawValue) async {
    final db = context.read<MockDatabaseService>();

    // Parse QR
    final payload = QrService.parseQrCode(rawValue);
    if (payload == null) {
      _showResultDialog(_ScanResult.invalid);
      return;
    }

    // Validate session is active in DB
    final session = db.validateSession(payload.sessionId);
    if (session == null) {
      _showResultDialog(_ScanResult.noSession);
      return;
    }

    // Check for duplicate attendance
    final existing = db.getAttendanceForStudentSession(
      widget.student.id,
      session.id,
    );
    if (existing != null) {
      _showResultDialog(_ScanResult.duplicate);
      return;
    }

    // Record attendance
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
    final record = db.recordAttendance(
      studentId: widget.student.id,
      sessionId: session.id,
    );

    setState(() {
      _todayRecord = record;
      _isSaving = false;
    });

    _showResultDialog(_ScanResult.success, record: record);
  }

  void _showResultDialog(_ScanResult result, {AttendanceRecord? record}) {
    String title, message;
    IconData icon;
    Color iconColor;

    switch (result) {
      case _ScanResult.success:
        title = 'Attendance Recorded';
        final time = record?.timeIn != null
            ? DateFormat('h:mm a').format(record!.timeIn!)
            : '';
        message = '${widget.student.displayName}\nPresent\nToday • $time';
        icon = Icons.check_circle;
        iconColor = AppColors.successAccent;
        break;
      case _ScanResult.duplicate:
        title = 'Already Recorded';
        message = 'Your attendance for this session has already been recorded.';
        icon = Icons.info_outline;
        iconColor = AppColors.primaryLight;
        break;
      case _ScanResult.noSession:
        title = 'Session Expired';
        message = 'This class session is no longer active or has expired.';
        icon = Icons.qr_code;
        iconColor = AppColors.error;
        break;
      case _ScanResult.invalid:
        title = 'Invalid QR Code';
        message = 'This QR code is not a valid ATTENDLY attendance code.';
        icon = Icons.error_outline;
        iconColor = AppColors.error;
        break;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(icon, color: iconColor, size: 48),
        title: Text(title, textAlign: TextAlign.center),
        content: Text(message, textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabaseService>();
    final hasActiveSession = db.activeSession != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const AppLogo(size: 28, showSubtitle: false),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Sign out',
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('saved_student_id');
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, '/role-selection');
            },
          ),
        ],
      ),
      body: _isSaving
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text('Recording attendance...'),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async => _refreshTodayRecord(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.horizontal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      '${_greeting()},',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${widget.student.firstname}!',
                      style: AppTextStyles.headlineLarge,
                    ),
                    const SizedBox(height: 24),
                    AttendanceStatusCard(
                      status: _statusType,
                      studentName: widget.student.displayName,
                      timeIn: _todayRecord?.timeIn != null
                          ? 'Today • ${DateFormat('h:mm a').format(_todayRecord!.timeIn!)}'
                          : null,
                      sessionInfo: hasActiveSession
                          ? 'Scan the class QR code to mark your attendance'
                          : 'There is no active session right now',
                    ),
                    const SizedBox(height: 24),
                    if (!hasActiveSession && _todayRecord == null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.warningBg,
                          borderRadius: BorderRadius.circular(AppRadius.large),
                          border: Border.all(
                              color: AppColors.warning.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.wifi_off_outlined,
                                size: 36, color: AppColors.warning),
                            const SizedBox(height: 12),
                            Text(
                              'No Active Class',
                              style: AppTextStyles.titleMedium
                                  .copyWith(color: AppColors.warning),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'There is currently no active attendance session. Ask your teacher to generate a QR code.',
                              style: AppTextStyles.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (_todayRecord == null) ...[
                      PrimaryButton(
                        label: 'SCAN QR CODE',
                        icon: Icons.qr_code_scanner,
                        isLoading: _isScanning,
                        onPressed: hasActiveSession ? _openScanner : null,
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          hasActiveSession
                              ? 'Point your camera at the teacher\'s QR code'
                              : 'Scanning is disabled — no active session',
                          style: AppTextStyles.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    if (_todayRecord != null) ...[
                      const Center(
                        child: Column(
                          children: [
                            Icon(Icons.verified,
                                color: AppColors.successAccent, size: 64),
                            SizedBox(height: 8),
                            Text(
                              'You\'re all set for today!',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// QR Scanner Bottom Sheet — fixed for mobile_scanner v5
// ─────────────────────────────────────────────────────────────

class _QrScannerSheet extends StatefulWidget {
  final ValueChanged<String> onScan;
  final VoidCallback onClose;

  const _QrScannerSheet({
    required this.onScan,
    required this.onClose,
  });

  @override
  State<_QrScannerSheet> createState() => _QrScannerSheetState();
}

class _QrScannerSheetState extends State<_QrScannerSheet>
    with WidgetsBindingObserver {
  MobileScannerController? _controller;
  bool _scanned = false;
  bool _torchOn = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startScanner();
  }

  void _startScanner() {
    _controller = MobileScannerController(
      // v5: autoStart defaults to true; use these args
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
      returnImage: false,
    );
    setState(() {
      _errorMessage = null;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null) return;
    try {
      if (state == AppLifecycleState.paused) {
        _controller?.stop();
      } else if (state == AppLifecycleState.resumed) {
        _controller?.start();
      }
    } catch (e) {
      debugPrint('Scanner lifecycle error: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    try {
      _controller?.dispose();
    } catch (_) {}
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final rawValue = capture.barcodes.firstOrNull?.rawValue;
    if (rawValue != null && rawValue.isNotEmpty) {
      _scanned = true;
      try {
        _controller?.stop();
      } catch (_) {}
      widget.onScan(rawValue);
    }
  }

  void _toggleTorch() async {
    await _controller?.toggleTorch();
    setState(() => _torchOn = !_torchOn);
  }

  void _switchCamera() async {
    await _controller?.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: Column(
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _torchOn ? Icons.flash_on : Icons.flash_off,
                    color: _torchOn ? Colors.yellow : Colors.white,
                  ),
                  onPressed: _toggleTorch,
                  tooltip: 'Toggle flash',
                ),
                const Expanded(
                  child: Text(
                    'Scan QR Code',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),

          // Camera preview
          Expanded(
            child: _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.camera_alt_outlined,
                              color: Colors.white54, size: 60),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _scanned = false;
                                _errorMessage = null;
                              });
                              _startScanner();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : ClipRRect(
                    child: Stack(
                      children: [
                        // Scanner widget
                        MobileScanner(
                          controller: _controller!,
                          onDetect: _onDetect,
                          errorBuilder: (context, error, child) {
                            // Handle camera errors gracefully
                            WidgetsBinding.instance
                                .addPostFrameCallback((_) {
                              if (mounted) {
                                setState(() {
                                  _errorMessage =
                                      'Camera error: ${error.errorDetails?.message ?? error.errorCode.name}.\n\nPlease close and try again.';
                                });
                              }
                            });
                            return const SizedBox.expand(
                              child: ColoredBox(color: Colors.black),
                            );
                          },
                        ),

                        // Dimmed overlay with square cutout
                        IgnorePointer(
                          child: CustomPaint(
                            painter: _ScanOverlayPainter(),
                            child: const SizedBox.expand(),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          // Instructions + flip camera
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Expanded(
                  child: Text(
                    'Point at the teacher\'s QR code',
                    style:
                        TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.flip_camera_android,
                      color: Colors.white54),
                  onPressed: _switchCamera,
                  tooltip: 'Flip camera',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints a semi-transparent overlay with a clear square in the center.
class _ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const squareSize = 240.0;
    final squareLeft = (size.width - squareSize) / 2;
    final squareTop = (size.height - squareSize) / 2;
    final squareRect =
        Rect.fromLTWH(squareLeft, squareTop, squareSize, squareSize);

    // Dim everything except the square
    final overlayPaint = Paint()..color = Colors.black.withValues(alpha: 0.5);
    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(fullRect),
        Path()
          ..addRRect(
              RRect.fromRectAndRadius(squareRect, const Radius.circular(12))),
      ),
      overlayPaint,
    );

    // Corner guides
    const cornerLen = 28.0;
    const cornerThick = 3.5;
    final cornerPaint = Paint()
      ..color = const Color(0xFF5B9BD5)
      ..strokeWidth = cornerThick
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final corners = [
      // TL
      [squareRect.topLeft, squareRect.topLeft + const Offset(cornerLen, 0)],
      [squareRect.topLeft, squareRect.topLeft + const Offset(0, cornerLen)],
      // TR
      [squareRect.topRight, squareRect.topRight + const Offset(-cornerLen, 0)],
      [squareRect.topRight, squareRect.topRight + const Offset(0, cornerLen)],
      // BL
      [squareRect.bottomLeft, squareRect.bottomLeft + const Offset(cornerLen, 0)],
      [squareRect.bottomLeft, squareRect.bottomLeft + const Offset(0, -cornerLen)],
      // BR
      [squareRect.bottomRight, squareRect.bottomRight + const Offset(-cornerLen, 0)],
      [squareRect.bottomRight, squareRect.bottomRight + const Offset(0, -cornerLen)],
    ];

    for (final line in corners) {
      canvas.drawLine(line[0], line[1], cornerPaint);
    }
  }

  @override
  bool shouldRepaint(_ScanOverlayPainter old) => false;
}
