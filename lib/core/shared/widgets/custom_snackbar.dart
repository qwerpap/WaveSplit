import 'package:flutter/material.dart';

import '../../../constants/ui_constants.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_fonts.dart';

enum SnackBarType {
  success,
  error,
  warning,
  info,
}

class CustomSnackBar {
  CustomSnackBar._();

  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    String? actionLabel,
    VoidCallback? onActionPressed,
    Duration duration = UIConstants.snackBarDefaultDuration,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _CustomSnackBarWidget(
        message: message,
        type: type,
        actionLabel: actionLabel,
        onActionPressed: onActionPressed,
        onDismiss: () => overlayEntry.remove(),
        duration: duration,
      ),
    );

    overlay.insert(overlayEntry);
  }

  static void showSuccess(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onActionPressed,
    Duration duration = UIConstants.snackBarDefaultDuration,
  }) {
    show(
      context,
      message: message,
      type: SnackBarType.success,
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
    show(
      context,
      message: message,
      type: SnackBarType.error,
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
    show(
      context,
      message: message,
      type: SnackBarType.warning,
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
    show(
      context,
      message: message,
      type: SnackBarType.info,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      duration: duration,
    );
  }
}

class _CustomSnackBarWidget extends StatefulWidget {
  final String message;
  final SnackBarType type;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final VoidCallback onDismiss;
  final Duration duration;

  const _CustomSnackBarWidget({
    required this.message,
    required this.type,
    this.actionLabel,
    this.onActionPressed,
    required this.onDismiss,
    required this.duration,
  });

  @override
  State<_CustomSnackBarWidget> createState() => _CustomSnackBarWidgetState();
}

class _CustomSnackBarWidgetState extends State<_CustomSnackBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: UIConstants.snackBarAnimationDuration,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
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

    // Auto dismiss
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _animationController.reverse();
    widget.onDismiss();
  }

  Color get _backgroundColor {
    switch (widget.type) {
      case SnackBarType.success:
        return const Color(0xFF10B981);
      case SnackBarType.error:
        return const Color(0xFFEF4444);
      case SnackBarType.warning:
        return const Color(0xFFF59E0B);
      case SnackBarType.info:
        return AppColors.primaryColor;
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case SnackBarType.success:
        return Icons.check_circle_rounded;
      case SnackBarType.error:
        return Icons.error_rounded;
      case SnackBarType.warning:
        return Icons.warning_rounded;
      case SnackBarType.info:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + UIConstants.snackBarTopOffset,
      left: UIConstants.snackBarHorizontalPadding,
      right: UIConstants.snackBarHorizontalPadding,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: _backgroundColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          _icon,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.message,
                          style: AppFonts.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (widget.actionLabel != null) ...[
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            widget.onActionPressed?.call();
                            _dismiss();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              widget.actionLabel!,
                              style: AppFonts.labelMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _dismiss,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}