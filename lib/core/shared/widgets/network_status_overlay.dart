import 'package:flutter/material.dart';

import '../../../constants/strings.dart';
import '../../theme/app_fonts.dart';
import '../../services/network_monitor_service.dart';

class NetworkStatusOverlay extends StatefulWidget {
  final NetworkStatus status;
  final int consecutiveFailures;
  final DateTime? lastFailureTime;
  final VoidCallback onDismiss;
  final VoidCallback onRetry;
  final VoidCallback onDiagnose;

  const NetworkStatusOverlay({
    super.key,
    required this.status,
    required this.consecutiveFailures,
    this.lastFailureTime,
    required this.onDismiss,
    required this.onRetry,
    required this.onDiagnose,
  });

  @override
  State<NetworkStatusOverlay> createState() => _NetworkStatusOverlayState();
}

class _NetworkStatusOverlayState extends State<NetworkStatusOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
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

    if (widget.status == NetworkStatus.poor) {
      Future.delayed(const Duration(seconds: 10), () {
        if (mounted) {
          _dismiss();
        }
      });
    }
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
    switch (widget.status) {
      case NetworkStatus.disconnected:
        return const Color(0xFFEF4444);
      case NetworkStatus.poor:
        return const Color(0xFFF59E0B);
      case NetworkStatus.checking:
        return const Color(0xFF6B7280);
      case NetworkStatus.connected:
        return const Color(0xFF10B981);
    }
  }

  IconData get _icon {
    switch (widget.status) {
      case NetworkStatus.disconnected:
        return Icons.wifi_off_rounded;
      case NetworkStatus.poor:
        return Icons.signal_wifi_bad_rounded;
      case NetworkStatus.checking:
        return Icons.wifi_find_rounded;
      case NetworkStatus.connected:
        return Icons.wifi_rounded;
    }
  }

  String get _title {
    switch (widget.status) {
      case NetworkStatus.disconnected:
        return AppStrings.networkErrorTitle;
      case NetworkStatus.poor:
        return AppStrings.networkPoorTitle;
      case NetworkStatus.checking:
        return AppStrings.networkCheckingTitle;
      case NetworkStatus.connected:
        return AppStrings.networkConnectedTitle;
    }
  }

  String get _message {
    switch (widget.status) {
      case NetworkStatus.disconnected:
        return AppStrings.networkErrorMessage;
      case NetworkStatus.poor:
        return AppStrings.networkPoorMessage;
      case NetworkStatus.checking:
        return AppStrings.networkCheckingMessage;
      case NetworkStatus.connected:
        return AppStrings.networkConnectedMessage;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
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
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 8,
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  decoration: BoxDecoration(
                    color: _backgroundColor,
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
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _icon,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _title,
                                    style: AppFonts.titleLarge.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _message,
                                    style: AppFonts.bodySmall.copyWith(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: _dismiss,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        if (widget.status == NetworkStatus.disconnected) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _ActionButton(
                                  text: AppStrings.retryButton,
                                  onPressed: widget.onRetry,
                                  isPrimary: true,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _ActionButton(
                                  text: AppStrings.diagnoseButton,
                                  onPressed: widget.onDiagnose,
                                  isPrimary: false,
                                ),
                              ),
                            ],
                          ),
                        ],
                        
                        if (widget.consecutiveFailures > 1) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              AppStrings.failedTimes.replaceFirst('%d', '${widget.consecutiveFailures}'),
                              style: AppFonts.labelSmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
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

class _ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _ActionButton({
    required this.text,
    required this.onPressed,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isPrimary 
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isPrimary 
                ? null 
                : Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
          ),
          child: Center(
            child: Text(
              text,
              style: AppFonts.labelMedium.copyWith(
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