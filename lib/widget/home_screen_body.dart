import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insight_hub/core/constant/app_colors.dart';
import 'package:insight_hub/cuibt/cubit/dashboard_cubit.dart';
import 'package:insight_hub/model/dashboard_item.dart';
import 'package:insight_hub/views/jobs_summary_card.dart';
import 'package:insight_hub/widget/app_header.dart';
import 'package:insight_hub/widget/app_motion.dart';
import 'package:insight_hub/widget/base_container.dart';
import 'package:insight_hub/widget/safe_error_widget.dart';
import 'package:insight_hub/widget/widget_factory.dart';

class HomeScreenBody extends StatefulWidget {
  const HomeScreenBody({super.key});

  @override
  State<HomeScreenBody> createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<HomeScreenBody> {
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
  @override
  Widget build(BuildContext context) {
    return  SafeArea(
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
      );
  }
}