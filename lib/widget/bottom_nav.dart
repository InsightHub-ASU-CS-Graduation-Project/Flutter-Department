import 'package:flutter/material.dart';
import 'package:insight_hub/constant/app_colors.dart';
import 'package:insight_hub/constant/routes.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;

  const BottomNav({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, 0, Icons.home, 'Home'),
          _buildNavItem(context, 1, Icons.search, 'Search'),
          _buildNavItem(context, 2, Icons.interests, 'Survey'),
          _buildNavItem(context, 3, Icons.person, 'Profile'),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
  ) {
    final isActive = currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _handleTap(context, index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primaryBlue : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.primaryBlue : Colors.grey,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, int index) {
    if (index == currentIndex) {
      return;
    }

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, Routes.homeScreen);
        return;
      case 3:
        Navigator.pushReplacementNamed(context, Routes.profileScreen);
        return;
      case 2:
        Navigator.pushReplacementNamed(context, Routes.surveyMenuScreen);
        return;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This section is not available now.'),
          ),
        );
    }
  }
}
