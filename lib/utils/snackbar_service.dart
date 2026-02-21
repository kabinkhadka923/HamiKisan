import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'constants.dart';

class SnackbarService {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showSnackbar({
    required String message,
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: textColor ?? Colors.white),
        ),
        backgroundColor: backgroundColor ?? AppColors.primary,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
        ),
      ),
    );
  }

  static void showSuccess(String message) {
    showSnackbar(
      message: message,
      backgroundColor: AppColors.success,
    );
  }

  static void showError(String message) {
    showSnackbar(
      message: message,
      backgroundColor: AppColors.error,
    );
  }

  static void showWarning(String message) {
    showSnackbar(
      message: message,
      backgroundColor: AppColors.warning,
      textColor: AppColors.onWarning,
    );
  }

  static void hideCurrentSnackbar() {
    scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
  }
}
