import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../model/scan_model.dart';
import '../../../provider/scan_provider.dart';
import '../../../data/service/report_export_service.dart';
import '../../../theme/app_color.dart';
import '../../../theme/app_textStyle.dart';
import '../../widget/threat_card.dart';
import 'phishing_detector_screen.dart';

class AnalysisResultScreen extends StatefulWidget {
  const AnalysisResultScreen({super.key});

  @override
  State<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends State<AnalysisResultScreen> {
  final ReportExportService _exportService = ReportExportService();

  bool _isResetting = false;
  bool _isSaving = false;
  bool _isSharing = false;

  Future<void> _saveReport(ScanModel result) async {
    setState(() => _isSaving = true);
    try {
      final saved = await _exportService.saveToDevice(result);
      if (!mounted || !saved) return;
      _showSnack('Report saved.', Colors.green.shade600);
    } catch (e) {
      _showSnack('Could not save report: $e', Colors.red.shade600);
    }
    if (mounted) setState(() => _isSaving = false);
  }

  Future<void> _shareReport(ScanModel result) async {
    setState(() => _isSharing = true);
    try {
      await _exportService.shareReport(result);
    } catch (e) {
      _showSnack('Could not share report: $e', Colors.red.shade600);
    }
    if (mounted) setState(() => _isSharing = false);
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showExportSheet(ScanModel result) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceColor,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.save_alt, color: AppColors.blueColor),
              title: Text('Save to Device', style: TextStyles.bodyStyle),
              onTap: () {
                Navigator.pop(ctx);
                _saveReport(result);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.share_outlined,
                color: AppColors.blueColor,
              ),
              title: Text('Share Report', style: TextStyles.bodyStyle),
              onTap: () {
                Navigator.pop(ctx);
                _shareReport(result);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _scanAnother() async {
    setState(() => _isResetting = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    context.read<ScanProvider>().reset();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PhishingDetectorScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = Provider.of<ScanProvider>(context).currentResult;

    if (result == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Center(
          child: Text('No result available', style: TextStyles.bodyStyle),
        ),
      );
    }

    final riskColor = result.riskLevel == 'HIGH'
        ? AppColors.redColor
        : result.riskLevel == 'MEDIUM'
        ? AppColors.yellowColor
        : AppColors.greenColor;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        title: Text('Analysis Result', style: TextStyles.headingStyle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _banner(result, riskColor),
            const SizedBox(height: 20),
            if (result.threats.isNotEmpty) _threatsList(result),
            const SizedBox(height: 20),
            _safeBrowsingBox(result),
            const SizedBox(height: 20),
            _recommendationBox(result, riskColor),
            const SizedBox(height: 24),
            _exportButton(result),
            const SizedBox(height: 12),
            _actionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _banner(ScanModel result, Color riskColor) {
    final label = result.riskLevel == 'HIGH'
        ? 'Malicious'
        : result.riskLevel == 'MEDIUM'
        ? 'Suspicious'
        : 'No threats found';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: riskColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            result.riskLevel == 'HIGH'
                ? Icons.dangerous_outlined
                : Icons.warning_amber_rounded,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyles.headingStyle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${result.threats.length} indicator(s) matched • Score ${result.riskScore}/100',
                  style: TextStyles.smallStyle.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _threatsList(ScanModel result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'THREATS DETECTED',
          style: TextStyles.smallStyle.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...result.threats.map(
          (t) => ThreatCard(
            item: ThreatItem(
              title: t.explanation,
              risk: t.severity == 'HIGH'
                  ? ThreatRiskLevel.high
                  : t.severity == 'MEDIUM'
                  ? ThreatRiskLevel.medium
                  : ThreatRiskLevel.safe,
              timeAgo: 'Just now',
            ),
          ),
        ),
      ],
    );
  }

  Widget _safeBrowsingBox(ScanModel result) {
    final confirmed = result.threats.any((t) => t.type == 'confirmedPhishing');
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Icon(
            confirmed ? Icons.gpp_bad_outlined : Icons.verified_user_outlined,
            color: confirmed ? AppColors.redColor : AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              result.safeBrowsingSummary,
              style: TextStyles.smallStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _recommendationBox(ScanModel result, Color riskColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: riskColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: riskColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.tips_and_updates_outlined, color: riskColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(result.recommendation, style: TextStyles.smallStyle),
          ),
        ],
      ),
    );
  }

  Widget _exportButton(ScanModel result) {
    final busy = _isSaving || _isSharing;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: busy ? null : () => _showExportSheet(result),
        icon: busy
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.ios_share, size: 18),
        label: Text(
          _isSaving
              ? 'Saving...'
              : _isSharing
              ? 'Preparing...'
              : 'Export Report',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blueColor,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _actionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isResetting ? null : _scanAnother,
            icon: const Icon(Icons.search),
            label: Text(_isResetting ? 'Loading...' : 'Scan Another'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            icon: const Icon(Icons.home),
            label: const Text('Go Home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blueColor,
              foregroundColor: AppColors.blueDark,
            ),
          ),
        ),
      ],
    );
  }
}
