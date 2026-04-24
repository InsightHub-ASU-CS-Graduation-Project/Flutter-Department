import 'package:flutter/material.dart';
import 'package:insight_hub/widget/chart_builders.dart';
import 'package:insight_hub/widget/safe_error_widget.dart';
import 'package:insight_hub/utils/safe_parser.dart';

class DynamicCard extends StatelessWidget {
  final Map<String, dynamic>? data;

  const DynamicCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    try {
      if (data == null || data!.isEmpty) {
        return const SafeErrorWidget(message: 'No data provided');
      }

      final rawValue = data!['data'];
      final value = rawValue?.toString() ?? '0';

      final suffix = SafeParser.getString(data, 'suffix');

      final rawSparkline = SafeParser.getList(data, 'sparkline_data');
      final sparklineData = rawSparkline
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// VALUE + SUFFIX
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (suffix.isNotEmpty) ...[
                  const SizedBox(width: 8.0),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      suffix,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            /// SPARKLINE
            if (sparklineData.isNotEmpty) ...[
              const SizedBox(height: 12.0),
              SizedBox(
                height: 64,
                child: ChartBuilders.buildSparklineChart(sparklineData),
              ),
            ],
          ],
        ),
      );
    } catch (e) {
      return const SafeErrorWidget(message: 'Card failed');
    }
  }
}
