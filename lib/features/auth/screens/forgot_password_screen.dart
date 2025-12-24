import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import '../../../core/theme/reluna_theme.dart';
import '../../../core/adaptive/adaptive.dart';
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
      title: 'Reset Password',
      hasBackButton: true,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: _emailSent ? _buildSuccessContent() : _buildFormContent(isIOS),
      ),
    );
  }

  Widget _buildFormContent(bool isIOS) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: RelunaTheme.accentColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIOS ? CupertinoIcons.lock_rotation : Icons.lock_reset,
              size: 40,
              color: RelunaTheme.accentColor,
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        const Text(
          'Forgot Password?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: RelunaTheme.textPrimary,
          ),
        ),
        
        const SizedBox(height: 8),
        
        const Text(
          'Enter your email address and we\'ll send you instructions to reset your password.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: RelunaTheme.textSecondary,
            height: 1.5,
          ),
        ),
        
        const SizedBox(height: 32),
        
        AdaptiveTextField(
          controller: _emailController,
          label: 'Email',
          placeholder: 'Enter your email',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _sendResetEmail(),
          prefix: Icon(
            isIOS ? CupertinoIcons.mail : Icons.email_outlined,
            color: RelunaTheme.textSecondary,
            size: 20,
          ),
        ),
        
        const SizedBox(height: 24),
        
        AdaptiveButton(
          text: 'Send Reset Link',
          isLoading: _isLoading,
          onPressed: _sendResetEmail,
        ),
        
        const SizedBox(height: 24),
        
        Center(
          child: AdaptiveTextButton(
            text: 'Back to Sign In',
            onPressed: () => context.router.maybePop(),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessContent() {
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
        
        const Text(
          'Check Your Email',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: RelunaTheme.textPrimary,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Text(
          'We\'ve sent password reset instructions to\n${_emailController.text}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            color: RelunaTheme.textSecondary,
            height: 1.5,
          ),
        ),
        
        const SizedBox(height: 32),
        
        AdaptiveButton(
          text: 'Back to Sign In',
          onPressed: () => context.router.replace(const LoginRoute()),
        ),
        
        const SizedBox(height: 16),
        
        AdaptiveTextButton(
          text: 'Didn\'t receive email? Resend',
          onPressed: () {
            setState(() => _emailSent = false);
          },
        ),
      ],
    );
  }
}
