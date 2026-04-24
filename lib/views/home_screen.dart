import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insight_hub/constant/app_colors.dart';
import 'package:insight_hub/model/dashboard_item.dart';
import 'package:insight_hub/widget/base_container.dart';
import 'package:insight_hub/widget/bottom_nav.dart';
import 'package:insight_hub/widget/widget_factory.dart';
import 'package:insight_hub/cuibt/cubit/dashboard_cubit.dart';
import 'package:insight_hub/widget/safe_error_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String routeName = '/homeScreen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Keywords that identify the "total jobs" metric
  static const _jobsKeywords = [
    'total jobs',
    'totaljobs',
    'total_jobs',
    'jobscount',
    'jobs_count',
    'jobs count',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DashboardCubit>().fetchHomeDashboard();
      }
    });
  }

  /// Check whether a DashboardItem represents the "total jobs" metric
  bool _isJobsMetric(DashboardItem item) {
    final titleLower = item.title.toLowerCase().trim();
    final idLower = item.id.toLowerCase().trim();

    for (final keyword in _jobsKeywords) {
      if (titleLower.contains(keyword) || idLower.contains(keyword)) {
        return true;
      }
    }
    return false;
  }

  /// Safely extract the display value from a DashboardItem's data
  String _extractValue(DashboardItem item) {
    final d = item.data;
    if (d is Map<String, dynamic>) {
      return d['data']?.toString() ?? '0';
    }
    return d?.toString() ?? '0';
  }

  /// Safely extract the suffix (e.g. "Jobs") from a DashboardItem's data
  String _extractSuffix(DashboardItem item) {
    final d = item.data;
    if (d is Map<String, dynamic>) {
      return d['suffix']?.toString() ?? 'Jobs';
    }
    return 'Jobs';
  }

  // ─── Header Card ───────────────────────────────────────────────

  Widget _buildHeaderCard({DashboardItem? jobsItem}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(bottom: 12.0, top: 8.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue,
            AppColors.primaryBlue.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Home',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.bgWhite,
            ),
          ),

          /// If we have a jobs metric → show it right under the title
          if (jobsItem != null) ...[
            const SizedBox(height: 4.0),
            Text(
              'Posted Lately',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.bgWhite.withOpacity(0.85),
              ),
            ),
            const SizedBox(height: 8.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _extractValue(jobsItem),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.bgWhite,
                  ),
                ),
                const SizedBox(width: 8.0),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Text(
                    _extractSuffix(jobsItem),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.bgWhite.withOpacity(0.85),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 8.0),
            Text(
              'Overview of your daily insights and metrics',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.bgWhite.withOpacity(0.9),
              ),
            ),
          ],

          const SizedBox(height: 24.0),

          /// Mini cards row
          Row(
            children: [
              Expanded(child: _buildMiniCard('Active', 'Tasks')),
              const SizedBox(width: 16.0),
              Expanded(child: _buildMiniCard('Matches', 'Found')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCard(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.bgWhite.withOpacity(0.15),
        border: Border.all(color: AppColors.bgWhite.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.bgWhite,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.bgWhite.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightGray,
      body: SafeArea(
        child: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading || state is DashboardInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DashboardFailure) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: SafeErrorWidget(
                  message: state.errorMessage,
                  onRetry: () =>
                      context.read<DashboardCubit>().fetchHomeDashboard(),
                ),
              );
            }

            if (state is DashboardSuccess) {
              // 1) Find the jobs metric (first match)
              DashboardItem? jobsItem;
              try {
                jobsItem = state.items.firstWhere(_isJobsMetric);
              } catch (_) {
                jobsItem = null;
              }

              // 2) Filter it out of the remaining cards
              final remainingItems = state.items
                  .where((item) => jobsItem == null || item.id != jobsItem.id)
                  .toList();

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                children: [
                  _buildHeaderCard(jobsItem: jobsItem),
                  if (remainingItems.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          'No analysis data available right now.',
                          style: TextStyle(color: AppColors.textGray),
                        ),
                      ),
                    )
                  else
                    ...remainingItems.map((item) {
                      return BaseContainer(
                        title: item.title,
                        objective: item.objective,
                        child: WidgetFactory.build(item.type, item.data),
                      );
                    }),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 0),
    );
  }
}