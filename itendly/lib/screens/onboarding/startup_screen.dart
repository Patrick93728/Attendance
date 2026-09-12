import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/device_session_service.dart';
import '../../services/fruitask_database_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/app_buttons.dart';

/// Loads Fruitask data and exposes visible loading and failure states.
class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  bool _navigationScheduled = false;
  final _sessionService = const DeviceSessionService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    await context.read<FruitaskDatabaseService>().initialize();
  }

  @override
  Widget build(BuildContext context) {
    final db = context.watch<FruitaskDatabaseService>();

    if (db.isLoaded && db.loadError == null && !_navigationScheduled) {
      _navigationScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;

        try {
          final savedStudentId = await _sessionService.getStudentId();
          if (!mounted) return;
          if (savedStudentId != null) {
            final student = db.findStudentById(savedStudentId);
            if (student != null) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/student/home',
                (_) => false,
                arguments: student,
              );
              return;
            }
            await _sessionService.clearInvalidStudent();
          }

          final savedTeacherId = await _sessionService.getTeacherId();
          if (!mounted) return;
          if (savedTeacherId != null) {
            final teacher = db.findTeacherById(savedTeacherId);
            if (teacher != null) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/teacher/home',
                (_) => false,
                arguments: teacher,
              );
              return;
            }
            await _sessionService.clearTeacher();
          }
        } catch (error) {
          debugPrint('Unable to restore device session: $error');
        }

        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/role-selection',
            (_) => false,
          );
        }
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.horizontal),
            child: db.loadError == null
                ? const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppLogo(size: 84),
                      SizedBox(height: 32),
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Loading attendance data...'),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off_outlined,
                          color: AppColors.error, size: 56),
                      const SizedBox(height: 16),
                      const Text(
                        'Unable to Start',
                        style: AppTextStyles.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Attendance data could not be loaded from Fruitask. Please check the connection and try again.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        db.loadError!,
                        style: AppTextStyles.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        label: 'TRY AGAIN',
                        icon: Icons.refresh,
                        onPressed: _load,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
