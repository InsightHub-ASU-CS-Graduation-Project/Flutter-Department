import 'package:flutter/material.dart';

class QuizCodeBlock extends StatelessWidget {
  final String code;
  final String? language;

  const QuizCodeBlock({super.key, required this.code, this.language});

  @override
  Widget build(BuildContext context) {
    final displayLanguage = language?.trim();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (displayLanguage != null && displayLanguage.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              color: const Color(0xFF111827),
              child: Text(
                displayLanguage,
                style: const TextStyle(
                  color: Color(0xFF93C5FD),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Text(
              code.trimRight(),
              softWrap: false,
              style: const TextStyle(
                color: Color(0xFFE5E7EB),
                fontFamily: 'monospace',
                fontSize: 14,
                height: 1.55,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
