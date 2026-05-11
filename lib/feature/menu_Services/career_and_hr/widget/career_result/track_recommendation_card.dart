import 'package:flutter/material.dart';
import 'package:InsightHub/feature/menu_Services/career_and_hr/model/career_quiz_result_model.dart';
import 'package:InsightHub/feature/menu_Services/career_and_hr/widget/career_result/sections/match_score_section.dart';
import 'package:InsightHub/feature/menu_Services/career_and_hr/widget/career_result/sections/market_insights_section.dart';
import 'package:InsightHub/feature/menu_Services/career_and_hr/widget/career_result/sections/skills_section.dart';
import 'package:InsightHub/feature/menu_Services/career_and_hr/widget/career_result/sections/track_header_section.dart';
import 'package:InsightHub/feature/menu_Services/career_and_hr/widget/career_result/widgets/section_card.dart';

/// Track Recommendation Card (per TrackMatch).
///
/// UI Hierarchy:
/// CareerResultScreen
///   ↓ TrackRecommendationCard
///     ↓ TrackHeaderSection
///     ↓ MatchScoreSection
///     ↓ SkillsSection
///     ↓ MarketInsightsSection
///
/// لماذا هذا التنظيم؟
/// - يعكس طبقات الـ JSON: track + marketInsights
/// - يسهل إضافة categories مستقبلًا بدون تعديل Card ضخمة
class TrackRecommendationCard extends StatelessWidget {
  final int rank;
  final TrackMatch trackMatch;

  const TrackRecommendationCard({
    super.key,
    required this.rank,
    required this.trackMatch,
  });

  @override
  Widget build(BuildContext context) {
    final track = trackMatch.track;

    return SectionCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TrackHeaderSection(rank: rank, trackMatch: trackMatch),
          const SizedBox(height: 12),
          Text(
            track.description,
            style: const TextStyle(
              color: Color(0xFF475569),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          MatchScoreSection(trackMatch: trackMatch),
          const SizedBox(height: 12),
          SkillsSection(track: track),
          const SizedBox(height: 12),
          MarketInsightsSection(insights: trackMatch.marketInsights),
        ],
      ),
    );
  }
}

