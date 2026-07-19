import 'package:flutter/material.dart';
import '../../theme/app_color.dart';
import '../../theme/app_textStyle.dart';

enum ThreatRiskLevel { high, medium, safe }

/// A single scanned-message outcome. Public (not private to
/// home_screen.dart) since Reports will likely want to render the
/// same shape of data for full scan history.
class ThreatItem {
  final String title;
  final ThreatRiskLevel risk;
  final String timeAgo;

  const ThreatItem({
    required this.title,
    required this.risk,
    required this.timeAgo,
  });
}

/// Renders a single [ThreatItem] as a card: icon, title, risk pill,
/// and relative time.
class ThreatCard extends StatelessWidget {
  const ThreatCard({super.key, required this.item});

  final ThreatItem item;

  Color get _riskColor {
    switch (item.risk) {
      case ThreatRiskLevel.high:
        return AppColors.redColor;
      case ThreatRiskLevel.medium:
        return AppColors.yellowColor;
      case ThreatRiskLevel.safe:
        return AppColors.greenColor;
    }
  }

  String get _riskLabel {
    switch (item.risk) {
      case ThreatRiskLevel.high:
        return 'HIGH';
      case ThreatRiskLevel.medium:
        return 'MED';
      case ThreatRiskLevel.safe:
        return 'SAFE';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.blueDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            item.risk == ThreatRiskLevel.safe
                ? Icons.check_circle
                : Icons.warning_amber_rounded,
            color: _riskColor,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.title,
              style: TextStyles.bodyStyle.copyWith(fontSize: 14),
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
                item.timeAgo,
                style: TextStyles.smallStyle.copyWith(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
