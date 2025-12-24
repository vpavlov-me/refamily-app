import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import '../../../core/theme/reluna_theme.dart';
import '../../../core/adaptive/adaptive.dart';
import '../../../core/providers/providers.dart';
import '../../../core/router/app_router.dart';

@RoutePage()
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Pre-fill with mock user for testing
    _emailController.text = 'alexander.reluna@family.com';
    _passwordController.text = 'password123';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Please enter email and password');
      return;
    }

    setState(() => _isLoading = true);

    final success = await ref.read(authStateProvider.notifier).login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      final authState = ref.read(authStateProvider);
      if (authState.hasPinSetup) {
        context.router.replace(const PinVerifyRoute());
      } else {
        context.router.replace(const PinSetupRoute());
      }
    } else {
      _showError('Invalid email or password');
    }
  }

  Future<void> _socialLogin(String provider) async {
    _showError('$provider login is a mock feature');
    // Simulate social login success
    await Future.delayed(const Duration(seconds: 1));
    await ref.read(authStateProvider.notifier).login(
      'alexander.reluna@family.com',
      'password123',
    );
    if (mounted) {
      final authState = ref.read(authStateProvider);
      if (authState.hasPinSetup) {
        context.router.replace(const PinVerifyRoute());
      } else {
        context.router.replace(const PinSetupRoute());
      }
    }
  }

  void _showError(String message) {
    final isIOS = AdaptivePlatform.isIOSByContext(context);
    if (isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Notice'),
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
    
    return Scaffold(
      backgroundColor: RelunaTheme.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              
              // Logo
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: RelunaTheme.accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.family_restroom,
                    size: 40,
                    color: RelunaTheme.accentColor,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              const Text(
                'Welcome Back',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: RelunaTheme.textPrimary,
                ),
              ),
              
              const SizedBox(height: 8),
              
              const Text(
                'Sign in to continue to Reluna Family',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: RelunaTheme.textSecondary,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Tab Bar
              Container(
                decoration: BoxDecoration(
                  color: RelunaTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: RelunaTheme.divider),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: RelunaTheme.accentColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: const EdgeInsets.all(4),
                  labelColor: Colors.white,
                  unselectedLabelColor: RelunaTheme.textSecondary,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Sign In'),
                    Tab(text: 'Register'),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Form fields
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
                placeholder: 'Enter your password',
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _login(),
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
              
              const SizedBox(height: 12),
              
              Align(
                alignment: Alignment.centerRight,
                child: AdaptiveTextButton(
                  text: 'Forgot Password?',
                  onPressed: () => context.router.push(const ForgotPasswordRoute()),
                ),
              ),
              
              const SizedBox(height: 24),
              
              AdaptiveButton(
                text: 'Sign In',
                isLoading: _isLoading,
                onPressed: _login,
              ),
              
              const SizedBox(height: 24),
              
              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: RelunaTheme.divider)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or continue with',
                      style: TextStyle(
                        color: RelunaTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: RelunaTheme.divider)),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Social buttons
              Row(
                children: [
                  Expanded(
                    child: _SocialButton(
                      icon: Icons.g_mobiledata,
                      label: 'Google',
                      onTap: () => _socialLogin('Google'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SocialButton(
                      icon: Icons.apple,
                      label: 'Apple',
                      onTap: () => _socialLogin('Apple'),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Register link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(color: RelunaTheme.textSecondary),
                  ),
                  AdaptiveTextButton(
                    text: 'Register',
                    onPressed: () => context.router.push(const RegisterRoute()),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: RelunaTheme.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: RelunaTheme.divider),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: RelunaTheme.textPrimary),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: RelunaTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
