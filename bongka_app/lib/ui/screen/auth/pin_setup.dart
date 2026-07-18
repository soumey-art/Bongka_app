import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_color.dart';
import '../../../theme/app_textStyle.dart';
import '../../../provider/auth_provider.dart';
import '../home/home_screen.dart';

enum _PinStage { enter, confirm }

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({
    super.key,
    this.pinLength = 6,
    this.maxAttempts = 3,
    this.lockoutSeconds = 10,
  });

  final int pinLength;
  final int maxAttempts;
  final int lockoutSeconds;

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  _PinStage _stage = _PinStage.enter;
  String _firstPin = '';
  String _currentInput = '';
  String? _errorMessage;
  bool _isSaving = false;

  int _failedAttempts = 0;
  Timer? _lockoutTimer;
  int _secondsRemaining = 0;

  bool get _isLockedOut => _secondsRemaining > 0;

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    super.dispose();
  }

  void _onKeyTap(String digit) {
    if (_isLockedOut || _isSaving) return;
    if (_currentInput.length >= widget.pinLength) return;

    setState(() {
      _errorMessage = null;
      _currentInput += digit;
    });

    if (_currentInput.length == widget.pinLength) {
      _handleComplete();
    }
  }

  void _onBackspace() {
    if (_isLockedOut || _isSaving) return;
    if (_currentInput.isEmpty) return;
    setState(() {
      _currentInput = _currentInput.substring(0, _currentInput.length - 1);
    });
  }

  void _handleComplete() {
    if (_stage == _PinStage.enter) {
      // Move to confirm stage
      _firstPin = _currentInput;
      Future.delayed(const Duration(milliseconds: 150), () {
        if (!mounted) return;
        setState(() {
          _stage = _PinStage.confirm;
          _currentInput = '';
        });
      });
    } else {
      // Confirm stage: compare against first PIN
      if (_currentInput == _firstPin) {
        _failedAttempts = 0;
        _savePin(_firstPin);
      } else {
        _failedAttempts++;

        if (_failedAttempts >= widget.maxAttempts) {
          _startLockout();
        } else {
          setState(() {
            final remaining = widget.maxAttempts - _failedAttempts;
            _errorMessage =
                'PINs do not match. $remaining attempt${remaining == 1 ? '' : 's'} left.';
            _stage = _PinStage.enter;
            _firstPin = '';
            _currentInput = '';
          });
        }
      }
    }
  }

  Future<void> _savePin(String pin) async {
    setState(() => _isSaving = true);

    try {
      // Never store the raw PIN — hash it before it leaves the device.
      final hashedPin = sha256.convert(utf8.encode(pin)).toString();

      await context.read<AuthProvider>().savePin(hashedPin);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Could not save PIN: ${e.toString()}';
        _stage = _PinStage.enter;
        _firstPin = '';
        _currentInput = '';
      });
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _startLockout() {
    setState(() {
      _stage = _PinStage.enter;
      _firstPin = '';
      _currentInput = '';
      _secondsRemaining = widget.lockoutSeconds;
      _errorMessage = 'Too many attempts. Try again in $_secondsRemaining s';
    });

    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _secondsRemaining--;
        if (_secondsRemaining <= 0) {
          _secondsRemaining = 0;
          _failedAttempts = 0;
          _errorMessage = null;
          timer.cancel();
        } else {
          _errorMessage =
              'Too many attempts. Try again in $_secondsRemaining s';
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isConfirmStage = _stage == _PinStage.confirm;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 24),

                  // Logo + Title
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.blueColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      Icons.shield_outlined,
                      color: AppColors.blueDark,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'BONGKA',
                    style: TextStyles.titleStyle.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isConfirmStage ? 'Step 2 of 2' : 'Step 1 of 2',
                    style: TextStyles.smallStyle.copyWith(
                      color: AppColors.blueColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isSaving
                        ? 'Saving your PIN...'
                        : isConfirmStage
                        ? 'Please Re-Enter your PIN'
                        : 'Set a PIN to protect your account',
                    style: TextStyles.smallStyle,
                  ),

                  const SizedBox(height: 20),

                  if (_isSaving) ...[
                    const SizedBox(height: 12),
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  ] else ...[
                    // PIN dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(widget.pinLength, (index) {
                        final bool filled = index < _currentInput.length;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: filled
                                ? AppColors.blueDark
                                : AppColors.textSecondary,
                          ),
                        );
                      }),
                    ),
                  ],

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyles.smallStyle.copyWith(
                        color: AppColors.redColor,
                        fontWeight: _isLockedOut
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Numeric keypad
                  Opacity(
                    opacity: (_isLockedOut || _isSaving) ? 0.4 : 1.0,
                    child: IgnorePointer(
                      ignoring: _isLockedOut || _isSaving,
                      child: _buildKeypad(),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    const double buttonSize = 64;

    Widget row(List<String> keys) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: keys.map((key) {
            if (key.isEmpty) {
              return const SizedBox(width: buttonSize, height: buttonSize);
            }
            if (key == 'back') {
              return _KeypadButton(
                size: buttonSize,
                transparent: true,
                onTap: _onBackspace,
                child: const Icon(Icons.backspace_outlined, size: 20),
              );
            }
            return _KeypadButton(
              size: buttonSize,
              onTap: () => _onKeyTap(key),
              child: Text(
                key,
                style: TextStyles.headingStyle.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      );
    }

    return Column(
      children: [
        row(['1', '2', '3']),
        row(['4', '5', '6']),
        row(['7', '8', '9']),
        row(['', '0', 'back']),
      ],
    );
  }
}

class _KeypadButton extends StatelessWidget {
  const _KeypadButton({
    required this.child,
    required this.onTap,
    required this.size,
    this.transparent = false,
  });

  final Widget child;
  final VoidCallback onTap;
  final double size;
  final bool transparent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: transparent ? Colors.transparent : AppColors.blueDark,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Center(child: child),
        ),
      ),
    );
  }
}
