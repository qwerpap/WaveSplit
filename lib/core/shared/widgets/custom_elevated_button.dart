import 'package:flutter/material.dart';
import 'package:wave_split/core/theme/app_colors.dart';
import 'package:wave_split/core/theme/app_fonts.dart';
import 'package:wave_split/core/theme/button_styles.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final double height;
  final double? horizontalPadding;

  const CustomElevatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.width,
    this.height = 56,
    this.horizontalPadding,
  });

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: onPressed,
      style: primaryButtonStyle(radius: 12),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding ?? 16),
        child: Text(
          text,
          style: AppFonts.headlineLarge.copyWith(color: AppColors.whiteColor),
        ),
      ),
    );

    if (width != null) {
      return SizedBox(width: width, height: height, child: button);
    }
    // If horizontalPadding is explicitly provided, size to content (centered)
    // but ensure the button fills the requested height.
    if (horizontalPadding != null) {
      return SizedBox(
        height: height,
        child: Center(
          child: SizedBox(height: height, child: button),
        ),
      );
    }

    // Default behaviour: full width
    return SizedBox(width: double.infinity, height: height, child: button);
  }
}
