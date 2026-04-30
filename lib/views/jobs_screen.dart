import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:insight_hub/core/constant/app_colors.dart';
import 'package:insight_hub/cuibt/cubit/jobs_cubit.dart';
import 'package:insight_hub/cuibt/cubit/jobs_state.dart';
import 'package:insight_hub/model/job_model.dart';
import 'package:insight_hub/widget/app_header.dart';
import 'package:url_launcher/url_launcher.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});
  static const String routeName = '/jobScreen';

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();

    /// Pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (!isLoadingMore) {
          isLoadingMore = true;
          context.read<JobsCubit>().loadMore().then((_) {
            isLoadingMore = false;
          });
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobsCubit>().loadJobs(reset: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              title: 'Jobs',
              subtitle: 'Updated Daily',
              showBackButton: true,
            ),
const SizedBox(height: 12), // 👈 ده المهمconst SizedBox(height: 12), // 👈 ده المهم
            _buildCategoryBar(),
            const SizedBox(height: 10),

            Expanded(
              child: BlocBuilder<JobsCubit, JobsState>(
                builder: (context, state) {
                  if (state is JobsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is JobsError) {
                    return _errorView(state.message);
                  }

                  if (state is JobsLoaded) {
                    if (state.jobList.isEmpty) {
                      return _emptyView();
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount:
                          state.jobList.length + (state.hasMorePages ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= state.jobList.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        return _buildCard(state.jobList[index]);
                      },
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= CATEGORY =================

Widget _buildCategoryBar() {
  return BlocBuilder<JobsCubit, JobsState>(
    builder: (context, state) {
      final cubit = context.read<JobsCubit>();
      final selected = cubit.selectedCategories;

      final width = MediaQuery.of(context).size.width;
      final isTablet = width > 600;

      final height = isTablet ? 42.0 : 36.0;
      final fontSize = isTablet ? 13.0 : 11.0;
      final iconSize = isTablet ? 14.0 : 12.0;
      final padding = isTablet ? 12.0 : 10.0;

      return SizedBox(
        height: height,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: JobsCubit.categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (context, index) {
            final category = JobsCubit.categories[index];
            final isSelected = selected.contains(category);

            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  final updated = List<String>.from(selected);

                  /// toggle
                  if (isSelected) {
                    updated.remove(category);
                  } else {
                    updated.add(category);
                  }

                  cubit.setCategories(updated);
                  cubit.loadJobs(reset: true);
                },
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 120),
                  scale: isSelected ? 1.05 : 1.0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.25),
                                blurRadius: 6,
                              )
                            ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getCategoryIcon(category),
                          size: iconSize,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          category,
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}
  // ================= CARD (LinkedIn Style) =================

  Widget _buildCard(JobModel job) {
    final description = job.description ?? '';
    final salary = _extractSalary(description);
    final jobType = _extractJobType(description);

    return GestureDetector(
      onTap: () => _openUrl(job.redirectUrl),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// HEADER
            Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      job.companyName.isNotEmpty
                          ? job.companyName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        job.companyName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// LOCATION
            if (job.location.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.location_on,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      job.location,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 8),

            /// BADGES
            Row(
              children: [
                if (salary != null) _badge(salary, Colors.green),
                if (jobType != null) ...[
                  const SizedBox(width: 6),
                  _badge(jobType, AppColors.primary),
                ]
              ],
            ),

            const SizedBox(height: 8),

            /// DESCRIPTION
            if (description.isNotEmpty)
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  // ================= STATES =================

  Widget _emptyView() {
    return const Center(child: Text('No jobs available'));
  }

  Widget _errorView(String message) {
    return Center(child: Text(message));
  }

  // ================= HELPERS =================

  String? _extractSalary(String text) {
    final regex = RegExp(r'[\$£€]\s?[\d,]+');
    return regex.firstMatch(text)?.group(0);
  }

  String? _extractJobType(String text) {
    text = text.toLowerCase();

    if (text.contains('remote')) return 'Remote';
    if (text.contains('hybrid')) return 'Hybrid';
    if (text.contains('full-time')) return 'Full-time';
    if (text.contains('part-time')) return 'Part-time';

    return null;
  }

  Future<void> _openUrl(String? url) async {
    if (url == null || url.isEmpty) return;

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    }
  }
}IconData _getCategoryIcon(String category) {
  final value = category.toLowerCase();

  if (value.contains('back')) return Icons.storage;
  if (value.contains('front')) return Icons.web;
  if (value.contains('full')) return Icons.layers;
  if (value.contains('mobile')) return Icons.phone_android;
  if (value.contains('data')) return Icons.bar_chart;

  return Icons.work;
}