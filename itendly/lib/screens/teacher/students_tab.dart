import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/student.dart';
import '../../models/teacher.dart';
import '../../services/mock_database_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/student_list_tile.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/confirmation_dialog.dart';
import 'add_edit_student_screen.dart';

/// Teacher Students Tab — list with add, edit, delete.
class StudentsTab extends StatelessWidget {
  final Teacher teacher;
  final VoidCallback onLogout;

  const StudentsTab({
    super.key,
    required this.teacher,
    required this.onLogout,
  });

  Future<void> _deleteStudent(
    BuildContext context,
    Student student,
  ) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Delete Student?',
      message:
          'This will remove ${student.displayName} from the current mock data.',
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
      isDestructive: true,
      icon: Icons.delete_outline,
    );
    if (confirmed == true && context.mounted) {
      context.read<MockDatabaseService>().deleteStudent(student.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${student.displayName} deleted'),
          action: SnackBarAction(label: 'OK', onPressed: () {}),
        ),
      );
    }
  }

  void _navigateToAdd(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddEditStudentScreen(),
      ),
    );
  }

  void _navigateToEdit(BuildContext context, Student student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditStudentScreen(existingStudent: student),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final students = context.watch<MockDatabaseService>().students;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Students'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Sign out',
            onPressed: onLogout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAdd(context),
        tooltip: 'Add Student',
        child: const Icon(Icons.add),
      ),
      body: students.isEmpty
          ? EmptyState(
              icon: Icons.group_outlined,
              title: 'No Students',
              description: 'No students enrolled yet.\nTap + to add a student.',
              actionLabel: 'Add Student',
              onAction: () => _navigateToAdd(context),
            )
          : Column(
              children: [
                // Student count header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.horizontal,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${students.length} student${students.length == 1 ? '' : 's'} enrolled',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.horizontal,
                      vertical: 4,
                    ),
                    itemCount: students.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, index) => StudentListTile(
                      student: students[index],
                      onEdit: () => _navigateToEdit(ctx, students[index]),
                      onDelete: () => _deleteStudent(ctx, students[index]),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
