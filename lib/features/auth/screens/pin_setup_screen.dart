import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/theme/theme.dart';
import '../../../core/providers/providers.dart';
import '../../../core/router/app_router.dart';

@RoutePage()
class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirmStep = false;
  String _errorMessage = '';

  void _onKeyPressed(String key) {
    HapticFeedback.lightImpact();
    
    setState(() {
      _errorMessage = '';
      if (_isConfirmStep) {
        if (_confirmPin.length < 4) {
          _confirmPin += key;
          if (_confirmPin.length == 4) {
            _verifyPins();
          }
        }
      } else {
        if (_pin.length < 4) {
          _pin += key;
          if (_pin.length == 4) {
            _moveToConfirm();
          }
        }
      }
    });
  }

  void _onDelete() {
    HapticFeedback.lightImpact();
    
    setState(() {
      _errorMessage = '';
      if (_isConfirmStep) {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        }
      } else {
        if (_pin.isNotEmpty) {
          _pin = _pin.substring(0, _pin.length - 1);
        }
      }
    });
  }

  void _moveToConfirm() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _isConfirmStep = true;
        });
      }
    });
  }

  Future<void> _verifyPins() async {
    if (_pin == _confirmPin) {
      await ref.read(authStateProvider.notifier).setupPin(_pin);
      if (mounted) {
        context.router.replace(const MainShellRoute());
      }
    } else {
      setState(() {
        _errorMessage = 'PINs do not match. Please try again.';
        _confirmPin = '';
      });
    }
  }

  void _reset() {
    setState(() {
      _pin = '';
      _confirmPin = '';
      _isConfirmStep = false;
      _errorMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final currentPin = _isConfirmStep ? _confirmPin : _pin;
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 60),
              
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline,
                  size: 40,
                  color: theme.colorScheme.primary,
                ),
              ),
              
              const SizedBox(height: 32),
              
              Text(
                _isConfirmStep ? 'Confirm Your PIN' : 'Create PIN',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.foreground,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                _isConfirmStep 
                    ? 'Enter your PIN again to confirm'
                    : 'Create a 4-digit PIN for quick access',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // PIN dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isFilled = index < currentPin.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled 
                          ? theme.colorScheme.primary 
                          : Colors.transparent,
                      border: Border.all(
                        color: isFilled 
                            ? theme.colorScheme.primary 
                            : theme.colorScheme.border,
                        width: 2,
                      ),
                    ),
                  );
                }),
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
              
              const SizedBox(height: 60),
              
              // Keypad
              _buildKeypad(theme),
              
              const SizedBox(height: 24),
              
              if (_isConfirmStep)
                ShadButton.ghost(
                  onPressed: _reset,
                  child: Text(
                    'Start Over',
                    style: TextStyle(color: theme.colorScheme.mutedForeground),
                  ),
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
          onTap: () => _onKeyPressed(key),
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
                  color: theme.colorScheme.foreground,
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
