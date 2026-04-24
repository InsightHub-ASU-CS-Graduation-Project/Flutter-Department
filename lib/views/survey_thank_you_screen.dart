import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insight_hub/constant/app_colors.dart';
import 'package:insight_hub/constant/routes.dart';
import 'package:insight_hub/cuibt/cubit/match_cubit.dart';
import 'package:insight_hub/cuibt/cubit/question_cubit.dart';
import 'package:insight_hub/widget/bottom_nav.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SurveyThankYouScreen extends StatelessWidget {
  const SurveyThankYouScreen({super.key});

  static const String routeName = '/surveyThankYouScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryBlue,
                    Color(0xFF1D4ED8),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Survey Complete',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Thank you for sharing your insights.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryBlue.withOpacity(0.15),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          LucideIcons.checkCircle,
                          color: AppColors.primaryBlue,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Title
                      const Text(
                        'Thank You!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Message
                      const Text(
                        'Your survey responses have been recorded successfully. Since you are employed, your answers will help us improve our career matching for others.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF475569),
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Retake button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.read<MatchCubit>().reset();
                            context.read<QuestionCubit>().reset();
                            Navigator.pushReplacementNamed(
                              context,
                              Routes.questionScreen,
                            );
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Take Survey Again'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Back to home
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pushReplacementNamed(
                            context,
                            Routes.homeScreen,
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Go to Home',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 2),
    );
  }
}
