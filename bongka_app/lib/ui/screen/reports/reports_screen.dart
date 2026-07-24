import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_color.dart';
import '../../../theme/app_textStyle.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/scan_provider.dart';
import '../../../model/scan_model.dart';
import '../../../model/report_model.dart';
import '../../widget/weekly_activity_chart.dart';
import '../analyzer/analysis_result_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  // Small getters so the rest of this file (widget builders below) can
  // keep reading _scans / _stats / _isLoading like before, just backed
  // by ScanProvider now instead of a local field.
  List<ScanModel> get _scans => context.watch<ScanProvider>().scans;
  ReportModel? get _stats => context.watch<ScanProvider>().stats;
  bool get _isLoading => context.watch<ScanProvider>().isLoadingReports;
  String? get _errorMessage => context.watch<ScanProvider>().reportsError;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId =
        Provider.of<AuthProvider>(context, listen: false).currentUser?.id ?? '';
    await context.read<ScanProvider>().loadReports(userId);
  }

  Future<void> _handleDelete(ScanModel scan) async {
    final scanProvider = context.read<ScanProvider>();
    final ok = await scanProvider.deleteScan(scan);
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Scan deleted')));
      _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(scanProvider.reportsError ?? 'Could not delete scan'),
        ),
      );
    }
  }

  void _openScan(ScanModel scan) {
    context.read<ScanProvider>().loadPastScan(scan);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AnalysisResultScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _loadingView();
    if (_errorMessage != null) return _errorView();

    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        Text('Reports', style: TextStyles.headingStyle),
        const SizedBox(height: 20),
        Text(
          'Your activity',
          style: TextStyles.bodyStyle.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        _statsRow(),
        const SizedBox(height: 20),
        _weeklyChart(),
        const SizedBox(height: 24),
        _scanListHeader(),
        const SizedBox(height: 12),
        if (_scans.isEmpty) _emptyState() else ..._scans.map(_scanTile),
      ],
    );
  }

  Widget _loadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.blueColor),
          const SizedBox(height: 16),
          Text(
            'Loading your reports...',
            style: TextStyles.smallStyle.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, color: AppColors.textMuted, size: 48),
          const SizedBox(height: 16),
          Text('Could not load reports', style: TextStyles.bodyStyle),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blueColor,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _statsRow() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Total Scans',
            value: '${_stats?.totalScans ?? 0}',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Days Active',
            value: '${_stats?.daysActive ?? 0}',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Accuracy',
            value: '${_stats?.accuracy ?? 0}%',
          ),
        ),
      ],
    );
  }

  Widget _weeklyChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This week',
            style: TextStyles.smallStyle.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          WeeklyActivityChart(
            weeklyData: _stats?.weeklyData ?? [0, 0, 0, 0, 0, 0, 0],
          ),
        ],
      ),
    );
  }

  Widget _scanListHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Recent Scans',
          style: TextStyles.bodyStyle.copyWith(fontWeight: FontWeight.w700),
        ),
        if (_scans.isNotEmpty)
          Text(
            'Tap to view • Swipe to delete',
            style: TextStyles.smallStyle.copyWith(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),
      ],
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.inbox_outlined,
            color: AppColors.textMuted,
            size: 36,
          ),
          const SizedBox(height: 12),
          Text(
            'No scans yet',
            style: TextStyles.bodyStyle.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Go to Home and tap Scan Message to get started',
            style: TextStyles.smallStyle.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _scanTile(ScanModel scan) {
    final color = scan.riskColor;

    return Dismissible(
      key: ValueKey(scan.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: AppColors.redColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.redColor),
      ),
      onDismissed: (_) => _handleDelete(scan),
      child: GestureDetector(
        onTap: () => _openScan(scan),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Row(
            children: [
              Icon(
                scan.riskLevel == 'SAFE'
                    ? Icons.check_circle
                    : Icons.warning_amber_rounded,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scan.messageText.length > 40
                          ? '${scan.messageText.substring(0, 40)}...'
                          : scan.messageText,
                      style: TextStyles.bodyStyle.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${scan.createdAt.day}/${scan.createdAt.month}/${scan.createdAt.year}',
                      style: TextStyles.smallStyle.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  scan.riskLabel,
                  style: TextStyles.smallStyle.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
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

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyles.bodyStyle.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyles.smallStyle.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
