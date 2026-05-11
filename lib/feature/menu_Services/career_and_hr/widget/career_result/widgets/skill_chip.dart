import 'package:flutter/material.dart';
import 'package:InsightHub/core/constant/app_colors.dart';

/// Chip لعرض مهارة واحدة.
///
/// لماذا Chip؟
/// - الـ backend يرجع `requiredSkills` كسلسلة نصية
/// - UX الأفضل: تحويلها إلى Tags/Chips بحيث المستخدم "يشوفها كوحدات"
class SkillChip extends StatelessWidget {
  final String label;

  const SkillChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

