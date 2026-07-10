import 'package:flutter/material.dart';
import '../../../theme/app_color.dart';
import '../../../theme/app_textStyle.dart';

/// Placeholder for the message-analysis flow. Replace with the real
/// input form -> analyzing_screen.dart -> analysis_result_screen.dart
/// pipeline, backed by phishing_detector_service.dart.
class PhishingDetectorScreen extends StatelessWidget {
  const PhishingDetectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textColor,
        title: Text('Analyze Message', style: TextStyles.headingStyle),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.mail_outline, size: 48, color: AppColors.blueColor),
              const SizedBox(height: 16),
              Text(
                'Message analysis coming soon',
                style: TextStyles.bodyStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Paste a suspicious message here to check it for phishing signals.',
                textAlign: TextAlign.center,
                style: TextStyles.smallStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
