import 'package:flutter/material.dart';
import 'package:insight_hub/constant/app_colors.dart';
import 'package:insight_hub/constant/routes.dart';
import 'package:insight_hub/widget/bottom_nav.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insight_hub/cuibt/cubit/match_cubit.dart';
import 'package:insight_hub/widget/app_header.dart';
import 'package:insight_hub/widget/app_motion.dart';

class SurveyMenuScreen extends StatelessWidget {
  const SurveyMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightGray,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppHeader(
              title: 'Services Hub',
              subtitle: 'Empowering your next professional breakthrough.',
            ),
            Expanded(
              child: AppMotion(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  children: [
                    _buildSurveyCard(
                      context,
                      title: 'Career Assessment',
                      subtitle:
                          'Match your personality with the ideal career path.',
                      icon: LucideIcons.briefcase,
                      isActive: true,
                      onTap: () async {
                        final cubit = context.read<MatchCubit>();

                        // Show a simple loading indicator (can be improved with a dialog)
                        // For now, we'll just await the fetch
                        final hasResult = await cubit.fetchResult();

                        if (!context.mounted) return;

                        if (hasResult) {
                          Navigator.pushNamed(context, Routes.matchScreen);
                        } else {
                          Navigator.pushNamed(context, Routes.questionScreen);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildSurveyCard(
                      context,
                      title: 'News ',
                      subtitle: 'Tech news tailored to your career interests.',
                      icon: LucideIcons.clipboardCheck,
                      isActive: true,
                      onTap: () {
                        Navigator.pushNamed(context, Routes.newsScreen);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildSurveyCard(
                      context,
                      title: 'Job  ',
                      subtitle: ' Discover job ',
                      icon: LucideIcons.home,
                      isActive: true,
                      onTap: () {
                        Navigator.pushNamed(context, Routes.jobScreen);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildSurveyCard(
                      context,
                      title: 'Interest Profiler',
                      subtitle: 'Explore industries that excite you most.',
                      icon: LucideIcons.heart,
                      isActive: false,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: const BottomNav(currentIndex: 2),
    );
  }

  Widget _buildSurveyCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return Opacity(
      opacity: isActive ? 1.0 : 0.5,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isActive ? onTap : null,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: AppColors.primaryBlue, size: 26),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textGray,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isActive ? LucideIcons.chevronRight : LucideIcons.lock,
                    color: const Color(0xFF9CA3AF),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
