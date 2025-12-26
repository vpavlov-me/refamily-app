import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/shared.dart';
import '../../../core/providers/providers.dart';
import '../../../core/router/app_router.dart';

@RoutePage()
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _familyNameController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _familyNameController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _familyNameController.text.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return;
    }

    if (_passwordController.text.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }

    setState(() => _isLoading = true);

    final success = await ref.read(authStateProvider.notifier).register(
      _emailController.text.trim(),
      _passwordController.text,
      _nameController.text.trim(),
      _familyNameController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      context.router.replace(const PinSetupRoute());
    }
  }

  void _showError(String message) {
    ShadToaster.of(context).show(
      ShadToast.destructive(
        title: const Text('Error'),
        description: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    
    return AppScaffold(
      title: 'Create Account',
      hasBackButton: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            
            Text(
              'Join Your Family',
              style: theme.textTheme.h3,
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Create an account to get started with family governance',
              style: theme.textTheme.muted,
            ),
            
            const SizedBox(height: 32),
            
            ShadInput(
              controller: _nameController,
              placeholder: const Text('Enter your full name'),
              prefix: Icon(
                Icons.person_outline,
                color: theme.colorScheme.mutedForeground,
                size: 20,
              ),
            ),
            
            const SizedBox(height: 16),
            
            ShadInput(
              controller: _familyNameController,
              placeholder: const Text('Enter your family name'),
              prefix: Icon(
                Icons.family_restroom,
                color: theme.colorScheme.mutedForeground,
                size: 20,
              ),
            ),
            
            const SizedBox(height: 16),
            
            ShadInput(
              controller: _emailController,
              placeholder: const Text('Enter your email'),
              keyboardType: TextInputType.emailAddress,
              prefix: Icon(
                Icons.email_outlined,
                color: theme.colorScheme.mutedForeground,
                size: 20,
              ),
            ),
            
            const SizedBox(height: 16),
            
            ShadInput(
              controller: _passwordController,
              placeholder: const Text('Create a password'),
              obscureText: _obscurePassword,
              prefix: Icon(
                Icons.lock_outline,
                color: theme.colorScheme.mutedForeground,
                size: 20,
              ),
              suffix: GestureDetector(
                onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                child: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: theme.colorScheme.mutedForeground,
                  size: 20,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            ShadInput(
              controller: _confirmPasswordController,
              placeholder: const Text('Confirm your password'),
              obscureText: _obscureConfirmPassword,
              prefix: Icon(
                Icons.lock_outline,
                color: theme.colorScheme.mutedForeground,
                size: 20,
              ),
              suffix: GestureDetector(
                onTap: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                child: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: theme.colorScheme.mutedForeground,
                  size: 20,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            ShadButton(
              child: const Text('Create Account'),
              enabled: !_isLoading,
              onPressed: _register,
              icon: _isLoading
                  ? const CupertinoActivityIndicator(
                      radius: 8,
                      color: Colors.white,
                    )
                  : null,
            ),
            
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: theme.textTheme.muted,
                ),
                ShadButton.link(
                  child: const Text('Sign In'),
                  onPressed: () => context.router.maybePop(),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
