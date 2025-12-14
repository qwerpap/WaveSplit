import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/shared/widgets/animated_tap.dart';
import '../../../core/shared/widgets/selection_animated.dart';
import '../data/models/separation_card_model.dart';

class SeparationCard extends StatelessWidget {
  final SeparationCardModel model;
  final bool isActive;
  final VoidCallback? onTap;

  const SeparationCard({
    super.key,
    required this.model,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedTap(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      splashColor: AppColors.primaryColor12,
      child: SelectionAnimated(
        isActive: isActive,
        borderRadius: 16,
        child: SizedBox(
          height: 160,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(model.icon, size: 28, color: isActive ? AppColors.primaryColor : AppColors.blackColor),
              const SizedBox(height: 8),
              Text(model.title, style: AppFonts.headlineLarge.copyWith(color: isActive ? AppColors.primaryColor : AppColors.blackColor)),
              const SizedBox(height: 4),
              Text(
                model.subtitle,
                textAlign: TextAlign.center,
                style: AppFonts.titleMedium.copyWith(color: AppColors.greyColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
