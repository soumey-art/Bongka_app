import 'package:flutter/material.dart';
import 'package:pract_app/data/service/file_import_server.dart';
import '../../../theme/app_color.dart';
import '../../../theme/app_textStyle.dart';
import 'analyzing_screen.dart';

class PhishingDetectorScreen extends StatefulWidget {
  const PhishingDetectorScreen({super.key});

  @override
  State<PhishingDetectorScreen> createState() => _PhishingDetectorScreenState();
}

class _PhishingDetectorScreenState extends State<PhishingDetectorScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FileImportService _fileImportService = FileImportService();
  static const int _maxChars = 2000;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  bool _isImporting = false;

  // Device feature: FILE STORAGE.
  // Lets the user pick a .txt or .eml file from their phone (e.g. an
  // email exported from Gmail as "Show original" and saved, or a
  // screenshot-free copy of a suspicious SMS) and loads its contents
  // straight into the scan box.
  Future<void> _handleImportFile() async {
    setState(() => _isImporting = true);
    try {
      final file = await _fileImportService.pickTextFile();
      if (file == null) return; // user cancelled

      if (file.content.trim().isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('That file appears to be empty.')),
        );
        return;
      }

      // Automatically places the imported content into the detector
      // text field, ready to scan.
      setState(() {
        _messageController.text = file.content;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Imported "${file.name}"')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not read file: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
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
        foregroundColor: AppColors.textColor,
        title: Text('Phishing Detector', style: TextStyles.headingStyle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.blueColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.blueColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.blueColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Paste a suspicious SMS, message, email body, or "
                        "full email source (headers included — e.g. Gmail "
                        "→ ⋮ → Show original). We'll check the text, links, "
                        "and sender headers for phishing signals.",
                        style: TextStyles.smallStyle.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Import from device storage
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isImporting ? null : _handleImportFile,
                  icon: _isImporting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.folder_open, size: 18),
                  label: Text(
                    _isImporting
                        ? 'Opening file...'
                        : 'Import .txt / .eml file',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.blueColor,
                    side: const BorderSide(color: AppColors.blueColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Message input — dark bg, white text
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
                    style: const TextStyle(
                      color: AppColors.textColor,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    cursorColor: AppColors.blueColor,
                    decoration: InputDecoration(
                      hintText: 'Paste or type the suspicious message here...',
                      hintStyle: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      counterStyle: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Scan button — disabled when empty
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _messageController.text.trim().isNotEmpty
                      ? _handleScan
                      : null,
                  icon: Icon(
                    Icons.search,
                    color: _messageController.text.trim().isNotEmpty
                        ? AppColors.blueDark
                        : AppColors.textMuted,
                  ),
                  label: Text(
                    'SCAN MESSAGE',
                    style: TextStyles.buttonStyle.copyWith(
                      color: _messageController.text.trim().isNotEmpty
                          ? AppColors.blueDark
                          : AppColors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _messageController.text.trim().isNotEmpty
                        ? AppColors.blueColor
                        : AppColors.surfaceColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: _messageController.text.trim().isNotEmpty
                          ? BorderSide.none
                          : const BorderSide(color: AppColors.surfaceBorder),
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
