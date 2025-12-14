import 'package:flutter/material.dart';
import 'package:wave_split/core/theme/app_colors.dart';

class IconInCircle extends StatelessWidget {
  const IconInCircle({super.key, this.size = 50, required this.icon});

  final double size;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: AppColors.lightGreyColor,
        shape: BoxShape.circle,
      ),
      child: Icon(icon),
    );
  }
}
