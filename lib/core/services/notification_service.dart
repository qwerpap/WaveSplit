import 'package:flutter/material.dart';

import '../../constants/strings.dart';
import '../../constants/ui_constants.dart';
import '../shared/widgets/custom_dialog.dart';
import '../shared/widgets/custom_snackbar.dart';

/// Централизованный сервис для показа уведомлений
/// Заменяет все дефолтные ScaffoldMessenger.showSnackBar и showDialog
class NotificationService {
  NotificationService._();

  // SnackBar методы
  static void showSuccess(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onActionPressed,
    Duration duration = UIConstants.snackBarDefaultDuration,
  }) {
    CustomSnackBar.showSuccess(
      context,
      message: message,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      duration: duration,
    );
  }

  static void showError(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onActionPressed,
    Duration duration = UIConstants.snackBarErrorDuration,
  }) {
    CustomSnackBar.showError(
      context,
      message: message,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      duration: duration,
    );
  }

  static void showWarning(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onActionPressed,
    Duration duration = UIConstants.snackBarDefaultDuration,
  }) {
    CustomSnackBar.showWarning(
      context,
      message: message,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      duration: duration,
    );
  }

  static void showInfo(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onActionPressed,
    Duration duration = UIConstants.snackBarDefaultDuration,
  }) {
    CustomSnackBar.showInfo(
      context,
      message: message,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      duration: duration,
    );
  }

  // Dialog методы
  static Future<bool?> showConfirmation(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = AppStrings.confirmAction,
    String cancelText = AppStrings.cancelAction,
    bool isDangerous = false,
  }) {
    return CustomDialog.showConfirmation(
      context,
      title: title,
      content: content,
      confirmText: confirmText,
      cancelText: cancelText,
      isDangerous: isDangerous,
    );
  }

  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required String content,
    String buttonText = AppStrings.okAction,
  }) {
    return CustomDialog.showError(
      context,
      title: title,
      content: content,
      buttonText: buttonText,
    );
  }

  static Future<void> showSuccessDialog(
    BuildContext context, {
    required String title,
    required String content,
    String buttonText = AppStrings.okAction,
  }) {
    return CustomDialog.showSuccess(
      context,
      title: title,
      content: content,
      buttonText: buttonText,
    );
  }

  static Future<void> showInfoDialog(
    BuildContext context, {
    required String title,
    required String content,
    String buttonText = AppStrings.okAction,
  }) {
    return CustomDialog.showInfo(
      context,
      title: title,
      content: content,
      buttonText: buttonText,
    );
  }

  static Future<T?> showCustomDialog<T>(
    BuildContext context, {
    required String title,
    required String content,
    DialogType type = DialogType.info,
    String? primaryButtonText,
    String? secondaryButtonText,
    VoidCallback? onPrimaryPressed,
    VoidCallback? onSecondaryPressed,
    bool barrierDismissible = true,
    Widget? customContent,
  }) {
    return CustomDialog.show<T>(
      context,
      title: title,
      content: content,
      type: type,
      primaryButtonText: primaryButtonText,
      secondaryButtonText: secondaryButtonText,
      onPrimaryPressed: onPrimaryPressed,
      onSecondaryPressed: onSecondaryPressed,
      barrierDismissible: barrierDismissible,
      customContent: customContent,
    );
  }

  // Специальные методы для частых случаев
  static void showFilePickingError(
    BuildContext context, {
    required String message,
  }) {
    showError(
      context,
      message: message,
      actionLabel: AppStrings.retryAction,
    );
  }

  static void showNetworkError(
    BuildContext context, {
    required String message,
    VoidCallback? onDiagnose,
  }) {
    showError(
      context,
      message: message,
      actionLabel: onDiagnose != null ? AppStrings.diagnoseAction : null,
      onActionPressed: onDiagnose,
    );
  }

  static void showPlaybackMessage(
    BuildContext context, {
    required String trackName,
    required String modelName,
  }) {
    showInfo(
      context,
      message: AppStrings.playingTrack.replaceFirst('%s', trackName).replaceFirst('%s', modelName),
      duration: UIConstants.snackBarShortDuration,
    );
  }

  static void showHistoryCleared(BuildContext context) {
    showSuccess(
      context,
      message: AppStrings.historyCleared,
      duration: UIConstants.snackBarShortDuration,
    );
  }

  static void showTrackRemoved(
    BuildContext context, {
    required String trackName,
  }) {
    showSuccess(
      context,
      message: AppStrings.trackRemovedFromHistory.replaceFirst('%s', trackName),
      duration: UIConstants.snackBarShortDuration,
    );
  }

  static Future<bool?> showClearHistoryConfirmation(BuildContext context) {
    return showConfirmation(
      context,
      title: AppStrings.clearHistoryTitle,
      content: AppStrings.clearHistoryContent,
      confirmText: AppStrings.clearAction,
      cancelText: AppStrings.cancelAction,
      isDangerous: true,
    );
  }
}