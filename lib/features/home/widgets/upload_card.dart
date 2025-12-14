import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/shared/widgets/custom_elevated_button.dart';
import '../../../core/shared/widgets/dashed_rounded_rect_painter.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../constants/strings.dart';

class UploadCard extends StatelessWidget {
  const UploadCard({
    super.key, 
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.15,
      child: Container(
        margin: EdgeInsets.only(bottom: 20),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.lightGreyColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: CustomPaint(
          painter: const DashedRoundedRectPainter(
            strokeWidth: 1.5,
            color: Colors.grey,
            radius: 12,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _UploadIcon(),
              const SizedBox(height: 16),
              const Text(AppStrings.uploadTitle, style: AppFonts.displaySmall),
              const SizedBox(height: 8),
              Text(
                AppStrings.uploadHint,
                style: AppFonts.titleMedium.copyWith(
                  color: AppColors.greyColor,
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: CustomElevatedButton(
                  text: isLoading ? 'Selecting...' : AppStrings.chooseFile,
                  horizontalPadding: 16,
                  onPressed: onPressed,
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _UploadIcon extends StatelessWidget {
  const _UploadIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor10,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.cloud_upload,
        size: 28,
        color: AppColors.primaryColor,
      ),
    );
  }
}
