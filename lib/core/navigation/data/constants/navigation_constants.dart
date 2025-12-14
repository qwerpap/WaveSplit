import 'package:flutter/material.dart';

class NavigationConstants {
  static const String home = '/home';
  static const String history = '/history';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String separationResult = '/separation/result';
  static const String logs = '/debug/logs';
  
  static const Duration fastTransition = Duration(milliseconds: 200);
  static const Duration normalTransition = Duration(milliseconds: 350);
  static const Duration slowTransition = Duration(milliseconds: 500);
  
  static const Curve easeInOutCurve = Curves.easeInOut;
  static const Curve easeOutBackCurve = Curves.easeOutBack;
  static const Curve fastOutSlowInCurve = Curves.fastOutSlowIn;
}