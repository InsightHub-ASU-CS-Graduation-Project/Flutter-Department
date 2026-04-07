import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:insight_hub/constant/app_colors.dart';
import 'package:insight_hub/constant/routes.dart';
import 'package:insight_hub/cuibt/cubit/logout_cubit.dart';
import 'package:insight_hub/cuibt/cubit/register_cubit.dart';
import 'package:insight_hub/widget/bottom_nav.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const String routeName = '/profileScreen';

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RegisterCubit>();
    final logoutCubit = context.read<LogoutCubit>();

    final profileSections = [
      {
        'title': 'Personal Information',
        'items': [
          {
            'icon': LucideIcons.user,
            'label': 'Full Name',
            'value': '${cubit.firstName ?? ''} ${cubit.lastName ?? ''}'.trim(),
          },
          {
            'icon': LucideIcons.mail,
            'label': 'Email',
            'value': cubit.email ?? 'Not set',
          },
          {
            'icon': LucideIcons.calendar,
            'label': 'Birthdate',
            'value': cubit.birthDate != null
                ? DateFormat('MMMM d, yyyy').format(cubit.birthDate!)
                : 'Not set',
          },
          {
            'icon': LucideIcons.graduationCap,
            'label': 'College',
            'value': cubit.collage ?? 'Not set',
          },
          {
            'icon': LucideIcons.award,
            'label': 'Graduation Status',
            'value': cubit.isGraduated == true ? 'Graduated' : 'Currently Enrolled',
          },
        ],
      },
    ];

    final settingsItems = [
      {'icon': LucideIcons.settings, 'label': 'Account Settings', 'action': () {}, 'isDestructive': false},
      {
        'icon': LucideIcons.logOut,
        'label': 'Log Out',
        'action': () => logoutCubit.logout(),
        'isDestructive': true,
      },
    ];

    return BlocListener<LogoutCubit, LogoutState>(
      listener: (context, state) {
        if (state is LogoutSuccess) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.signInScreen,
            (route) => false,
          );
        } else if (state is LogoutFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage)),
          );
        }
      },
      child: Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // gray-50
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Manage your account information',
                    style: TextStyle(
                      color: Color(0xFFBFDBFE), // blue-100
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  children: [
                    // Profile Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      margin: const EdgeInsets.only(top: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)), // gray-200
                      ),
                      child: Column(
                        children: [
                          // Avatar
                          Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${(cubit.firstName ?? '')[0]}${(cubit.lastName ?? '')[0]}'.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${cubit.firstName ?? ''} ${cubit.lastName ?? ''}'.trim(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827), // gray-900
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cubit.email ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280), // gray-600
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Personal Information Sections
                    ...profileSections.map((section) {
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE5E7EB)), // gray-200
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              section['title'] as String,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827), // gray-900
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...((section['items'] as List).map((item) {
                              final icon = item['icon'] as IconData;
                              final label = item['label'] as String;
                              final value = item['value'] as String;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3F4F6), // gray-100
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        icon,
                                        size: 20,
                                        color: const Color(0xFF6B7280), // gray-600
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            label,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF6B7280), // gray-500
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            value,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFF111827), // gray-900
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList()),
                          ],
                        ),
                      );
                    }).toList(),

                    // Settings
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)), // gray-200
                      ),
                      child: Column(
                        children: settingsItems.map((item) {
                          final index = settingsItems.indexOf(item);
                          final icon = item['icon'] as IconData;
                          final label = item['label'] as String;
                          final action = item['action'] as Function;
                          final isDestructive = item['isDestructive'] as bool;

                          return InkWell(
                            onTap: () => action(),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                border: index != settingsItems.length - 1
                                    ? const Border(
                                        bottom: BorderSide(color: Color(0xFFF3F4F6)), // gray-100
                                      )
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    icon,
                                    size: 20,
                                    color: isDestructive ? Colors.red : const Color(0xFF111827), // gray-900
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: isDestructive ? Colors.red : const Color(0xFF111827), // gray-900
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    LucideIcons.chevronRight,
                                    size: 20,
                                    color: const Color(0xFF9CA3AF), // gray-400
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    // App Info
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        children: [
                          Text(
                            'InsightHub v1.0.0',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280), // gray-500
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '© 2026 InsightHub. All rights reserved.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9CA3AF), // gray-400
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Navigation
            const BottomNav(),
          ],
        ),
      ),
    ),
    );
  }
}
