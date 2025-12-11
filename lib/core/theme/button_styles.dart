import 'package:flutter/material.dart';
import 'package:wave_split/core/theme/app_colors.dart';

ButtonStyle primaryButtonStyle({double radius = 10}) {
  return ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith<Color?>(
      (states) => states.contains(WidgetState.disabled) ? AppColors.primaryColor50 : AppColors.primaryColor,
    ),
    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
    ),
    overlayColor: WidgetStateProperty.resolveWith<Color?>(
      (states) => states.contains(WidgetState.pressed) ? AppColors.whiteColor26 : AppColors.whiteColor06,
    ),
    elevation: WidgetStateProperty.resolveWith<double>(
      (states) => states.contains(WidgetState.pressed) ? 6.0 : 0.0,
    ),
    shadowColor: WidgetStateProperty.all<Color>(AppColors.shadowBlack12),
  );
}


