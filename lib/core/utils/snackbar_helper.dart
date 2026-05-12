import 'package:flutter/material.dart';
import 'package:InsightHub/core/constant/app_colors.dart';

class SnackbarHelper {
  static void showError(BuildContext context, String message) {
    _show(context, message, AppColors.error);
  }

  static void showSuccess(BuildContext context, String message) {
    _show(context, message, AppColors.success);
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message, AppColors.primary);
  }

  static void _show(BuildContext context, String message, Color backgroundColor) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
