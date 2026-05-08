import 'package:flutter/material.dart';
import 'package:insight_hub/core/constant/app_colors.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_treemap/treemap.dart';
import 'package:insight_hub/core/utils/safe_parser.dart';
import 'package:insight_hub/feature/home_and_explore/widget/safe_error_widget.dart';

class ChartBuilders {
  /// LINE CHART
 static Widget buildLineChart(List<Map<String, dynamic>> rawData) {
    try {
      if (rawData.isEmpty) {
        return const SafeErrorWidget(message: 'No data available');
      }

      return Builder(
        builder: (context) {
          return SfCartesianChart(
            // إخفاء إطار منطقة الرسم لجعلها تبدو نظيفة تماماً
            plotAreaBorderWidth: .5, 
            
            // إخفاء المحور السيني (X) إذا كنت لا تريده، أو تركه حسب حاجتك
            primaryXAxis: const CategoryAxis(
              isVisible: true, // اجعلها true إذا أردت رؤية التصنيفات بالأسفل
              majorGridLines: MajorGridLines(width: 0.5),
              
            ),
            
            // المحور الصادي (Y) - الجزء المطلوب إخفاؤه
            primaryYAxis: const NumericAxis(
              isVisible: true, // إخفاء المحور تماماً
              majorGridLines: MajorGridLines(width: .5),
            ),

            series: [
              LineSeries<Map<String, dynamic>, String>(
                animationDuration: 1000, // إضافة حركة خفيفة تعطي مظهراً احترافياً
                dataSource: rawData,
                xValueMapper: (data, _) =>
                    SafeParser.getString(data, 'x', defaultValue: ''),
                yValueMapper: (data, _) => SafeParser.getDouble(data, 'y'),
                color: AppColors.success,
                width: 3, // زيادة السمك قليلاً ليناسب الرسم الكروكي
                
                // إضافة النقاط عند القمم
                markerSettings: const MarkerSettings(
                  isVisible: true,
                  height: 4,
                  width: 4,
                  shape: DataMarkerType.circle,
                ),

                // تفعيل ظهور الأرقام (Data Labels) فوق الخط
                     dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  labelAlignment: ChartDataLabelAlignment.top,
                  
                  textStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),)
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
                color: AppColors.success,
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
                color: AppColors.primary,
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
                    final double ratio = (tile.weight / maxWeight).clamp(
                      0.0,
                      1.0,
                    );

                    // Interpolate across multiple colors
                    if (ratio < 0.5) {
                      return Color.lerp(palette[0], palette[1], ratio * 2) ??
                          palette[0];
                    } else {
                      return Color.lerp(
                            palette[1],
                            palette[2],
                            (ratio - 0.5) * 2,
                          ) ??
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
static Widget buildGroupedBarChart(
  List<Map<String, dynamic>> rawData,
) {
  try {
    if (rawData.isEmpty) {
      return const SafeErrorWidget(
        message: 'No data available',
      );
    }

    String shortenLabel(String text) {
      if (text.length <= 12) {
        return text;
      }

      return '${text.substring(0, 10)}...';
    }

    return SizedBox(
      width: double.infinity,
      height: 440,
      child: SfCartesianChart(
        enableAxisAnimation: false,

        margin: const EdgeInsets.fromLTRB(
          12,
          12,
          16,
          12,
        ),

        plotAreaBorderWidth: 0,

        // ───────────────── X AXIS ─────────────────
        primaryXAxis: CategoryAxis(
          labelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),

          labelIntersectAction:
              AxisLabelIntersectAction.multipleRows,

          maximumLabels: 1,

          axisLine: const AxisLine(width: 0),

          majorGridLines: const MajorGridLines(
            width: 0,
          ),

          majorTickLines: const MajorTickLines(
            width: 0,
          ),
        ),

        // ───────────────── LEFT AXIS ─────────────────
        primaryYAxis: const NumericAxis(
          name: 'JobsAxis',

          axisLine: AxisLine(width: 0),

          majorTickLines: MajorTickLines(
            width: 0,
          ),

          majorGridLines: MajorGridLines(
            width: 0.4,
            color: Color(0xFFE5E7EB),
          ),

          labelStyle: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),

        // ───────────────── RIGHT AXIS ─────────────────
        axes: const <ChartAxis>[
          NumericAxis(
            name: 'SalaryAxis',

            opposedPosition: true,

            axisLine: AxisLine(width: 0),

            majorTickLines: MajorTickLines(
              width: 0,
            ),

            majorGridLines: MajorGridLines(
              width: 0,
            ),

            labelStyle: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],

        // ───────────────── LEGEND ─────────────────
        legend: const Legend(
          isVisible: true,

          position: LegendPosition.bottom,

          overflowMode:
              LegendItemOverflowMode.wrap,

          textStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),

        // ───────────────── TOOLTIP ─────────────────
        tooltipBehavior: TooltipBehavior(
          enable: true,

          canShowMarker: true,

          header: '',

          format: 'point.x : point.y',
        ),

        // ───────────────── SERIES ─────────────────
        series:
            <CartesianSeries<Map<String, dynamic>,
                String>>[
          // ───────── JOBS ─────────
          BarSeries<Map<String, dynamic>, String>(
            name: 'Jobs',

            animationDuration: 0,

            spacing: 0.35,

            width: 0.9,

            borderRadius:
                const BorderRadius.horizontal(
              right: Radius.circular(8),
            ),

            dataSource: rawData,

            xValueMapper: (data, _) =>
                shortenLabel(
                  SafeParser.getString(data, 'x'),
                ),

            yValueMapper: (data, _) =>
                SafeParser.getDouble(
                  data,
                  'y_jobs_count',
                ),

            color: AppColors.primary,

            yAxisName: 'JobsAxis',
          ),

          // ───────── SALARY ─────────
          BarSeries<Map<String, dynamic>, String>(
            name: 'Salary (M)',

            animationDuration: 0,

            spacing: 0.35,

            width: 0.9,

            borderRadius:
                const BorderRadius.horizontal(
              right: Radius.circular(8),
            ),

            dataSource: rawData,

            xValueMapper: (data, _) =>
                shortenLabel(
                  SafeParser.getString(data, 'x'),
                ),

            yValueMapper: (data, _) {
              final val =
                  SafeParser.getDouble(
                data,
                'y_total_salary',
              );

              // Convert to Millions
              return val / 1000000;
            },

            color: AppColors.success,

            yAxisName: 'SalaryAxis',
          ),
        ],
      ),
    );
  } catch (e) {
    return const SafeErrorWidget(
      message: 'Grouped bar chart failed',
    );
  }
}
}
