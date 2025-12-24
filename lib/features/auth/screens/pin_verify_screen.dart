import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/theme/theme.dart';
import '../../../core/providers/providers.dart';
import '../../../core/router/app_router.dart';

@RoutePage()
class PinVerifyScreen extends ConsumerStatefulWidget {
  const PinVerifyScreen({super.key});

  @override
  ConsumerState<PinVerifyScreen> createState() => _PinVerifyScreenState();
}

class _PinVerifyScreenState extends ConsumerState<PinVerifyScreen> 
    with SingleTickerProviderStateMixin {
  String _pin = '';
  String _errorMessage = '';
  int _attempts = 0;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onKeyPressed(String key) {
    HapticFeedback.lightImpact();
    
    setState(() {
      _errorMessage = '';
      if (_pin.length < 4) {
        _pin += key;
        if (_pin.length == 4) {
          _verifyPin();
        }
      }
    });
  }

  void _onDelete() {
    HapticFeedback.lightImpact();
    
    setState(() {
      _errorMessage = '';
      if (_pin.isNotEmpty) {
        _pin = _pin.substring(0, _pin.length - 1);
      }
    });
  }

  Future<void> _verifyPin() async {
    final isValid = await ref.read(authStateProvider.notifier).verifyPin(_pin);
    
    if (isValid) {
      if (mounted) {
        context.router.replace(const MainShellRoute());
      }
    } else {
      _attempts++;
      HapticFeedback.heavyImpact();
      _shakeController.forward(from: 0);
      
      setState(() {
        _errorMessage = _attempts >= 3 
            ? 'Too many attempts. Try again later.'
            : 'Incorrect PIN. Please try again.';
        _pin = '';
      });
    }
  }

  Future<void> _useBiometric() async {
    HapticFeedback.lightImpact();
    
    showDialog(
      context: context,
      builder: (context) {
        final theme = ShadTheme.of(context);
        return AlertDialog(
          backgroundColor: theme.colorScheme.card,
          title: const Text('Biometric Authentication'),
          content: const Text('Biometric authentication is a mock feature.\nTap Confirm to simulate success.'),
          actions: [
            ShadButton.ghost(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ShadButton(
              onPressed: () async {
                Navigator.pop(context);
                await ref.read(authStateProvider.notifier).verifyPin(
                  ref.read(pinManagerProvider).getPin()!,
                );
                if (mounted) {
                  context.router.replace(const MainShellRoute());
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    await ref.read(authStateProvider.notifier).logout();
    if (mounted) {
      context.router.replace(const LoginRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final authState = ref.watch(authStateProvider);
    final isBiometricEnabled = ref.read(authStateProvider.notifier).isBiometricEnabled();
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 60),
              
              // Avatar
              ShadAvatar(
                authState.currentUser?.avatar ?? 'placeholder',
                size: const Size(80, 80),
                placeholder: Icon(
                  Icons.person,
                  size: 40,
                  color: theme.colorScheme.primary,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Text(
                'Welcome back,',
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
              
              const SizedBox(height: 4),
              
              Text(
                authState.currentUser?.fullName ?? 'User',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.foreground,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Enter your PIN to continue',
                style: TextStyle(
                  fontSize: 15,
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // PIN dots with shake animation
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  final offset = _shakeAnimation.value * 10 * 
                      ((_shakeAnimation.value * 10).toInt().isEven ? 1 : -1);
                  return Transform.translate(
                    offset: Offset(offset, 0),
                    child: child,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    final isFilled = index < _pin.length;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isFilled 
                            ? (_errorMessage.isNotEmpty ? theme.colorScheme.destructive : theme.colorScheme.primary)
                            : Colors.transparent,
                        border: Border.all(
                          color: isFilled 
                              ? (_errorMessage.isNotEmpty ? theme.colorScheme.destructive : theme.colorScheme.primary)
                              : theme.colorScheme.border,
                          width: 2,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage,
                  style: TextStyle(
                    color: theme.colorScheme.destructive,
                    fontSize: 14,
                  ),
                ),
              ],
              
              const Spacer(),
              
              // Keypad
              _buildKeypad(theme),
              
              const SizedBox(height: 24),
              
              // Biometric and other options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (isBiometricEnabled)
                    ShadButton.ghost(
                      onPressed: _useBiometric,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.fingerprint,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Use Biometric',
                            style: TextStyle(color: theme.colorScheme.primary),
                          ),
                        ],
                      ),
                    ),
                  ShadButton.ghost(
                    onPressed: _logout,
                    child: Text(
                      'Sign Out',
                      style: TextStyle(color: theme.colorScheme.mutedForeground),
                    ),
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

  Widget _buildKeypad(ShadThemeData theme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['1', '2', '3'].map((key) => _buildKey(key, theme)).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['4', '5', '6'].map((key) => _buildKey(key, theme)).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['7', '8', '9'].map((key) => _buildKey(key, theme)).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 80),
            _buildKey('0', theme),
            _buildDeleteKey(theme),
          ],
        ),
      ],
    );
  }

  Widget _buildKey(String key, ShadThemeData theme) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _attempts >= 3 ? null : () => _onKeyPressed(key),
          borderRadius: BorderRadius.circular(40),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.card,
              border: Border.all(color: theme.colorScheme.border),
            ),
            child: Center(
              child: Text(
                key,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  color: _attempts >= 3 
                      ? theme.colorScheme.mutedForeground 
                      : theme.colorScheme.foreground,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteKey(ShadThemeData theme) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _onDelete,
          borderRadius: BorderRadius.circular(40),
          child: Center(
            child: Icon(
              Icons.backspace_outlined,
              size: 28,
              color: theme.colorScheme.mutedForeground,
            ),
          ),
        ),
      ),
    );
  }
}
