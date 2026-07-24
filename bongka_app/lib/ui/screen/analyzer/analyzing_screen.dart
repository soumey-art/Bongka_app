import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_color.dart';
import '../../../theme/app_textStyle.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/scan_provider.dart';
import 'analysis_result_screen.dart';

class AnalyzingScreen extends StatefulWidget {
  final String messageText;
  const AnalyzingScreen({super.key, required this.messageText});

  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<AnalyzingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  Timer? _stepTimer;
  int _stepIndex = 0;

  static const List<String> _steps = [
    'Checking keywords and urgency language',
    'Scanning links and domains',
    'Verifying with Google Safe Browsing',
    'Checking sender authenticity (SPF / DKIM / DMARC)',
    'Calculating risk score',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    // Cycles through the step labels so the loading screen reflects what
    // the analyzer is actually doing, instead of a single static line.
    _stepTimer = Timer.periodic(const Duration(milliseconds: 900), (_) {
      if (!mounted) return;
      setState(() => _stepIndex = (_stepIndex + 1) % _steps.length);
    });

    // Deferred to after the first frame — calling this directly in initState
    // triggers notifyListeners() while the widget tree is still building,
    // which is what caused the "setState() called during build" error.
    WidgetsBinding.instance.addPostFrameCallback((_) => _runAnalysis());
  }

  Future<void> _runAnalysis() async {
    final scanProvider = Provider.of<ScanProvider>(context, listen: false);
    final userId =
        Provider.of<AuthProvider>(context, listen: false).currentUser?.id ?? '';

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await scanProvider.analyzeMessage(widget.messageText, userId, authProvider);

    if (!mounted) return;

    if (scanProvider.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(scanProvider.error!)));
      Navigator.pop(context); // back to the scan form instead of a stale result
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AnalysisResultScreen()),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _stepTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              turns: _animController,
              child: const Icon(
                Icons.shield_outlined,
                size: 80,
                color: AppColors.blueColor,
              ),
            ),
            const SizedBox(height: 32),
            Text('Analyzing message...', style: TextStyles.headingStyle),
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _steps[_stepIndex],
                key: ValueKey(_stepIndex),
                textAlign: TextAlign.center,
                style: TextStyles.smallStyle,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: AppColors.blueColor),
          ],
        ),
      ),
    );
  }
}
