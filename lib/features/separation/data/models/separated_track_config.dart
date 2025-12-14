import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SeparatedTrackConfig extends Equatable {
  final String id;
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  const SeparatedTrackConfig({
    required this.id,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });

  @override
  List<Object?> get props => [id, title, icon, iconColor, backgroundColor];
}

