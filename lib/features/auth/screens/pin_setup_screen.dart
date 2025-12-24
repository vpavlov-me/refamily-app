import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import '../../../core/theme/reluna_theme.dart';
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
    final currentPin = _isConfirmStep ? _confirmPin : _pin;
    
    return Scaffold(
      backgroundColor: RelunaTheme.backgroundLight,
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
                  color: RelunaTheme.accentColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 40,
                  color: RelunaTheme.accentColor,
                ),
              ),
              
              const SizedBox(height: 32),
              
              Text(
                _isConfirmStep ? 'Confirm Your PIN' : 'Create PIN',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: RelunaTheme.textPrimary,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                _isConfirmStep 
                    ? 'Enter your PIN again to confirm'
                    : 'Create a 4-digit PIN for quick access',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: RelunaTheme.textSecondary,
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
                          ? RelunaTheme.accentColor 
                          : Colors.transparent,
                      border: Border.all(
                        color: isFilled 
                            ? RelunaTheme.accentColor 
                            : RelunaTheme.divider,
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
                  style: const TextStyle(
                    color: RelunaTheme.error,
                    fontSize: 14,
                  ),
                ),
              ],
              
              const SizedBox(height: 60),
              
              // Keypad
              _buildKeypad(),
              
              const SizedBox(height: 24),
              
              if (_isConfirmStep)
                TextButton(
                  onPressed: _reset,
                  child: const Text(
                    'Start Over',
                    style: TextStyle(color: RelunaTheme.textSecondary),
                  ),
                ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['1', '2', '3'].map((key) => _buildKey(key)).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['4', '5', '6'].map((key) => _buildKey(key)).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['7', '8', '9'].map((key) => _buildKey(key)).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 80), // Empty space
            _buildKey('0'),
            _buildDeleteKey(),
          ],
        ),
      ],
    );
  }

  Widget _buildKey(String key) {
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
              color: RelunaTheme.surfaceLight,
              border: Border.all(color: RelunaTheme.divider),
            ),
            child: Center(
              child: Text(
                key,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  color: RelunaTheme.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteKey() {
    return SizedBox(
      width: 80,
      height: 80,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _onDelete,
          borderRadius: BorderRadius.circular(40),
          child: const Center(
            child: Icon(
              Icons.backspace_outlined,
              size: 28,
              color: RelunaTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
