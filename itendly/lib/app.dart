import 'package:flutter/material.dart';

import 'models/student.dart';
import 'models/teacher.dart';
import 'screens/onboarding/role_selection_screen.dart';
import 'screens/onboarding/startup_screen.dart';
import 'screens/student/identity_screen.dart';
import 'screens/student/student_home_screen.dart';
import 'screens/teacher/teacher_login_screen.dart';
import 'screens/teacher/teacher_home_screen.dart';
import 'theme/app_theme.dart';

class AttendlyApp extends StatelessWidget {
  const AttendlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ATTENDLY',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      onGenerateRoute: _generateRoute,
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _fadeRoute(const StartupScreen(), settings);

      case '/role-selection':
        return _fadeRoute(const RoleSelectionScreen(), settings);

      case '/student/identity':
        return _slideRoute(const StudentIdentityScreen(), settings);

      case '/student/home':
        final student = settings.arguments as Student;
        return _fadeRoute(StudentHomeScreen(student: student), settings);

      case '/teacher/login':
        return _slideRoute(const TeacherLoginScreen(), settings);

      case '/teacher/home':
        final teacher = settings.arguments as Teacher;
        return _fadeRoute(TeacherHomeScreen(teacher: teacher), settings);

      default:
        return _fadeRoute(const RoleSelectionScreen(), settings);
    }
  }

  /// Smooth fade transition — used for major role/home screens.
  static PageRoute _fadeRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  /// Slide-from-right transition — used for detail/form screens.
  static PageRoute _slideRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (_, animation, __, child) {
        final tween = Tween(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeInOutCubic));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }
}
