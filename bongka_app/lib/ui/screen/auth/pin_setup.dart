import 'package:flutter/material.dart';
import '../../../theme/app_color.dart';
import '../../../theme/app_textStyle.dart';
/*import '../home/home_screen.dart';*/

enum _PinStage { enter, confirm }

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key, this.pinLength = 6});

  final int pinLength;

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  _PinStage _stage = _PinStage.enter;
  String _firstPin = '';
  String _currentInput = '';
  String? _errorMessage;

  void _onKeyTap(String digit) {
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
    if (_currentInput.isEmpty) return;
    setState(() {
      _currentInput = _currentInput.substring(0, _currentInput.length - 1);
    });
  }

  void _handleComplete() {
    if (_stage == _PinStage.enter) {
      _firstPin = _currentInput;
      Future.delayed(const Duration(milliseconds: 150), () {
        if (!mounted) return;
        setState(() {
          _stage = _PinStage.confirm;
          _currentInput = '';
        });
      });
    } else {
      if (_currentInput == _firstPin) {
        Future.delayed(const Duration(milliseconds: 150), () {
          if (!mounted) return;
          /*Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );*/
        });
      } else {
        setState(() {
          _errorMessage = 'PINs do not match. Try again.';
          _stage = _PinStage.enter;
          _firstPin = '';
          _currentInput = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isConfirmStage = _stage == _PinStage.confirm;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            // Keeps a phone-like width even on wide desktop/web windows
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
                      color: AppColors.blueColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      Icons.shield_outlined,
                      color: AppColors.blueColor,
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
                    isConfirmStage
                        ? 'Please Re-Enter your PIN'
                        : 'Please Enter your PIN',
                    style: TextStyles.smallStyle,
                  ),

                  const SizedBox(height: 20),

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
                              ? AppColors.blueColor
                              : const Color(0xFFD9D9D9),
                        ),
                      );
                    }),
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      style: TextStyles.smallStyle.copyWith(
                        color: AppColors.redColor,
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Numeric keypad - fixed circle size, doesn't stretch
                  _buildKeypad(),

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
        color: transparent ? Colors.transparent : const Color(0xFFE9E9E9),
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
