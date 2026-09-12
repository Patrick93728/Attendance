import 'package:flutter/material.dart';
import '../../models/teacher.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          StudentsTab(teacher: widget.teacher),
          QrGeneratorTab(teacher: widget.teacher),
          TeacherRecordsTab(teacher: widget.teacher),
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
