import 'package:flutter/material.dart';
import 'package:insight_hub/feature/home_and_explore/widget/chart_builders/chart_helpers.dart';
import 'package:insight_hub/feature/home_and_explore/widget/chart_builders/chart_styles.dart';
import 'package:insight_hub/feature/home_and_explore/widget/safe_error_widget.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ColumnChartBuilder {
  const ColumnChartBuilder._();

  static Widget build(List<Map<String, dynamic>> rawData) {
    try {
      if (rawData.isEmpty) {
        return const SafeErrorWidget(message: 'No data available');
      }

      int? selectedIndex;

      return StatefulBuilder(
        builder: (context, setState) {
          return SizedBox(
            height: ChartStyles.selectableChartHeight,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              margin: ChartStyles.columnChartMargin,
              tooltipBehavior: ChartStyles.tooltipBehavior(
                format: 'point.x : point.y',
              ),
              primaryXAxis: ChartStyles.categoryAxis(),
              primaryYAxis: ChartStyles.hiddenNumericAxis(),
              series: [
                _buildSeries(
                  rawData,
                  selectedIndex,
                  (int? nextIndex) => setState(() {
                    selectedIndex = nextIndex;
                  }),
                ),
              ],
            ),
          );
        },
      );
    } catch (_) {
      return const SafeErrorWidget(message: 'Column chart failed');
    }
  }

  static ColumnSeries<Map<String, dynamic>, String> _buildSeries(
    List<Map<String, dynamic>> rawData,
    int? selectedIndex,
    ValueChanged<int?> onSelectionChanged,
  ) {
    return ColumnSeries<Map<String, dynamic>, String>(
      animationDuration: 900,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(ChartStyles.roundedBarRadius),
      ),
      spacing: ChartStyles.barSpacing,
      width: ChartStyles.barWidth,
      dataSource: rawData,
      xValueMapper: (data, index) {
        return ChartHelpers.selectedAwareLabel(data, index, selectedIndex);
      },
      yValueMapper: (data, _) => ChartHelpers.value(data),
      pointColorMapper: (data, index) {
        return ChartStyles.selectablePointColor(index, selectedIndex);
      },
      dataLabelSettings: const DataLabelSettings(
        isVisible: true,
        labelPosition: ChartDataLabelPosition.outside,
        textStyle: ChartStyles.dataLabelStyle,
      ),
      dataLabelMapper: (data, _) {
        return ChartHelpers.compactNumber(ChartHelpers.value(data));
      },
      onPointTap: (details) {
        onSelectionChanged(
          ChartHelpers.toggledSelection(details.pointIndex, selectedIndex),
        );
      },
    );
  }
}
