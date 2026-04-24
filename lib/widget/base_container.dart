import 'package:flutter/material.dart';
import 'package:insight_hub/constant/app_colors.dart';
import 'package:insight_hub/widget/safe_error_widget.dart';

class BaseContainer extends StatelessWidget {
  final String title;
  final String? objective;
  final Widget? child;

  const BaseContainer({
    super.key,
    required this.title,
    this.objective,
    this.child,
  });

  Widget _safeChild() {
    try {
      if (child == null) return const SizedBox.shrink();
      return child!;
    } catch (e) {
      return const SafeErrorWidget(message: 'Failed to load content.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.borderLight, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600, // semi-bold
              color: AppColors.textDark,
              fontSize: 18,
            ),
          ),
          if (objective != null && objective!.isNotEmpty) ...[
            const SizedBox(height: 4.0),
            Text(
              objective!,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textGray,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 16.0),
          _safeChild(),
        ],
      ),
    );
  }
}
