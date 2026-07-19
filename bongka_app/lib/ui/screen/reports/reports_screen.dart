import 'package:flutter/material.dart';
import '../../../theme/app_color.dart';
import '../../../theme/app_textStyle.dart';
import '../../../ui/widget/weekly_activity_chart.dart';

/// Displays the user's scan history summary and recent scans.
///
/// TODO: replace _mockSummary/_mockWeeklyData/_mockScans with real
/// data from report_repository.dart / ScanProvider once built —
/// ideally a single ReportModel, so these three stay consistent.
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  static const _mockSummary = (totalScans: 24, daysActive: 12, accuracy: 94);

  // [Mon, Tue, Wed, Thu, Fri, Sat, Sun] — matches ReportModel.weeklyData.
  static const List<int> _mockWeeklyData = [3, 5, 2, 6, 4, 1, 3];

  static const List<_ScanRow> _mockScans = [
    _ScanRow('Suspicious PayPal email', _Risk.high, '2h ago'),
    _ScanRow('Bank OTP verification', _Risk.medium, 'Yesterday'),
    _ScanRow('Delivery tracking link', _Risk.medium, 'Yesterday'),
    _ScanRow('Newsletter — Shopee', _Risk.safe, '2d ago'),
    _ScanRow('Team meeting invite', _Risk.safe, '3d ago'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        Text('Reports', style: TextStyles.headingStyle),
        const SizedBox(height: 20),

        // Your activity summary
        Text(
          'Your activity',
          style: TextStyles.bodyStyle.copyWith(
            color: AppColors.textColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Total Scans',
                value: '${_mockSummary.totalScans}',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'Days Active',
                value: '${_mockSummary.daysActive}',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'Accuracy',
                value: '${_mockSummary.accuracy}%',
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        Container(
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
                style: TextStyles.smallStyle.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              const WeeklyActivityChart(weeklyData: _mockWeeklyData),
            ],
          ),
        ),

        const SizedBox(height: 24),

        Text(
          'Recent Scans',
          style: TextStyles.bodyStyle.copyWith(
            color: AppColors.textColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),

        ..._mockScans.map((scan) => _ScanRowTile(scan: scan)),
      ],
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
              color: AppColors.textColor,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyles.smallStyle.copyWith(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

enum _Risk { high, medium, safe }

class _ScanRow {
  final String title;
  final _Risk risk;
  final String timeAgo;

  const _ScanRow(this.title, this.risk, this.timeAgo);
}

class _ScanRowTile extends StatelessWidget {
  const _ScanRowTile({required this.scan});

  final _ScanRow scan;

  Color get _riskColor {
    switch (scan.risk) {
      case _Risk.high:
        return AppColors.redColor;
      case _Risk.medium:
        return AppColors.yellowColor;
      case _Risk.safe:
        return AppColors.greenColor;
    }
  }

  String get _riskLabel {
    switch (scan.risk) {
      case _Risk.high:
        return 'HIGH';
      case _Risk.medium:
        return 'MED';
      case _Risk.safe:
        return 'SAFE';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            scan.risk == _Risk.safe
                ? Icons.check_circle
                : Icons.warning_amber_rounded,
            color: _riskColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              scan.title,
              style: TextStyles.bodyStyle.copyWith(
                color: AppColors.textColor,
                fontSize: 14,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _riskColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _riskLabel,
                  style: TextStyles.smallStyle.copyWith(
                    color: _riskColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                scan.timeAgo,
                style: TextStyles.smallStyle.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
