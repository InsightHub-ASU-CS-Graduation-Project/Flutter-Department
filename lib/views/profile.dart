import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:insight_hub/constant/app_colors.dart';
import 'package:insight_hub/constant/routes.dart';
import 'package:insight_hub/cuibt/cubit/logout_cubit.dart';
import 'package:insight_hub/cuibt/cubit/profile_cubit.dart';
import 'package:insight_hub/model/profile_model.dart';
import 'package:insight_hub/widget/bottom_nav.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const String routeName = '/profileScreen';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProfileCubit>().fetchProfile();
    });
  }

  String _initialFrom(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed[0].toUpperCase();
  }

  String _fullName(ProfileModel profile) {
    final name = '${profile.firstName} ${profile.lastName}'.trim();
    return name.isEmpty ? 'Guest User' : name;
  }

  String _email(ProfileModel profile) {
    return profile.email.trim().isEmpty ? 'No email available' : profile.email;
  }

  List<Map<String, String>> _profileItems(ProfileModel profile) {
    final jobs = profile.jobs
        .where((job) => job.jobName.trim().isNotEmpty)
        .map((job) {
          final years = job.yearsExperience;
          if (years == null) return job.jobName;
          final suffix = years == 1 ? 'year' : 'years';
          return '${job.jobName} ($years $suffix)';
        })
        .join(', ');

    return [
      {
        'label': 'Username',
        'value': profile.userName.trim().isEmpty ? 'Not set' : profile.userName,
      },
      {
        'label': 'College',
        'value': profile.collage.trim().isEmpty ? 'Not set' : profile.collage,
      },
      {
        'label': 'Graduation Status',
        'value': profile.isGraduated ? 'Graduated' : 'Currently Enrolled',
      },
      {
        'label': 'Jobs',
        'value': jobs.isEmpty ? 'Not set' : jobs,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final logoutCubit = context.read<LogoutCubit>();

    final settingsItems = [
      {
        'icon': LucideIcons.refreshCw,
        'label': 'Refresh Profile',
        'action': () => context.read<ProfileCubit>().fetchProfile(),
        'isDestructive': false,
      },
      {
        'icon': LucideIcons.logOut,
        'label': 'Log Out',
        'action': () => logoutCubit.logout(),
        'isDestructive': true,
      },
    ];

    return MultiBlocListener(
      listeners: [
        BlocListener<LogoutCubit, LogoutState>(
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
        ),
        BlocListener<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is ProfileFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: SafeArea(
          child: Column(
            children: [
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
                        color: Color(0xFFBFDBFE),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (context, state) {
                    if (state is ProfileLoading || state is ProfileInitial) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is! ProfileSuccess) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Unable to load profile right now.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  context.read<ProfileCubit>().fetchProfile();
                                },
                                child: const Text('Try Again'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final profile = state.profile;
                    final fullName = _fullName(profile);
                    final email = _email(profile);
                    final avatarInitials =
                        '${_initialFrom(profile.firstName)}${_initialFrom(profile.lastName)}';
                    final profileItems = _profileItems(profile);

                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryBlue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      avatarInitials,
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
                                  fullName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  email,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Personal Information',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ...profileItems.map(
                                  (item) => _buildInfoRow(
                                    icon: _iconForLabel(item['label']!),
                                    label: item['label']!,
                                    value: item['value']!,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: Column(
                              children: settingsItems.map((item) {
                                final index = settingsItems.indexOf(item);
                                final icon = item['icon'] as IconData;
                                final label = item['label'] as String;
                                final action = item['action'] as VoidCallback;
                                final isDestructive =
                                    item['isDestructive'] as bool;

                                return InkWell(
                                  onTap: action,
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      border: index != settingsItems.length - 1
                                          ? const Border(
                                              bottom: BorderSide(
                                                color: Color(0xFFF3F4F6),
                                              ),
                                            )
                                          : null,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          icon,
                                          size: 20,
                                          color: isDestructive
                                              ? Colors.red
                                              : const Color(0xFF111827),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            label,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: isDestructive
                                                  ? Colors.red
                                                  : const Color(0xFF111827),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        const Icon(
                                          LucideIcons.chevronRight,
                                          size: 20,
                                          color: Color(0xFF9CA3AF),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Column(
                              children: [
                                Text(
                                  'InsightHub v1.0.0',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Copyright 2026 InsightHub. All rights reserved.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const BottomNav(),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForLabel(String label) {
    switch (label) {
      case 'Username':
        return LucideIcons.atSign;
      case 'College':
        return LucideIcons.graduationCap;
      case 'Graduation Status':
        return LucideIcons.award;
      case 'Jobs':
        return LucideIcons.briefcase;
      default:
        return LucideIcons.user;
    }
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: const Color(0xFF6B7280),
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
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
