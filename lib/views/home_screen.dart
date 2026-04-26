import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insight_hub/constant/app_colors.dart';
import 'package:insight_hub/model/dashboard_item.dart';
import 'package:insight_hub/widget/base_container.dart';
import 'package:insight_hub/widget/bottom_nav.dart';
import 'package:insight_hub/widget/widget_factory.dart';
import 'package:insight_hub/cuibt/cubit/dashboard_cubit.dart';
import 'package:insight_hub/widget/safe_error_widget.dart';
import 'package:insight_hub/widget/app_header.dart';
import 'package:insight_hub/widget/app_motion.dart';

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
              return Column(
                children: [
                  const AppHeader(
                    title: 'Home',
                    subtitle: 'Overview of your daily insights',
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SafeErrorWidget(
                        message: state.errorMessage,
                        onRetry: () =>
                            context.read<DashboardCubit>().fetchHomeDashboard(),
                      ),
                    ),
                  ),
                ],
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

              return Column(
                children: [
                  const AppHeader(
                    title: 'Home',
                    subtitle: 'Overview of your daily insights and metrics',
                  ),
                  Expanded(
                    child: AppMotion(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                        children: [
                          if (jobsItem != null)
                            JobsSummaryCard(item: jobsItem),
                          if (remainingItems.isEmpty && jobsItem == null)
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
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: BaseContainer(
                                  title: item.title,
                                  objective: item.objective,
                                  description: item.description,
                                  child: WidgetFactory.build(item.type, item.data),
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                  ),
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

class JobsSummaryCard extends StatelessWidget {
  final DashboardItem item;

  const JobsSummaryCard({super.key, required this.item});

  String _extractValue(DashboardItem item) {
    final d = item.data;
    if (d is Map<String, dynamic>) {
      return d['data']?.toString() ?? '0';
    }
    return d?.toString() ?? '0';
  }

  String _extractSuffix(DashboardItem item) {
    final d = item.data;
    if (d is Map<String, dynamic>) {
      return d['suffix']?.toString() ?? 'Jobs';
    }
    return 'Jobs';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.work_outline,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Posted Lately',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _extractValue(item),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  _extractSuffix(item),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGray,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}