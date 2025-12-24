import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import '../../../core/theme/reluna_theme.dart';
import '../../../core/adaptive/adaptive.dart';
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
    final isIOS = AdaptivePlatform.isIOSByContext(context);
    if (isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = AdaptivePlatform.isIOSByContext(context);
    
    return AdaptiveScaffold(
      title: 'Create Account',
      hasBackButton: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            
            const Text(
              'Join Your Family',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: RelunaTheme.textPrimary,
              ),
            ),
            
            const SizedBox(height: 8),
            
            const Text(
              'Create an account to get started with family governance',
              style: TextStyle(
                fontSize: 15,
                color: RelunaTheme.textSecondary,
              ),
            ),
            
            const SizedBox(height: 32),
            
            AdaptiveTextField(
              controller: _nameController,
              label: 'Full Name',
              placeholder: 'Enter your full name',
              textInputAction: TextInputAction.next,
              prefix: Icon(
                isIOS ? CupertinoIcons.person : Icons.person_outline,
                color: RelunaTheme.textSecondary,
                size: 20,
              ),
            ),
            
            const SizedBox(height: 16),
            
            AdaptiveTextField(
              controller: _familyNameController,
              label: 'Family Name',
              placeholder: 'Enter your family name',
              textInputAction: TextInputAction.next,
              prefix: Icon(
                isIOS ? CupertinoIcons.house : Icons.family_restroom,
                color: RelunaTheme.textSecondary,
                size: 20,
              ),
            ),
            
            const SizedBox(height: 16),
            
            AdaptiveTextField(
              controller: _emailController,
              label: 'Email',
              placeholder: 'Enter your email',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              prefix: Icon(
                isIOS ? CupertinoIcons.mail : Icons.email_outlined,
                color: RelunaTheme.textSecondary,
                size: 20,
              ),
            ),
            
            const SizedBox(height: 16),
            
            AdaptiveTextField(
              controller: _passwordController,
              label: 'Password',
              placeholder: 'Create a password',
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              prefix: Icon(
                isIOS ? CupertinoIcons.lock : Icons.lock_outline,
                color: RelunaTheme.textSecondary,
                size: 20,
              ),
              suffix: GestureDetector(
                onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                child: Icon(
                  _obscurePassword
                      ? (isIOS ? CupertinoIcons.eye : Icons.visibility_outlined)
                      : (isIOS ? CupertinoIcons.eye_slash : Icons.visibility_off_outlined),
                  color: RelunaTheme.textSecondary,
                  size: 20,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            AdaptiveTextField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              placeholder: 'Confirm your password',
              obscureText: _obscureConfirmPassword,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _register(),
              prefix: Icon(
                isIOS ? CupertinoIcons.lock : Icons.lock_outline,
                color: RelunaTheme.textSecondary,
                size: 20,
              ),
              suffix: GestureDetector(
                onTap: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                child: Icon(
                  _obscureConfirmPassword
                      ? (isIOS ? CupertinoIcons.eye : Icons.visibility_outlined)
                      : (isIOS ? CupertinoIcons.eye_slash : Icons.visibility_off_outlined),
                  color: RelunaTheme.textSecondary,
                  size: 20,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            AdaptiveButton(
              text: 'Create Account',
              isLoading: _isLoading,
              onPressed: _register,
            ),
            
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Already have an account? ',
                  style: TextStyle(color: RelunaTheme.textSecondary),
                ),
                AdaptiveTextButton(
                  text: 'Sign In',
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
