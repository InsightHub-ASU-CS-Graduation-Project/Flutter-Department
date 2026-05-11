import 'package:flutter/material.dart';
import 'package:InsightHub/core/constant/app_colors.dart';
import 'package:InsightHub/feature/menu_Services/career_and_hr/model/career_quiz_result_model.dart';

/// Track Header Section
/// - يعرض اسم المسار + الترتيب + نسبة percentage (secondary).
///
/// لماذا هذا section مستقل؟
/// - لأن header سيتكرر داخل كل track card
/// - ويسهل تغييره/تطويره بدون لمس باقي أقسام الـ UI
class TrackHeaderSection extends StatelessWidget {
  final int rank;
  final TrackMatch trackMatch;

  const TrackHeaderSection({
    super.key,
    required this.rank,
    required this.trackMatch,
  });

  @override
  Widget build(BuildContext context) {
    final track = trackMatch.track;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '#$rank',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              track.trackName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          Text(
            '${track.percentage.round()}%',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}

