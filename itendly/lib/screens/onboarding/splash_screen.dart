import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/mock_database_service.dart';
import '../../widgets/app_logo.dart';
import '../../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginState();
  }

  Future<void> _checkLoginState() async {
    // Add a small delay for branding splash
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final savedStudentId = prefs.getString('saved_student_id');

    if (!mounted) return;

    if (savedStudentId != null) {
      final db = context.read<MockDatabaseService>();
      try {
        final student = db.students.firstWhere((s) => s.id == savedStudentId);
        // Navigate directly to student home
        Navigator.pushReplacementNamed(
          context,
          '/student/home',
          arguments: student,
        );
        return;
      } catch (e) {
        // Student not found in DB (e.g., cleared data), fall through to role selection
      }
    }

    // No saved login, go to role selection
    Navigator.pushReplacementNamed(context, '/role-selection');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: AppLogo(size: 100),
      ),
    );
  }
}
