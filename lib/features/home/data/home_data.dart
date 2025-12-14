import 'package:flutter/material.dart';

import 'models/separation_card_model.dart';
import '../../../constants/strings.dart';

const List<SeparationCardModel> kSeparationOptions = [
  SeparationCardModel(
    id: '2stems',
    title: AppStrings.twoStemsTitle,
    subtitle: AppStrings.twoStemsSubtitle,
    icon: Icons.music_note,
  ),
  SeparationCardModel(
    id: '4stems',
    title: AppStrings.fourStemsTitle,
    subtitle: AppStrings.fourStemsSubtitle,
    icon: Icons.queue_music,
  ),
];
