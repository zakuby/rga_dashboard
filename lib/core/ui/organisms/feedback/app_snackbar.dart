import 'package:flutter/material.dart';

import '../../../../result/result.dart';
import '../../theme/app_colors.dart';

/// App snackbar helper for showing consistent notifications.
class AppSnackbar {
  /// Shows an error snackbar with appropriate icon based on failure type.
  static void showError(
    BuildContext context, {
    required String message,
    FailureType? failureType,
    Duration duration = const Duration(seconds: 4),
  }) {
    final theme = Theme.of(context);
    final icon = _getIconForFailureType(failureType);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: theme.colorScheme.onError),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: theme.colorScheme.error,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Shows a success snackbar.
  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    final theme = Theme.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: theme.colorScheme.onPrimary),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Shows an info snackbar.
  static void showInfo(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    final theme = Theme.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info, color: theme.colorScheme.onPrimaryContainer),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: theme.colorScheme.primaryContainer,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static IconData _getIconForFailureType(FailureType? type) {
    return switch (type) {
      FailureType.authentication => Icons.lock_outline,
      FailureType.timeout => Icons.timer_off_outlined,
      FailureType.network => Icons.wifi_off,
      FailureType.server => Icons.cloud_off,
      FailureType.validation => Icons.warning_amber,
      _ => Icons.error_outline,
    };
  }
}
