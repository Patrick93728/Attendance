import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/student.dart';
import '../../services/mock_database_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/custom_text_field.dart';

/// Screen to add a new student or edit an existing one.
class AddEditStudentScreen extends StatefulWidget {
  final Student? existingStudent;

  const AddEditStudentScreen({super.key, this.existingStudent});

  bool get isEditing => existingStudent != null;

  @override
  State<AddEditStudentScreen> createState() => _AddEditStudentScreenState();
}

class _AddEditStudentScreenState extends State<AddEditStudentScreen> {
  final _surnameCtrl = TextEditingController();
  final _firstnameCtrl = TextEditingController();
  final _middlenameCtrl = TextEditingController();
  final _studentIdCtrl = TextEditingController();

  final _firstnameFocus = FocusNode();
  final _middlenameFocus = FocusNode();
  final _idFocus = FocusNode();

  String? _surnameError;
  String? _firstnameError;
  String? _middlenameError;
  String? _idError;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      final s = widget.existingStudent!;
      _surnameCtrl.text = s.surname;
      _firstnameCtrl.text = s.firstname;
      _middlenameCtrl.text = s.middlename;
      _studentIdCtrl.text = s.id;
    } else {
      // Pre-fill next available ID
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final db = context.read<MockDatabaseService>();
        _studentIdCtrl.text = db.generateStudentId();
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _surnameCtrl.dispose();
    _firstnameCtrl.dispose();
    _middlenameCtrl.dispose();
    _studentIdCtrl.dispose();
    _firstnameFocus.dispose();
    _middlenameFocus.dispose();
    _idFocus.dispose();
    super.dispose();
  }

  bool _validate() {
    bool valid = true;
    setState(() {
      _surnameError =
          _surnameCtrl.text.trim().isEmpty ? 'Surname is required' : null;
      _firstnameError =
          _firstnameCtrl.text.trim().isEmpty ? 'First name is required' : null;
      _middlenameError = _middlenameCtrl.text.trim().isEmpty
          ? 'Middle name is required'
          : null;
      _idError =
          _studentIdCtrl.text.trim().isEmpty ? 'Student ID is required' : null;
    });
    if (_surnameCtrl.text.trim().isEmpty) valid = false;
    if (_firstnameCtrl.text.trim().isEmpty) valid = false;
    if (_middlenameCtrl.text.trim().isEmpty) valid = false;
    if (_studentIdCtrl.text.trim().isEmpty) valid = false;
    return valid;
  }

  Future<void> _save() async {
    if (!_validate()) return;
    final db = context.read<MockDatabaseService>();
    final studentId = _studentIdCtrl.text.trim().toUpperCase();
    if (!db.isStudentIdAvailable(
      studentId,
      excludingId: widget.existingStudent?.id,
    )) {
      setState(() => _idError = 'Student ID is already in use');
      return;
    }
    setState(() => _isSaving = true);

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    final student = Student(
      id: studentId,
      surname: _surnameCtrl.text.trim().toUpperCase(),
      firstname: _firstnameCtrl.text.trim().toUpperCase(),
      middlename: _middlenameCtrl.text.trim().toUpperCase(),
    );

    if (widget.isEditing) {
      db.updateStudent(widget.existingStudent!.id, student);
    } else {
      db.addStudent(student);
    }

    setState(() => _isSaving = false);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isEditing
              ? '${student.displayName} updated'
              : '${student.displayName} added',
        ),
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        title: Text(widget.isEditing ? 'Edit Student' : 'Add Student'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.horizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Surname
              CustomTextField(
                controller: _surnameCtrl,
                label: 'Surname',
                hint: 'e.g. MANGANTI',
                errorText: _surnameError,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.next,
                prefixIcon: const Icon(Icons.person_outline),
                onEditingComplete: () => _firstnameFocus.requestFocus(),
                onChanged: (_) => setState(() => _surnameError = null),
              ),

              const SizedBox(height: 16),

              CustomTextField(
                controller: _firstnameCtrl,
                label: 'First Name',
                hint: 'e.g. ARDY',
                errorText: _firstnameError,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.next,
                focusNode: _firstnameFocus,
                prefixIcon: const Icon(Icons.badge_outlined),
                onEditingComplete: () => _middlenameFocus.requestFocus(),
                onChanged: (_) => setState(() => _firstnameError = null),
              ),

              const SizedBox(height: 16),

              CustomTextField(
                controller: _middlenameCtrl,
                label: 'Middle Name',
                hint: 'e.g. TUAZON',
                errorText: _middlenameError,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.next,
                focusNode: _middlenameFocus,
                prefixIcon: const Icon(Icons.drive_file_rename_outline),
                onEditingComplete: () => _idFocus.requestFocus(),
                onChanged: (_) => setState(() => _middlenameError = null),
              ),

              const SizedBox(height: 16),

              CustomTextField(
                controller: _studentIdCtrl,
                label: 'Student ID',
                hint: 'e.g. STU-011',
                errorText: _idError,
                textInputAction: TextInputAction.done,
                focusNode: _idFocus,
                prefixIcon: const Icon(Icons.tag),
                textCapitalization: TextCapitalization.characters,
                onEditingComplete: _save,
                onChanged: (_) => setState(() => _idError = null),
              ),

              if (widget.isEditing)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Changing the ID also updates this student\'s attendance records.',
                    style: AppTextStyles.caption,
                  ),
                ),

              const SizedBox(height: 32),

              PrimaryButton(
                label: widget.isEditing ? 'UPDATE STUDENT' : 'ADD STUDENT',
                isLoading: _isSaving,
                icon: widget.isEditing ? Icons.save : Icons.person_add,
                onPressed: _save,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
