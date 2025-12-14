import 'package:flutter/material.dart';
import 'package:wave_split/core/theme/app_colors.dart';
import 'package:wave_split/core/theme/app_fonts.dart';

import '../models/separated_track_item.dart';

class SeparatedTrackCard extends StatelessWidget {
  const SeparatedTrackCard({
    super.key,
    required this.track,
    this.onVolumeChanged,
    this.onPlayToggle,
  });

  final SeparatedTrackItem track;
  final ValueChanged<double>? onVolumeChanged;
  final VoidCallback? onPlayToggle;

  @override
  Widget build(BuildContext context) {
    // Отладочная информация для диагностики цветов (временно включено)
    // print('🎨 Track ${track.config.title}:');
    // print('   Config ID: ${track.config.id}');
    // print('   Background: ${track.config.backgroundColor}');
    // print('   Icon Color: ${track.config.iconColor}');
    // print('   Silent Warning: ${track.hasSilentWarning}');
    // print('   Playable: ${track.isPlayable}');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: track.hasSilentWarning 
                ? AppColors.silentTrackBg.withValues(alpha: 0.5)
                : AppColors.lightGreyColor,
            borderRadius: BorderRadius.circular(16),
            border: track.hasSilentWarning 
                ? Border.all(
                    color: AppColors.silentTrackBorder.withValues(alpha: 0.3),
                    width: 1,
                  )
                : null,
          ),
          child: Row(
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: track.hasSilentWarning 
                      ? track.config.backgroundColor.withValues(alpha: 0.3)
                      : track.config.backgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  track.config.icon,
                  color: track.hasSilentWarning 
                      ? track.config.iconColor.withValues(alpha: 0.4)
                      : track.config.iconColor,
                  size: 26,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.config.title,
                      style: AppFonts.titleLarge.copyWith(color: AppColors.blackColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (track.hasSilentWarning) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Silent track',
                        style: AppFonts.bodySmall.copyWith(
                          color: const Color(0xFF64748B),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                  ),
                  child: Slider(
                    value: track.volume.clamp(0.0, 1.0).toDouble(),
                    min: 0.0,
                    max: 1.0,
                    activeColor: track.isPlayable 
                        ? AppColors.primaryColor 
                        : AppColors.silentTrackBorder,
                    inactiveColor: track.hasSilentWarning 
                        ? AppColors.silentTrackBorder.withValues(alpha: 0.3)
                        : Colors.grey.shade300,
                    onChanged: track.isPlayable ? onVolumeChanged : null,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildPlayButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayButton() {
    // Если трек анализируется
    if (track.isAnalyzing) {
      return Container(
        height: 56,
        width: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade300,
        ),
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(Colors.grey),
          ),
        ),
      );
    }

    // Если трек тихий/пустой - современный дизайн
    if (track.hasSilentWarning) {
      return Tooltip(
        message: 'This track appears to be silent or empty',
        child: Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.silentTrackBg,
            border: Border.all(
              color: AppColors.silentTrackBorder,
              width: 1.5,
            ),
          ),
          child: Icon(
            Icons.volume_off_rounded,
            color: AppColors.silentTrackIcon,
            size: 24,
          ),
        ),
      );
    }

    // Обычная кнопка воспроизведения
    return InkWell(
      onTap: track.isPlayable ? onPlayToggle : null,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 56,
        width: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: track.isPlayable
              ? AppColors.primaryColor
              : Colors.grey.shade300,
        ),
        child: Icon(
          track.isPlaying ? Icons.pause : Icons.play_arrow,
          color: track.isPlayable ? AppColors.whiteColor : Colors.grey.shade500,
          size: 28,
        ),
      ),
    );
  }
}
