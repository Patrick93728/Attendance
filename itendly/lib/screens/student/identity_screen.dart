import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/mock_database_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/custom_text_field.dart';

/// Student identity entry screen — student enters their name to look up in the DB.
class StudentIdentityScreen extends StatefulWidget {
  const StudentIdentityScreen({super.key});

  @override
  State<StudentIdentityScreen> createState() => _StudentIdentityScreenState();
}

class _StudentIdentityScreenState extends State<StudentIdentityScreen> {
  final _surnameCtrl = TextEditingController();
  final _firstnameCtrl = TextEditingController();
  final _middlenameCtrl = TextEditingController();
  final _firstnameFocus = FocusNode();
  final _middlenameFocus = FocusNode();

  String? _surnameError;
  String? _firstnameError;
  String? _middlenameError;
  bool _isLoading = false;

  @override
  void dispose() {
    _surnameCtrl.dispose();
    _firstnameCtrl.dispose();
    _middlenameCtrl.dispose();
    _firstnameFocus.dispose();
    _middlenameFocus.dispose();
    super.dispose();
  }

  bool _validate() {
    bool valid = true;
    setState(() {
      _surnameError = _surnameCtrl.text.trim().isEmpty ? 'Surname is required' : null;
      _firstnameError = _firstnameCtrl.text.trim().isEmpty ? 'First name is required' : null;
      _middlenameError =
          _middlenameCtrl.text.trim().isEmpty ? 'Middle name is required' : null;
    });
    if (_surnameCtrl.text.trim().isEmpty) valid = false;
    if (_firstnameCtrl.text.trim().isEmpty) valid = false;
    if (_middlenameCtrl.text.trim().isEmpty) valid = false;
    return valid;
  }

  Future<void> _submit() async {
    if (!_validate()) return;
    setState(() => _isLoading = true);

    // Small simulated delay for UX
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    final db = context.read<MockDatabaseService>();
    final student = db.findStudentByName(
      _surnameCtrl.text,
      _firstnameCtrl.text,
      _middlenameCtrl.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (student != null) {
      Navigator.pushReplacementNamed(
        context,
        '/student/home',
        arguments: student,
      );
    } else {
      _showNotFound();
    }
  }

  void _showNotFound() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.person_search, color: AppColors.error, size: 40),
        title: const Text('Student Not Found', textAlign: TextAlign.center),
        content: const Text(
          'We could not find your name in the class list.\n\nPlease check the spelling or contact your teacher.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Student Identity'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.horizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Header
              const Center(child: AppLogo(size: 60, showSubtitle: false)),
              const SizedBox(height: 24),

              Center(
                child: Text(
                  'Enter Your Name',
                  style: AppTextStyles.headlineMedium,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Use your registered name exactly as enrolled',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 32),

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
                onChanged: (_) {
                  if (_surnameError != null) {
                    setState(() => _surnameError = null);
                  }
                },
              ),

              const SizedBox(height: 16),

              // First name
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
                onChanged: (_) {
                  if (_firstnameError != null) {
                    setState(() => _firstnameError = null);
                  }
                },
              ),

              const SizedBox(height: 16),

              // Middle name
              CustomTextField(
                controller: _middlenameCtrl,
                label: 'Middle Name',
                hint: 'e.g. TUAZON',
                errorText: _middlenameError,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.done,
                focusNode: _middlenameFocus,
                prefixIcon: const Icon(Icons.drive_file_rename_outline),
                onEditingComplete: _submit,
                onChanged: (_) {
                  if (_middlenameError != null) {
                    setState(() => _middlenameError = null);
                  }
                },
              ),

              const SizedBox(height: 12),

              Text(
                'All fields automatically convert to uppercase.',
                style: AppTextStyles.caption,
              ),

              const SizedBox(height: 32),

              PrimaryButton(
                label: 'ENTER ATTENDANCE',
                isLoading: _isLoading,
                icon: Icons.arrow_forward,
                onPressed: _submit,
              ),

              const SizedBox(height: 16),

              Center(
                child: Text(
                  'Your name must match your class enrollment record.',
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
