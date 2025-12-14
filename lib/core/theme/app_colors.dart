import 'package:flutter/material.dart';

class AppColors {
  static const Color whiteColor = Colors.white;
  static const Color blackColor = Color.fromRGBO(45, 55, 72, 1);

  // Primary
  static const Color primaryColor = Color(0xFF6C5CE7);
  // Primary variants with common opacities used in UI (precomputed ARGB to avoid runtime math).
  static const Color primaryColor06 = Color.fromARGB(15, 108, 92, 231); // 0.06
  static const Color primaryColor10 = Color.fromARGB(26, 108, 92, 231); // 0.10
  static const Color primaryColor12 = Color.fromARGB(31, 108, 92, 231); // 0.12
  static const Color primaryColor50 = Color.fromARGB(128, 108, 92, 231); // 0.50

  // Neutrals / Greys
  static const Color greyColor = Color.fromRGBO(121, 129, 143, 1);
  static const Color lightGreyColor = Color.fromRGBO(243, 243, 243, 1);

  static const Color greenColor = Color.fromRGBO(103, 209, 197, 1);
  static const Color vocalsAccent = Color(0xFFE74C3C);
  static const Color vocalsBg = Color(0xFFFFEAEA);
  static const Color drumsAccent = Color(0xFF4C7DFF);
  static const Color drumsBg = Color(0xFFE8EFFF);
  static const Color bassAccent = greenColor;
  static const Color bassBg = Color(0xFFEAF8F5);
  static const Color otherAccent = greyColor;
  static const Color otherBg = Color(0xFFF2F3F5);
  
  // Цвета для музыки/аккомпанемента
  static const Color musicAccent = Color(0xFF9C27B0);  // Фиолетовый
  static const Color musicBg = Color(0xFFF3E5F5);      // Светло-фиолетовый

  static const Color whiteColor26 = Color.fromARGB(66, 255, 255, 255); // 0.26
  static const Color whiteColor06 = Color.fromARGB(15, 255, 255, 255); // 0.06

  static const Color shadowBlack12 = Color.fromARGB(31, 0, 0, 0); // 0.12

  static const Color scaffoldBgColor = Color.fromRGBO(249, 250, 251, 1);
  
  // Modern colors for silent tracks
  static const Color silentTrackBg = Color(0xFFF1F5F9);      // Soft blue-gray background
  static const Color silentTrackBorder = Color(0xFFCBD5E1);  // Subtle border
  static const Color silentTrackIcon = Color(0xFF64748B);    // Muted icon color
  static const Color silentTrackText = Color(0xFF64748B);    // Muted text color
}
