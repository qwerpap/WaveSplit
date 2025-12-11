import 'package:flutter/material.dart';
import 'package:wave_split/core/theme/app_colors.dart';

class SelectionAnimated extends StatelessWidget {
  final bool isActive;
  final Widget child;
  final double borderRadius;
  final Duration duration;
  final Curve curve;
  final Color? activeBackground;
  final Color? inactiveBackground;
  final Color? activeBorderColor;
  final Color? inactiveBorderColor;
  final double activeBorderWidth;
  final double inactiveBorderWidth;
  final List<BoxShadow>? activeShadow;
  final List<BoxShadow>? inactiveShadow;
  final double activeScale;

  const SelectionAnimated({
    super.key,
    required this.isActive,
    required this.child,
    this.borderRadius = 12,
    this.duration = const Duration(milliseconds: 220),
    this.curve = Curves.easeInOut,
    this.activeBackground,
    this.inactiveBackground,
    this.activeBorderColor,
    this.inactiveBorderColor,
    this.activeBorderWidth = 1.5,
    this.inactiveBorderWidth = 1.0,
    this.activeShadow,
    this.inactiveShadow,
    this.activeScale = 1.01,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isActive ? (activeBackground ?? AppColors.lightGreyColor) : (inactiveBackground ?? Colors.white);
    final borderColor = isActive ? (activeBorderColor ?? AppColors.primaryColor) : (inactiveBorderColor ?? AppColors.greyColor);
    final defaultInactiveShadow = [
      const BoxShadow(
        color: Color.fromARGB(8, 0, 0, 0),
        blurRadius: 4,
        offset: Offset(0, 1),
      )
    ];

    final boxShadow = isActive
        ? (activeShadow ??
            [
              BoxShadow(
                color: AppColors.shadowBlack12,
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ])
        : (inactiveShadow ?? defaultInactiveShadow);

    return AnimatedScale(
      scale: isActive ? activeScale : 1.0,
      duration: duration,
      curve: curve,
      child: AnimatedContainer(
        duration: duration,
        curve: curve,
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: borderColor, width: isActive ? activeBorderWidth : inactiveBorderWidth),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: boxShadow,
        ),
        child: child,
      ),
    );
  }
}


