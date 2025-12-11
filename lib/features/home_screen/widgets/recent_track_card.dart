import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../constants/strings.dart';

class RecentTrackCard extends StatelessWidget {
  final String title;
  final String details;
  final VoidCallback? onPlay;

  const RecentTrackCard({
    super.key,
    this.title = AppStrings.defaultTrackTitle,
    this.details = AppStrings.defaultTrackDetails,
    this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        border: Border.all(color: AppColors.lightGreyColor),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlack12,
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          // Gradient square icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFEE9AE5),
                  Color(0xFF6C5CE7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.music_note,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Title and details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppFonts.displaySmall),
                Text(
                  details,
                  style: AppFonts.titleMedium.copyWith(color: AppColors.greyColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Play button
          GestureDetector(
            onTap: onPlay,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowBlack12,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: const Icon(Icons.play_arrow, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}
