import 'package:flutter/material.dart';
import 'package:insight_hub/constant/app_colors.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_treemap/treemap.dart';
import 'package:insight_hub/utils/safe_parser.dart';
import 'package:insight_hub/widget/safe_error_widget.dart';

class ChartBuilders {
  /// LINE CHART
  static Widget buildLineChart(List<Map<String, dynamic>> rawData) {
    try {
      if (rawData.isEmpty) {
        return const SafeErrorWidget(message: 'No data available');
      }

      return Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return SfCartesianChart(
            primaryXAxis: const CategoryAxis(isVisible: true),
            primaryYAxis: const NumericAxis(isVisible: true),
            series: [
              LineSeries<Map<String, dynamic>, String>(
                animationDuration: 0,
                dataSource: rawData,
                xValueMapper: (data, _) =>
                    SafeParser.getString(data, 'x', defaultValue: ''),
                yValueMapper: (data, _) => SafeParser.getDouble(data, 'y'),
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ],
          );
        },
      );
    } catch (e) {
      return const SafeErrorWidget(message: 'Line chart failed');
    }
  }

  /// BAR CHART
  static Widget buildBarChart(List<Map<String, dynamic>> rawData) {
    try {
      if (rawData.isEmpty) {
        return const SafeErrorWidget(message: 'No data available');
      }

      return Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return SfCartesianChart(
            primaryXAxis: const CategoryAxis(),
            primaryYAxis: const NumericAxis(),
            series: [
              ColumnSeries<Map<String, dynamic>, String>(
                animationDuration: 0,
                dataSource: rawData,
                xValueMapper: (data, _) =>
                    SafeParser.getString(data, 'x', defaultValue: ''),
                yValueMapper: (data, _) => SafeParser.getDouble(data, 'y'),
                color: theme.colorScheme.secondary,
              ),
            ],
          );
        },
      );
    } catch (e) {
      return const SafeErrorWidget(message: 'Bar chart failed');
    }
  }

  /// PIE CHART
  static Widget buildPieChart(List<Map<String, dynamic>> rawData) {
    try {
      if (rawData.isEmpty) {
        return const SafeErrorWidget(message: 'No data available');
      }

      return Builder(
        builder: (context) {
          return SfCircularChart(
            series: [
              PieSeries<Map<String, dynamic>, String>(
                animationDuration: 0,
                dataSource: rawData,
                xValueMapper: (data, _) =>
                    SafeParser.getString(data, 'x', defaultValue: ''),
                yValueMapper: (data, _) => SafeParser.getDouble(data, 'y'),
                dataLabelSettings: const DataLabelSettings(isVisible: false),
              ),
            ],
          );
        },
      );
    } catch (e) {
      return const SafeErrorWidget(message: 'Pie chart failed');
    }
  }

  /// DOUGHNUT CHART
  static Widget buildDoughnutChart(List<Map<String, dynamic>> rawData) {
    try {
      if (rawData.isEmpty) {
        return const SafeErrorWidget(message: 'No data available');
      }

      // Calculate total for percentages
      double total = 0;
      for (var item in rawData) {
        total += SafeParser.getDouble(item, 'y');
      }
      if (total == 0) total = 1;

      bool showRealValues = false;

      return StatefulBuilder(
        builder: (context, setState) {
          return SfCircularChart(
            onDataLabelTapped: (DataLabelTapDetails details) {
              setState(() {
                showRealValues = !showRealValues;
              });
            },
            legend: const Legend(
              isVisible: true,
              position: LegendPosition.bottom,
              overflowMode: LegendItemOverflowMode.wrap,
              textStyle: TextStyle(fontSize: 10),
            ),
            series: [
              DoughnutSeries<Map<String, dynamic>, String>(
                animationDuration: 0,
                dataSource: rawData,
                xValueMapper: (data, _) =>
                    SafeParser.getString(data, 'x', defaultValue: ''),
                yValueMapper: (data, _) => SafeParser.getDouble(data, 'y'),
                dataLabelMapper: (data, _) {
                  final val = SafeParser.getDouble(data, 'y');
                  if (showRealValues) {
                    return val.toInt().toString();
                  }
                  final ratio = (val / total * 100).toStringAsFixed(1);
                  return '$ratio%';
                },
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  labelPosition: ChartDataLabelPosition.outside,
                  textStyle: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  useSeriesColor: true,
                ),
                innerRadius: '60%',
              ),
            ],
          );
        },
      );
    } catch (e) {
      return const SafeErrorWidget(message: 'Doughnut chart failed');
    }
  }

  /// SPARKLINE (MINI LINE)
  static Widget buildSparklineChart(List<Map<String, dynamic>> rawData) {
    try {
      if (rawData.isEmpty) return const SizedBox.shrink();

      return Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return SfCartesianChart(
            primaryXAxis: const CategoryAxis(isVisible: false),
            primaryYAxis: const NumericAxis(isVisible: false),
            plotAreaBorderWidth: 0,
            series: [
              LineSeries<Map<String, dynamic>, String>(
                animationDuration: 0,
                dataSource: rawData,
                xValueMapper: (data, _) =>
                    SafeParser.getString(data, 'x', defaultValue: ''),
                yValueMapper: (data, _) => SafeParser.getDouble(data, 'y'),
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ],
          );
        },
      );
    } catch (e) {
      return const SafeErrorWidget(message: 'Sparkline failed');
    }
  }

  /// TREEMAP CHART
  static Widget buildTreemap(List<Map<String, dynamic>> rawData) {
    try {
      if (rawData.isEmpty) {
        return const SafeErrorWidget(message: 'No data available');
      }

      // Find max weight for color scaling
      double maxWeight = 0;
      for (var item in rawData) {
        double val = SafeParser.getDouble(item, 'y');
        if (val > maxWeight) maxWeight = val;
      }
      if (maxWeight == 0) maxWeight = 1;

      // Dynamic height based on items (min 300, max 600)
      final double dynamicHeight = (rawData.length * 50.0).clamp(300.0, 600.0);

      return Builder(
        builder: (context) {
          // Multi-color palette for professional look
          final List<Color> palette = [
            Colors.teal.shade300,
            Colors.blue.shade400,
            Colors.indigo.shade600,
          ];

          return Container(
            height: dynamicHeight,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SfTreemap(
              dataCount: rawData.length,
              weightValueMapper: (int index) {
                return SafeParser.getDouble(rawData[index], 'y');
              },
              levels: [
                TreemapLevel(
                  groupMapper: (int index) {
                    return SafeParser.getString(rawData[index], 'x');
                  },
                  colorValueMapper: (TreemapTile tile) {
                    final double ratio =
                        (tile.weight / maxWeight).clamp(0.0, 1.0);

                    // Interpolate across multiple colors
                    if (ratio < 0.5) {
                      return Color.lerp(palette[0], palette[1], ratio * 2) ??
                          palette[0];
                    } else {
                      return Color.lerp(palette[1], palette[2], (ratio - 0.5) * 2) ??
                          palette[1];
                    }
                  },
                  labelBuilder: (BuildContext context, TreemapTile tile) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              tile.group,
                              style: const TextStyle(
                                color: AppColors.bgWhite,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tile.weight.toInt().toString(),
                              style: TextStyle(
                                color: AppColors.bgWhite.withOpacity(0.9),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      return const SafeErrorWidget(message: 'Treemap failed');
    }
  }

  /// GROUPED BAR CHART (HORIZONTAL)
  static Widget buildGroupedBarChart(List<Map<String, dynamic>> rawData) {
    try {
      if (rawData.isEmpty) {
        return const SafeErrorWidget(message: 'No data available');
      }

      return Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return SizedBox(
            width: double.infinity,
            height: 320,
            child: SfCartesianChart(
              margin: EdgeInsets.zero,
              plotAreaBorderWidth: 0,
              primaryXAxis: const CategoryAxis(
                labelStyle: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
                labelIntersectAction: AxisLabelIntersectAction.wrap,
                axisLine: AxisLine(width: 0),
                majorGridLines: MajorGridLines(width: 0),
                majorTickLines: MajorTickLines(width: 0),
              ),
              primaryYAxis: const NumericAxis(
                name: 'PrimaryAxis',
                axisLine: AxisLine(width: 0),
                majorGridLines: MajorGridLines(width: 0),
                majorTickLines: MajorTickLines(width: 0),
                // Fix: Making it invisible via style instead of isVisible: false to prevent layout assertion errors
                labelStyle: TextStyle(color: Colors.transparent, fontSize: 0),
              ),
              axes: const <ChartAxis>[
                NumericAxis(
                  name: 'SalaryAxis',
                  opposedPosition: true,
                  labelStyle: TextStyle(color: Colors.transparent, fontSize: 0),
                  axisLine: AxisLine(width: 0),
                  majorGridLines: MajorGridLines(width: 0),
                )
              ],
              legend: const Legend(
                isVisible: true,
                position: LegendPosition.bottom,
                overflowMode: LegendItemOverflowMode.wrap,
                textStyle: TextStyle(fontSize: 10),
              ),
              tooltipBehavior: TooltipBehavior(
                enable: true,
                builder: (dynamic data, dynamic point, dynamic series,
                    int pointIndex, int seriesIndex) {
                  final Map<String, dynamic> item =
                      Map<String, dynamic>.from(data);
                  final company = SafeParser.getString(item, 'x');
                  final jobs =
                      SafeParser.getDouble(item, 'y_jobs_count').toInt();
                  final salary = SafeParser.getDouble(item, 'y_total_salary');

                  return Container(
                    padding: const EdgeInsets.all(8.0),
                    constraints: const BoxConstraints(maxWidth: 160),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Text(
                        company,
                        style: const TextStyle(
                          color: AppColors.bgWhite,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Jobs: $jobs',
                        style: const TextStyle(
                          color: AppColors.bgWhite,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        'Salary: \$${(salary / 1000).toStringAsFixed(1)}k',
                        style: const TextStyle(
                          color: AppColors.bgWhite,
                          fontSize: 10,
                        ),
                      ),
                      ],
                    ),
                  );
                },
              ),
              series: <CartesianSeries<Map<String, dynamic>, String>>[
                BarSeries<Map<String, dynamic>, String>(
                  name: 'Jobs Count',
                  animationDuration: 500, // Non-zero for stable layout cycles
                  dataSource: rawData,
                  xValueMapper: (data, _) => SafeParser.getString(data, 'x'),
                  yValueMapper: (data, _) =>
                      SafeParser.getDouble(data, 'y_jobs_count'),
                  color: theme.colorScheme.primary,
                  yAxisName: 'PrimaryAxis',
                ),
                BarSeries<Map<String, dynamic>, String>(
                  name: 'Total Salary',
                  animationDuration: 500,
                  dataSource: rawData,
                  xValueMapper: (data, _) => SafeParser.getString(data, 'x'),
                  yValueMapper: (data, _) {
                    final val = SafeParser.getDouble(data, 'y_total_salary');
                    return val / 1000.0;
                  },
                  color: theme.colorScheme.secondary,
                  yAxisName: 'SalaryAxis',
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      return const SafeErrorWidget(message: 'Grouped bar chart failed');
    }
  }
}