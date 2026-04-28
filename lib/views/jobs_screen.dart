import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:insight_hub/constant/app_colors.dart';
import 'package:insight_hub/cuibt/cubit/jobs_cubit.dart';
import 'package:insight_hub/cuibt/cubit/jobs_state.dart';
import 'package:insight_hub/model/job_model.dart';
import 'package:insight_hub/widget/app_header.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  static const String routeName = '/jobScreen';

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<JobsCubit>().loadMore();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightGray,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              title: 'Jobs',
              subtitle: 'Find your next opportunity',
              showBackButton: true,
            ),

            _buildCategoryBar(),
            const SizedBox(height: 10),

            Expanded(
              child: BlocBuilder<JobsCubit, JobsState>(
                builder: (context, state) {
                  if (state is JobsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is JobsError) {
                    return Center(child: Text(state.message));
                  }

                  if (state is JobsLoaded) {
                    if (state.jobList.isEmpty) {
                      return const Center(child: Text('No jobs available'));
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: state.jobList.length +
                          (state.hasMorePages ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= state.jobList.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                                child: CircularProgressIndicator()),
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

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  if (selected.isNotEmpty)
                    TextButton(
                      onPressed: () => cubit.setCategories([]),
                      child: const Text('Clear All'),
                    ),
                ],
              ),
            ),

            SizedBox(
              height: 50,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: JobsCubit.categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final category = JobsCubit.categories[index];
                  final isSelected = selected.contains(category);

                  return GestureDetector(
                    onTap: () {
                      final updated = List<String>.from(selected);

                      if (isSelected) {
                        updated.remove(category);
                      } else {
                        updated.add(category);
                      }

                      cubit.setCategories(updated);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryBlue
                            : Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryBlue
                              : Colors.grey.shade300,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          Text(
                            category,
                            style: TextStyle(
                              fontSize: 13,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.check,
                                size: 14, color: Colors.white),
                          ]
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // ================= CARD =================

  Widget _buildCard(JobModel job) {
    final salary = _extractSalary(job.description);
    final jobType = _extractJobType(job.description);

    return GestureDetector(
      onTap: () {
        if (job.redirectUrl != null && job.redirectUrl!.isNotEmpty) {
          _openUrl(job.redirectUrl!);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🔥 HEADER (LOGO + TITLE)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🏢 LOGO
                Container(
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      job.companyName.isNotEmpty
                          ? job.companyName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job.companyName,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 📍 LOCATION
            if (job.location.isNotEmpty)
              Row(
                children: [
                  const Icon(LucideIcons.mapPin,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      job.location,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 10),

            // 🏷 BADGES
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (salary != null)
                  _buildBadge(salary, Colors.green),

                if (jobType != null)
                  _buildBadge(jobType, Colors.blue),
              ],
            ),

            const SizedBox(height: 10),

            // 📝 DESCRIPTION
            if (job.description != null)
              Text(
                job.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),

            const SizedBox(height: 10),

            // ⏱ DATE
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(LucideIcons.clock,
                    size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  _formatDate(job.createdDate),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================= BADGE =================

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  // ================= HELPERS =================

  String _formatDate(DateTime? date) {
    if (date == null) return '';

    final diff = DateTime.now().difference(date);

    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';

    return '${diff.inDays}d';
  }

  String? _extractSalary(String? description) {
    if (description == null) return null;

    final regex = RegExp(r'£[\d,]+\s?-\s?[\d,]+');
    return regex.firstMatch(description)?.group(0);
  }

  String? _extractJobType(String? description) {
    if (description == null) return null;

    final text = description.toLowerCase();

    if (text.contains('remote')) return 'Remote';
    if (text.contains('hybrid')) return 'Hybrid';
    if (text.contains('full-time')) return 'Full-time';
    if (text.contains('part-time')) return 'Part-time';

    return null;
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
  }
}