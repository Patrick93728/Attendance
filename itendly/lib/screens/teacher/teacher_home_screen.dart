import 'package:flutter/material.dart';
import '../../models/teacher.dart';
import '../../services/device_session_service.dart';
import 'students_tab.dart';
import 'qr_generator_tab.dart';
import 'teacher_records_tab.dart';

/// Teacher home with three-tab bottom navigation.
class TeacherHomeScreen extends StatefulWidget {
  final Teacher teacher;

  const TeacherHomeScreen({super.key, required this.teacher});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  int _selectedIndex = 1; // Default to QR Generator tab
  bool _isLoggingOut = false;
  final _sessionService = const DeviceSessionService();

  Future<void> _logout() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;
    try {
      await _sessionService.clearTeacher();
    } catch (error) {
      debugPrint('Unable to clear teacher session: $error');
    } finally {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/role-selection',
          (_) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          StudentsTab(teacher: widget.teacher, onLogout: _logout),
          QrGeneratorTab(teacher: widget.teacher, onLogout: _logout),
          TeacherRecordsTab(teacher: widget.teacher, onLogout: _logout),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Students',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_outlined),
            selectedIcon: Icon(Icons.qr_code),
            label: 'QR Generator',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check),
            label: 'Records',
          ),
        ],
      ),
    );
  }
}
