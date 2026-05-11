import 'package:flutter/material.dart';
import 'package:InsightHub/core/constant/app_colors.dart';

/// Widget صغير لعرض Metric واحدة مع شرح "Beginner-friendly".
///
/// - **label**: اسم الـ metric
/// - **value**: قيمتها (مثلاً 3.6)
/// - **description**: معنى metric للمستخدم
/// - **scaleMax**: لو كانت metric على مقياس 1..5 (default) نعرض progress bar بسيط
class MetricTile extends StatelessWidget {
  final String label;
  final double value;
  final String description;
  final double scaleMax;

  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    required this.description,
    this.scaleMax = 5,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (scaleMax <= 0) ? 0.0 : (value / scaleMax).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              Text(
                value.toStringAsFixed(1),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              height: 1.35,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(999),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

