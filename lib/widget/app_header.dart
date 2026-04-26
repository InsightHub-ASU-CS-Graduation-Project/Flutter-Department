import 'package:flutter/material.dart';
import 'package:insight_hub/constant/app_colors.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? extra;
  final Widget? leading;
  final IconData? leadingIcon;
  final bool showBackButton;
  final VoidCallback? onBackPress;

  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.extra,
    this.leading,
    this.leadingIcon,
    this.showBackButton = false,
    this.onBackPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
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
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 12),
              ] else if (showBackButton) ...[
                IconButton(
                  icon: Icon(leadingIcon ?? Icons.arrow_back, color: Colors.white),
                  onPressed: onBackPress ?? () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ],
          if (extra != null) ...[
            const SizedBox(height: 20),
            extra!,
          ],
        ],
      ),
    );
  }
}
