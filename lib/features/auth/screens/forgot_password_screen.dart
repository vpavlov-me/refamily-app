import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/shared.dart';
import '../../../core/router/app_router.dart';

@RoutePage()
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (_emailController.text.isEmpty) {
      _showError('Please enter your email');
      return;
    }

    setState(() => _isLoading = true);

    // Mock sending email
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
      _emailSent = true;
    });
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
    return AppScaffold(
      title: 'Reset Password',
      hasBackButton: true,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: _emailSent ? _buildSuccessContent() : _buildFormContent(),
      ),
    );
  }

  Widget _buildFormContent() {
    final theme = ShadTheme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_reset,
              size: 40,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        Text(
          'Forgot Password?',
          textAlign: TextAlign.center,
          style: theme.textTheme.h3,
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Enter your email address and we\'ll send you instructions to reset your password.',
          textAlign: TextAlign.center,
          style: theme.textTheme.muted.copyWith(height: 1.5),
        ),
        
        const SizedBox(height: 32),
        
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
        
        const SizedBox(height: 24),
        
        ShadButton(
          child: const Text('Send Reset Link'),
          enabled: !_isLoading,
          onPressed: _sendResetEmail,
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : null,
        ),
        
        const SizedBox(height: 24),
        
        Center(
          child: ShadButton.link(
            child: const Text('Back to Sign In'),
            onPressed: () => context.router.maybePop(),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessContent() {
    final theme = ShadTheme.of(context);
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: RelunaTheme.success.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            size: 50,
            color: RelunaTheme.success,
          ),
        ),
        
        const SizedBox(height: 32),
        
        Text(
          'Check Your Email',
          style: theme.textTheme.h3,
        ),
        
        const SizedBox(height: 12),
        
        Text(
          'We\'ve sent password reset instructions to\n${_emailController.text}',
          textAlign: TextAlign.center,
          style: theme.textTheme.muted.copyWith(height: 1.5),
        ),
        
        const SizedBox(height: 32),
        
        ShadButton(
          child: const Text('Back to Sign In'),
          onPressed: () => context.router.replace(const LoginRoute()),
        ),
        
        const SizedBox(height: 16),
        
        ShadButton.link(
          child: const Text('Didn\'t receive email? Resend'),
          onPressed: () {
            setState(() => _emailSent = false);
          },
        ),
      ],
    );
  }
}
