import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_date_utils.dart';
import '../../../core/utils/unit_conversion.dart';
import '../../../data/models/culture_info.dart';

class RawDataTable extends StatefulWidget {
  final List<CultureInfo> data;

  const RawDataTable({super.key, required this.data});

  @override
  State<RawDataTable> createState() => _RawDataTableState();
}

class _RawDataTableState extends State<RawDataTable> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.soil800,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.soil600),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Text(
                    'Show raw data',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.leafGreenLight,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.leafGreenLight,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppColors.soil700),
                dataRowColor: WidgetStateProperty.resolveWith((states) {
                  final idx = states.contains(WidgetState.selected) ? 0 : 1;
                  return idx.isEven ? AppColors.soil800 : AppColors.soil700;
                }),
                columns: [
                  _col('Date'),
                  _col('Temp'),
                  _col('Air H.'),
                  _col('Ground H.'),
                  _col('Lux'),
                  _col('Pa'),
                ],
                rows: widget.data.take(50).toList().asMap().entries.map((e) {
                  final d = e.value;
                  final isEven = e.key.isEven;
                  return DataRow(
                    color: WidgetStateProperty.all(
                      isEven ? AppColors.soil800 : AppColors.soil700,
                    ),
                    cells: [
                      _cell(AppDateUtils.formatTimestamp(d.date)),
                      _cell(UnitConversion.formatTemperature(d.temperature)),
                      _cell(UnitConversion.formatInt(d.humidityAir)),
                      _cell(UnitConversion.formatInt(d.humidityGround)),
                      _cell(UnitConversion.formatInt(d.luminosity)),
                      _cell(UnitConversion.formatPressure(d.pressure)),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  DataColumn _col(String label) => DataColumn(
        label: Text(
          label,
          style: AppTypography.labelSmall.copyWith(color: AppColors.cream),
        ),
      );

  DataCell _cell(String text) => DataCell(
        Text(
          text,
          style: AppTypography.bodySmall.copyWith(color: AppColors.parchment),
        ),
      );
}
