import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/mock_database_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/custom_text_field.dart';

/// Teacher login screen with email + password.
///
/// Demo credentials: teacher@itendly.app / teacher123
/// PRODUCTION NOTE: Use secure server-side authentication.
class TeacherLoginScreen extends StatefulWidget {
  const TeacherLoginScreen({super.key});

  @override
  State<TeacherLoginScreen> createState() => _TeacherLoginScreenState();
}

class _TeacherLoginScreenState extends State<TeacherLoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _passwordFocus = FocusNode();

  String? _emailError;
  String? _passwordError;
  String? _loginError;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  bool _validate() {
    bool valid = true;
    setState(() {
      _loginError = null;
      _emailError = _emailCtrl.text.trim().isEmpty ? 'Email is required' : null;
      _passwordError =
          _passwordCtrl.text.isEmpty ? 'Password is required' : null;
    });
    if (_emailCtrl.text.trim().isEmpty || _passwordCtrl.text.isEmpty) {
      valid = false;
    }
    return valid;
  }

  Future<void> _login() async {
    if (!_validate()) return;
    setState(() => _isLoading = true);

    // Simulated delay
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final db = context.read<MockDatabaseService>();
    final teacher =
        db.loginTeacher(_emailCtrl.text.trim(), _passwordCtrl.text);

    setState(() => _isLoading = false);
    if (!mounted) return;

    if (teacher != null) {
      Navigator.pushReplacementNamed(
        context,
        '/teacher/home',
        arguments: teacher,
      );
    } else {
      setState(
        () => _loginError =
            'Invalid email or password. Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.horizontal),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const AppLogo(size: 70),
              const SizedBox(height: 32),
              Text('Teacher Login', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Sign in with your teacher account',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 32),

              // Login error
              if (_loginError != null) ...
                [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.errorBg,
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                      border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.error, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _loginError!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

              // Email
              CustomTextField(
                controller: _emailCtrl,
                label: 'Email Address',
                hint: 'teacher@itendly.app',
                errorText: _emailError,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                prefixIcon: const Icon(Icons.email_outlined),
                onEditingComplete: () => _passwordFocus.requestFocus(),
                onChanged: (_) => setState(() {
                  _emailError = null;
                  _loginError = null;
                }),
              ),

              const SizedBox(height: 16),

              // Password
              CustomTextField(
                controller: _passwordCtrl,
                label: 'Password',
                errorText: _passwordError,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                focusNode: _passwordFocus,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                onEditingComplete: _login,
                onChanged: (_) => setState(() {
                  _passwordError = null;
                  _loginError = null;
                }),
              ),

              const SizedBox(height: 28),

              PrimaryButton(
                label: 'LOGIN',
                isLoading: _isLoading,
                icon: Icons.login,
                onPressed: _login,
              ),

              const SizedBox(height: 24),

              // Demo hint
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: Column(
                  children: [
                    Text(
                      'Demo Credentials',
                      style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary),
                    ),
                    const SizedBox(height: 4),
                    const Text('Email: teacher@itendly.app',
                        style: AppTextStyles.bodySmall),
                    const Text('Password: teacher123',
                        style: AppTextStyles.bodySmall),
                    const SizedBox(height: 4),
                    const Text(
                      'For UI testing only — not secure for production.',
                      style: AppTextStyles.caption,
                      textAlign: TextAlign.center,
                    ),
                  ],
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
