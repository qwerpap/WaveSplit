import 'package:flutter/material.dart';

import '../../../core/shared/widgets/preview_track.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/utils/date_utils.dart' as date_utils;
import '../../history/data/models/track_history_model.dart';

class RecentTrackCard extends StatelessWidget {
  final TrackHistoryModel? track;
  final VoidCallback? onPlay;

  const RecentTrackCard({
    super.key,
    this.track,
    this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    if (track == null) {
      return _buildEmptyState();
    }

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
            ),
          ],
        ),
        child: Row(
        children: [
          // Gradient square icon
          const PreviewTrack(),
          const SizedBox(width: 12),
          // Title and details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        track!.displayName,
                        style: AppFonts.displaySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  ],
                ),
                Text(
                  '${track!.modelDisplayName} • ${date_utils.DateUtils.formatTimeAgo(track!.createdAt)}',
                  style: AppFonts.titleMedium.copyWith(
                    color: AppColors.greyColor,
                  ),
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
                  ),
                ],
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
        ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.lightGreyColor.withValues(alpha: 0.3),
        border: Border.all(color: AppColors.lightGreyColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.lightGreyColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.music_note,
              color: AppColors.greyColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No recent tracks',
                  style: AppFonts.displaySmall.copyWith(
                    color: AppColors.greyColor,
                  ),
                ),
                Text(
                  'Upload a track to get started',
                  style: AppFonts.titleMedium.copyWith(
                    color: AppColors.greyColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

