import 'package:flutter/material.dart';

import '../../../constants/image_source.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../constants/strings.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.appTitle, style: AppFonts.displayMedium),
                Text(
                  AppStrings.appSubtitle,
                  style: AppFonts.titleLarge.copyWith(
                    color: AppColors.greyColor,
                  ),
                ),
              ],
            ),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(shape: BoxShape.circle),
              child: ClipRRect(
                borderRadius: BorderRadiusGeometry.circular(99),
                child: Image.asset(ImageSource.placeholder, fit: BoxFit.cover),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
