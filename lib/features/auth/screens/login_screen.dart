import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/theme/theme.dart';
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
    ShadToaster.of(context).show(
      ShadToast(
        title: const Text('Notice'),
        description: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
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
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.family_restroom,
                    size: 40,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              Text(
                'Welcome Back',
                textAlign: TextAlign.center,
                style: theme.textTheme.h2,
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Sign in to continue to Reluna Family',
                textAlign: TextAlign.center,
                style: theme.textTheme.muted,
              ),
              
              const SizedBox(height: 32),
              
              // Tab Bar
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.muted,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: const EdgeInsets.all(4),
                  labelColor: theme.colorScheme.primaryForeground,
                  unselectedLabelColor: theme.colorScheme.mutedForeground,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Sign In'),
                    Tab(text: 'Register'),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Email field
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
              
              // Password field
              ShadInput(
                controller: _passwordController,
                placeholder: const Text('Enter your password'),
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
              
              const SizedBox(height: 12),
              
              Align(
                alignment: Alignment.centerRight,
                child: ShadButton.link(
                  child: const Text('Forgot Password?'),
                  onPressed: () => context.router.push(const ForgotPasswordRoute()),
                ),
              ),
              
              const SizedBox(height: 24),
              
              ShadButton(
                child: const Text('Sign In'),
                enabled: !_isLoading,
                onPressed: _login,
                icon: _isLoading
                    ? const CupertinoActivityIndicator(
                        radius: 8,
                        color: Colors.white,
                      )
                    : null,
              ),
              
              const SizedBox(height: 24),
              
              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: theme.colorScheme.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or continue with',
                      style: theme.textTheme.muted,
                    ),
                  ),
                  Expanded(child: Divider(color: theme.colorScheme.border)),
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
                  Text(
                    "Don't have an account? ",
                    style: theme.textTheme.muted,
                  ),
                  ShadButton.link(
                    child: const Text('Register'),
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
    final theme = ShadTheme.of(context);
    
    return ShadButton.outline(
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
