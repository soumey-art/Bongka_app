import 'package:flutter/material.dart';
import '../../theme/app_color.dart';
import '../../theme/app_textStyle.dart';

/// Simple bar chart of scans-per-day for the Reports screen.
///
/// Takes 7 values in [Mon, Tue, Wed, Thu, Fri, Sat, Sun] order,
/// matching ReportModel.weeklyData exactly — pass that field
/// straight in once report_repository.dart supplies a real
/// ReportModel.
class WeeklyActivityChart extends StatelessWidget {
  const WeeklyActivityChart({
    super.key,
    required this.weeklyData,
    this.height = 120,
  });

  /// 7 values, Mon through Sun. Anything else will assert in debug.
  final List<int> weeklyData;
  final double height;

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    assert(
      weeklyData.length == 7,
      'WeeklyActivityChart expects 7 values (Mon-Sun), got ${weeklyData.length}.',
    );

    final maxValue = weeklyData.isEmpty
        ? 1
        : weeklyData.reduce((a, b) => a > b ? a : b).clamp(1, 1 << 30);

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(weeklyData.length, (i) {
          final value = weeklyData[i];
          final barHeightFraction = value / maxValue;
          final isToday = i == DateTime.now().weekday - 1;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '$value',
                    style: TextStyles.smallStyle.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: barHeightFraction.clamp(0.04, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isToday
                                ? AppColors.blueColor
                                : AppColors.blueColor.withValues(alpha: 0.35),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _dayLabels[i],
                    style: TextStyles.smallStyle.copyWith(
                      color: isToday
                          ? AppColors.blueColor
                          : AppColors.textMuted,
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
