import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/mock_database_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/app_buttons.dart';

/// Loads bundled mock data and exposes visible loading and failure states.
class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  bool _navigationScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    await context.read<MockDatabaseService>().initialize();
  }

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabaseService>();

    if (db.isLoaded && db.loadError == null && !_navigationScheduled) {
      _navigationScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/role-selection');
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
                      Text('Unable to Start',
                          style: AppTextStyles.headlineMedium),
                      const SizedBox(height: 8),
                      const Text(
                        'The local attendance data could not be loaded. Please try again.',
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
