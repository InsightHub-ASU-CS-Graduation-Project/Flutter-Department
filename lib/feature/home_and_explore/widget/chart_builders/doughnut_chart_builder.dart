import 'package:flutter/material.dart';
import 'package:InsightHub/feature/home_and_explore/widget/chart_builders/chart_helpers.dart';
import 'package:InsightHub/feature/home_and_explore/widget/chart_builders/chart_styles.dart';
import 'package:InsightHub/feature/home_and_explore/widget/safe_error_widget.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DoughnutChartBuilder {
  const DoughnutChartBuilder._();

  static Widget build(List<Map<String, dynamic>> rawData) {
    try {
      if (rawData.isEmpty) {
        return const SafeErrorWidget(message: 'No data available');
      }

      final total = ChartHelpers.totalValue(rawData);
      bool showRealValues = false;

      return StatefulBuilder(
        builder: (context, setState) {
          return SfCircularChart(
            onDataLabelTapped: (_) {
              setState(() {
                showRealValues = !showRealValues;
              });
            },
            legend: const Legend(
              isVisible: true,
              position: LegendPosition.bottom,
              overflowMode: LegendItemOverflowMode.wrap,
              textStyle: ChartStyles.legendTextStyle,
            ),
            series: [
              DoughnutSeries<Map<String, dynamic>, String>(
                animationDuration: 1000,
                dataSource: rawData,
                xValueMapper: (data, _) => ChartHelpers.label(data),
                yValueMapper: (data, _) => ChartHelpers.value(data),
                dataLabelMapper: (data, _) {
                  return _formatLabel(data, total, showRealValues);
                },
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  labelPosition: ChartDataLabelPosition.outside,
                  textStyle: ChartStyles.circularDataLabelStyle,
                  useSeriesColor: true,
                ),
                innerRadius: '60%',
              ),
            ],
          );
        },
      );
    } catch (_) {
      return const SafeErrorWidget(message: 'Doughnut chart failed');
    }
  }

  static String _formatLabel(
    Map<String, dynamic> data,
    double total,
    bool showRealValues,
  ) {
    final value = ChartHelpers.value(data);
    if (showRealValues) return value.toInt().toString();

    final ratio = (value / total * 100).toStringAsFixed(1);
    return '$ratio%';
  }
}
