import 'package:flutter/material.dart';
import '../../theme/app_color.dart';
import '../../theme/app_textStyle.dart';

/// Circular "Cyber Safety Score" ring shown on the Home dashboard.
class ScoreRing extends StatelessWidget {
  const ScoreRing({
    super.key,
    required this.score,
    this.size = 96, // was 72
    this.strokeWidth = 10, // was 7
  });

  final int score;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final clamped = score.clamp(0, 100);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: clamped / 100,
              strokeWidth: strokeWidth,
              backgroundColor: AppColors.backgroundColor,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.blueColor,
              ),
            ),
          ),
          Text(
            '$clamped%',
            style: TextStyles.bodyStyle.copyWith(
              fontWeight: FontWeight.w700,
              fontSize:
                  size / 4.3, // scales with the ring instead of staying fixed
            ),
          ),
        ],
      ),
    );
  }
}
