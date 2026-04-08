import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class DateRangeSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  final VoidCallback onCustom;

  const DateRangeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.onCustom,
  });

  static const _options = ['24h', '7d', '30d', 'Custom'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _options.map((label) {
          final isActive = selected == label;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: GestureDetector(
              onTap: () {
                if (label == 'Custom') {
                  onCustom();
                } else {
                  onChanged(label);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.leafGreen : AppColors.soil700,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: isActive ? AppColors.soil900 : AppColors.parchment,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
