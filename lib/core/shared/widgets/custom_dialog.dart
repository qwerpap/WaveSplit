import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_fonts.dart';

enum DialogType {
  info,
  warning,
  error,
  success,
  confirmation,
}

class CustomDialog {
  CustomDialog._();

  static Future<T?> show<T>(
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
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => _CustomDialogWidget(
        title: title,
        content: content,
        type: type,
        primaryButtonText: primaryButtonText,
        secondaryButtonText: secondaryButtonText,
        onPrimaryPressed: onPrimaryPressed,
        onSecondaryPressed: onSecondaryPressed,
        customContent: customContent,
      ),
    );
  }

  static Future<bool?> showConfirmation(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDangerous = false,
  }) {
    return show<bool>(
      context,
      title: title,
      content: content,
      type: isDangerous ? DialogType.warning : DialogType.confirmation,
      primaryButtonText: confirmText,
      secondaryButtonText: cancelText,
      onPrimaryPressed: () => Navigator.of(context).pop(true),
      onSecondaryPressed: () => Navigator.of(context).pop(false),
    );
  }

  static Future<void> showError(
    BuildContext context, {
    required String title,
    required String content,
    String buttonText = 'OK',
  }) {
    return show(
      context,
      title: title,
      content: content,
      type: DialogType.error,
      primaryButtonText: buttonText,
      onPrimaryPressed: () => Navigator.of(context).pop(),
    );
  }

  static Future<void> showSuccess(
    BuildContext context, {
    required String title,
    required String content,
    String buttonText = 'OK',
  }) {
    return show(
      context,
      title: title,
      content: content,
      type: DialogType.success,
      primaryButtonText: buttonText,
      onPrimaryPressed: () => Navigator.of(context).pop(),
    );
  }

  static Future<void> showInfo(
    BuildContext context, {
    required String title,
    required String content,
    String buttonText = 'OK',
  }) {
    return show(
      context,
      title: title,
      content: content,
      type: DialogType.info,
      primaryButtonText: buttonText,
      onPrimaryPressed: () => Navigator.of(context).pop(),
    );
  }
}

class _CustomDialogWidget extends StatefulWidget {
  final String title;
  final String content;
  final DialogType type;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;
  final Widget? customContent;

  const _CustomDialogWidget({
    required this.title,
    required this.content,
    required this.type,
    this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
    this.customContent,
  });

  @override
  State<_CustomDialogWidget> createState() => _CustomDialogWidgetState();
}

class _CustomDialogWidgetState extends State<_CustomDialogWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color get _accentColor {
    switch (widget.type) {
      case DialogType.success:
        return const Color(0xFF10B981);
      case DialogType.error:
        return const Color(0xFFEF4444);
      case DialogType.warning:
        return const Color(0xFFF59E0B);
      case DialogType.info:
      case DialogType.confirmation:
        return AppColors.primaryColor;
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case DialogType.success:
        return Icons.check_circle_rounded;
      case DialogType.error:
        return Icons.error_rounded;
      case DialogType.warning:
        return Icons.warning_rounded;
      case DialogType.info:
        return Icons.info_rounded;
      case DialogType.confirmation:
        return Icons.help_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: _accentColor.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with icon
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: _accentColor.withOpacity(0.05),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _icon,
                              color: _accentColor,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.title,
                            style: AppFonts.headlineLarge.copyWith(
                              color: AppColors.blackColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          if (widget.customContent != null)
                            widget.customContent!
                          else
                            Text(
                              widget.content,
                              style: AppFonts.bodyMedium.copyWith(
                                color: AppColors.greyColor,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          const SizedBox(height: 24),

                          // Buttons
                          Row(
                            children: [
                              if (widget.secondaryButtonText != null) ...[
                                Expanded(
                                  child: _SecondaryButton(
                                    text: widget.secondaryButtonText!,
                                    onPressed: widget.onSecondaryPressed ??
                                        () => Navigator.of(context).pop(),
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                              if (widget.primaryButtonText != null)
                                Expanded(
                                  child: _PrimaryButton(
                                    text: widget.primaryButtonText!,
                                    color: _accentColor,
                                    onPressed: widget.onPrimaryPressed ??
                                        () => Navigator.of(context).pop(),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.text,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              text,
              style: AppFonts.labelLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _SecondaryButton({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.lightGreyColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.lightGreyColor,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: AppFonts.labelLarge.copyWith(
                color: AppColors.greyColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}