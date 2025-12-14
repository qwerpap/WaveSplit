import 'package:flutter/material.dart';
import 'package:wave_split/constants/strings.dart';
import 'package:wave_split/core/theme/app_colors.dart';

import '../models/separated_track_config.dart';

const List<SeparatedTrackConfig> kSeparatedTracksData = [
  SeparatedTrackConfig(
    id: 'vocals',
    title: AppStrings.vocals,
    icon: Icons.mic,
    iconColor: AppColors.vocalsAccent,
    backgroundColor: AppColors.vocalsBg,
  ),
  SeparatedTrackConfig(
    id: 'accompaniment',
    title: AppStrings.accompaniment,
    icon: Icons.library_music,
    iconColor: AppColors.musicAccent,
    backgroundColor: AppColors.musicBg,
  ),
  SeparatedTrackConfig(
    id: 'drums',
    title: AppStrings.drums,
    icon: Icons.music_note,
    iconColor: AppColors.drumsAccent,
    backgroundColor: AppColors.drumsBg,
  ),
  SeparatedTrackConfig(
    id: 'bass',
    title: AppStrings.bass,
    icon: Icons.audiotrack,
    iconColor: AppColors.bassAccent,
    backgroundColor: AppColors.bassBg,
  ),
  SeparatedTrackConfig(
    id: 'piano',
    title: AppStrings.piano,
    icon: Icons.piano,
    iconColor: AppColors.otherAccent,
    backgroundColor: AppColors.otherBg,
  ),
  SeparatedTrackConfig(
    id: 'other',
    title: AppStrings.other,
    icon: Icons.graphic_eq,
    iconColor: AppColors.otherAccent,
    backgroundColor: AppColors.otherBg,
  ),
];

