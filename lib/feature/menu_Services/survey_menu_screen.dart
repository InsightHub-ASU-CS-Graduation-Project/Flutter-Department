import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insight_hub/core/constant/app_colors.dart';
import 'package:insight_hub/core/constant/routes.dart';
import 'package:insight_hub/core/services/api_service.dart';
import 'package:insight_hub/feature/menu_Services/career_and_hr/cubit/navigation_career.dart';
import 'package:insight_hub/feature/menu_Services/widget/card_services.dart';
import 'package:insight_hub/widget/app_header.dart';
import 'package:insight_hub/widget/app_motion.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SurveyMenuScreen extends StatelessWidget {
  const SurveyMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NavigationCubit>(
      create: (_) => NavigationCubit(ApiService()),
      child: BlocListener<NavigationCubit, NavigationState>(
        listener: (context, state) {
          if (state is NavigationSuccess) {
            if (!context.mounted) return;

            switch (state.target) {
              case NavigationTarget.questions:
                print('SurveyMenuScreen: Navigating to questionScreen with isEmployed=${state.isEmployed}');
                Navigator.pushNamed(
                  context,
                  Routes.questionScreen,
                  arguments: state.isEmployed,
                );
                break;
              case NavigationTarget.result:
                Navigator.pushNamed(context, Routes.matchScreen);
                break;
              case NavigationTarget.thankYou:
                Navigator.pushNamed(context, Routes.surveyThankYouScreen);
                break;
            }
          }

          if (state is NavigationError) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.bgLightGray,
          body: Container(
            decoration: BoxDecoration(gradient: AppColors.bgGradient),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppHeader(
                    title: 'Services Hub',
                    subtitle: 'Empowering your next professional breakthrough.',
                  ),
                  Expanded(
                    child: AppMotion(
                      child: Builder(
                        builder: (innerContext) => ListView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 24,
                          ),
                          children: [
                          BlocBuilder<NavigationCubit, NavigationState>(
                            builder: (context, navState) {
                              final isLoading = navState is NavigationLoading;
                              return buildSurveyCard(
                                innerContext,
                                title: 'Career Assessment',
                                subtitle:
                                    'Match your personality with the ideal career path.',
                                icon: LucideIcons.briefcase,
                                isActive: true,
                                isLoading: isLoading,
                                onTap: isLoading
                                    ? null
                                    : () {
                                        innerContext
                                            .read<NavigationCubit>()
                                            .decide();
                                      },
                              );
                            },
                          ),
                            const SizedBox(height: 16),
                            buildSurveyCard(
                              innerContext,
                              title: 'News ',
                              subtitle:
                                  'Tech news tailored to your career interests.',
                              icon: LucideIcons.clipboardCheck,
                              isActive: true,
                              onTap: () {
                                Navigator.pushNamed(innerContext, Routes.newsScreen);
                              },
                            ),
                            const SizedBox(height: 16),
                            buildSurveyCard(
                              innerContext,
                              title: 'Job  ',
                              subtitle: ' Discover job ',
                              icon: LucideIcons.home,
                              isActive: true,
                              onTap: () {
                                Navigator.pushNamed(innerContext, Routes.jobScreen);
                              },
                            ),
                            const SizedBox(height: 16),
                            buildSurveyCard(
                              innerContext,
                              title: 'HR Services ',
                              subtitle:
                                  'Explore industries that excite you most.',
                              icon: LucideIcons.users,
                              isActive: true,
                              onTap: () {
                                Navigator.pushNamed(
                                  innerContext,
                                  Routes.menuHrCategoriesScreen,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
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
