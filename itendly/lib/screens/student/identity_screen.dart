import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/device_session_service.dart';
import '../../services/fruitask_database_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/custom_text_field.dart';

/// Student identity entry screen — student enters their name and ID to look up in the DB.
class StudentIdentityScreen extends StatefulWidget {
  const StudentIdentityScreen({super.key});

  @override
  State<StudentIdentityScreen> createState() => _StudentIdentityScreenState();
}

class _StudentIdentityScreenState extends State<StudentIdentityScreen> {
  final _sessionService = const DeviceSessionService();
  final _studentIdCtrl = TextEditingController();
  final _surnameCtrl = TextEditingController();
  final _firstnameCtrl = TextEditingController();
  final _middlenameCtrl = TextEditingController();
  final _surnameFocus = FocusNode();
  final _firstnameFocus = FocusNode();
  final _middlenameFocus = FocusNode();

  String? _studentIdError;
  String? _surnameError;
  String? _firstnameError;
  String? _middlenameError;
  bool _isLoading = false;

  @override
  void dispose() {
    _studentIdCtrl.dispose();
    _surnameCtrl.dispose();
    _firstnameCtrl.dispose();
    _middlenameCtrl.dispose();
    _surnameFocus.dispose();
    _firstnameFocus.dispose();
    _middlenameFocus.dispose();
    super.dispose();
  }

  bool _validate() {
    bool valid = true;
    setState(() {
      _studentIdError =
          _studentIdCtrl.text.trim().isEmpty ? 'Student ID is required' : null;
      _surnameError =
          _surnameCtrl.text.trim().isEmpty ? 'Surname is required' : null;
      _firstnameError =
          _firstnameCtrl.text.trim().isEmpty ? 'First name is required' : null;
      _middlenameError = _middlenameCtrl.text.trim().isEmpty
          ? 'Middle name is required'
          : null;
    });
    if (_studentIdCtrl.text.trim().isEmpty) valid = false;
    if (_surnameCtrl.text.trim().isEmpty) valid = false;
    if (_firstnameCtrl.text.trim().isEmpty) valid = false;
    if (_middlenameCtrl.text.trim().isEmpty) valid = false;
    return valid;
  }

  Future<void> _submit() async {
    if (!_validate()) return;
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    final db = context.read<FruitaskDatabaseService>();
    final student = db.findStudentByName(
      _surnameCtrl.text,
      _firstnameCtrl.text,
      _middlenameCtrl.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (student == null) {
      _showNotFound();
      return;
    }

    final enteredId = _studentIdCtrl.text.trim();
    if (student.id.toUpperCase() != enteredId.toUpperCase()) {
      setState(() {
        _studentIdError = 'Student ID does not match our records';
      });
      _showIdMismatch();
      return;
    }

    try {
      await _sessionService.rememberStudent(student.id);
    } catch (error) {
      debugPrint('Unable to remember student device: ');
    }

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/student/home',
      (_) => false,
      arguments: student,
    );
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

  void _showIdMismatch() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.badge, color: AppColors.warning, size: 40),
        title: const Text('Incorrect Student ID', textAlign: TextAlign.center),
        content: const Text(
          'The Student ID you entered does not match our records for this name.\n\nPlease double-check your ID and try again.',
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
              const Center(child: AppLogo(size: 60, showSubtitle: false)),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Enter Your Identity',
                  style: AppTextStyles.headlineMedium,
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Use your registered name and ID exactly as enrolled',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),

              // Caution Banner
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warningBg,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.5),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Your Student ID is required for verification. '
                        'Make sure it exactly matches the ID on your class record '
                        '(e.g. 06-2324-033413).',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.warning,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              CustomTextField(
                controller: _studentIdCtrl,
                label: 'Student ID',
                hint: 'e.g. 06-2324-033413',
                errorText: _studentIdError,
                textInputAction: TextInputAction.next,
                prefixIcon: const Icon(Icons.badge_outlined),
                onEditingComplete: () => _surnameFocus.requestFocus(),
                onChanged: (_) {
                  if (_studentIdError != null) {
                    setState(() => _studentIdError = null);
                  }
                },
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'FULL NAME',
                      style: AppTextStyles.caption.copyWith(
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 16),

              CustomTextField(
                controller: _surnameCtrl,
                label: 'Surname',
                hint: 'e.g. MANGANTI',
                errorText: _surnameError,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.next,
                focusNode: _surnameFocus,
                prefixIcon: const Icon(Icons.person_outline),
                onEditingComplete: () => _firstnameFocus.requestFocus(),
                onChanged: (_) {
                  if (_surnameError != null) {
                    setState(() => _surnameError = null);
                  }
                },
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
                prefixIcon: const Icon(Icons.drive_file_rename_outline),
                onEditingComplete: () => _middlenameFocus.requestFocus(),
                onChanged: (_) {
                  if (_firstnameError != null) {
                    setState(() => _firstnameError = null);
                  }
                },
              ),

              const SizedBox(height: 16),

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

              const Text(
                'Name fields automatically convert to uppercase.',
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

              const Center(
                child: Text(
                  'Your name and ID must match your class enrollment record.',
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
