import 'package:flutter/material.dart';
import '../../../theme/app_color.dart';
import '../../../theme/app_textStyle.dart';
import 'analyzing_screen.dart';

/// Message input form for the phishing scanner. Hands the raw text
/// off to AnalyzingScreen, which owns triggering the actual scan.
class PhishingDetectorScreen extends StatefulWidget {
  const PhishingDetectorScreen({super.key});

  @override
  State<PhishingDetectorScreen> createState() => _PhishingDetectorScreenState();
}

class _PhishingDetectorScreenState extends State<PhishingDetectorScreen> {
  final TextEditingController _messageController = TextEditingController();
  static const int _maxChars = 2000;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _handleScan() {
    final text = _messageController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paste or type a message to scan first.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AnalyzingScreen(messageText: text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        foregroundColor: AppColors.blueDark,
        title: Text('Phishing Detector', style: TextStyles.headingStyle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Paste a suspicious email, text message, or link below. '
                'We\'ll check it for common phishing signals.',
                style: TextStyles.smallStyle.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: TextField(
                    controller: _messageController,
                    maxLength: _maxChars,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: TextStyles.bodyStyle.copyWith(
                      color: AppColors.textColor,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Paste or type the suspicious message here...',
                      hintStyle: TextStyles.smallStyle.copyWith(
                        color: AppColors.textMuted,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                      border: InputBorder.none,
                      counterStyle: TextStyles.smallStyle.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _handleScan,
                  icon: const Icon(Icons.search, color: AppColors.blueDark),
                  label: Text(
                    'SCAN MESSAGE',
                    style: TextStyles.buttonStyle.copyWith(
                      color: AppColors.blueDark,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
