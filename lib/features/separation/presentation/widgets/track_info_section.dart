import 'package:flutter/material.dart';
import 'package:wave_split/constants/strings.dart';
import 'package:wave_split/core/shared/widgets/preview_track.dart';
import 'package:wave_split/core/theme/app_colors.dart';
import 'package:wave_split/core/theme/app_fonts.dart';

class TrackInfoSection extends StatelessWidget {
  const TrackInfoSection({
    super.key,
    this.title,
    this.artist,
    this.duration,
    this.previewSize = 256,
  });

  final String? title;
  final String? artist;
  final String? duration;
  final double previewSize;

  @override
  Widget build(BuildContext context) {
    final trackTitle = (title != null && title!.isNotEmpty) ? title! : AppStrings.defaultTrackTitle;
    final trackArtist = (artist != null && artist!.isNotEmpty) ? artist! : AppStrings.unknownArtist;
    final trackDuration = (duration != null && duration!.isNotEmpty) ? duration! : AppStrings.durationPlaceholder;
    final descStyle = AppFonts.titleLarge.copyWith(
      color: AppColors.greyColor,
      fontWeight: FontWeight.w400,
    );
    return Column(
      children: [
        Center(child: PreviewTrack(size: previewSize)),
        const SizedBox(height: 16),
        Text(trackTitle, style: AppFonts.displayMedium),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(trackArtist, style: descStyle),
            Text(' • ', style: descStyle),
            Text(trackDuration, style: descStyle),
          ],
        ),
      ],
    );
  }
}
