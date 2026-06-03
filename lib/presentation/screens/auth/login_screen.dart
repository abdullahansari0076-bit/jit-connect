// lib/presentation/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/app_models.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  UserRole _selectedRole = UserRole.student;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final user = await ref.read(authRepositoryProvider).signIn(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      if (!mounted) return;
      if (user.mustChangePassword) {
        context.go('/change-password');
        return;
      }
      context.go(switch (user.role) {
        UserRole.hod => '/hod',
        UserRole.teacher => '/teacher',
        UserRole.student => '/student',
      });
    } catch (e) {
      setState(() { _errorMessage = e.toString().replaceAll('Exception: ', ''); });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Logo
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.account_balance, color: AppColors.primaryAccent, size: 40),
              ),
              const SizedBox(height: 16),
              Text(AppConstants.appName,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(AppConstants.collegeName,
                style: const TextStyle(color: AppColors.primaryAccent, fontSize: 12),
                textAlign: TextAlign.center),
              const SizedBox(height: 32),

              // Login card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Role selector
                      const Text('Login as', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      Row(
                        children: UserRole.values.map((role) {
                          final isSelected = _selectedRole == role;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedRole = role),
                              child: Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary : AppColors.surface,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary : AppColors.border,
                                    width: 0.5,
                                  ),
                                ),
                                child: Text(
                                  role.name.toUpperCase() == 'HOD' ? 'HOD' :
                                  role.name[0].toUpperCase() + role.name.substring(1),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w500,
                                    color: isSelected ? Colors.white : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Email
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email / Employee ID',
                          hintText: 'Enter your email',
                          prefixIcon: Icon(Icons.person_outline, size: 18),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),

                      // Password
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          prefixIcon: const Icon(Icons.lock_outline, size: 18),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),

                      if (_errorMessage != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.dangerLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(children: [
                            const Icon(Icons.error_outline, color: AppColors.danger, size: 16),
                            const SizedBox(width: 8),
                            Expanded(child: Text(_errorMessage!, style: const TextStyle(color: AppColors.danger, fontSize: 12))),
                          ]),
                        ),
                      ],

                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Login to JIT Connect'),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text('Forgot password? Contact HOD',
                          style: TextStyle(fontSize: 12, color: AppColors.textHint)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
