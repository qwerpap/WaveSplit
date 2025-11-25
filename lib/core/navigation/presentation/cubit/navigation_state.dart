import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class NavigationState extends Equatable {
  final int currentIndex;
  final bool isDark;
  final bool isDragging;
  final Offset? dragPosition;
  final int? targetIndex;

  const NavigationState({
    required this.currentIndex,
    required this.isDark,
    this.isDragging = false,
    this.dragPosition,
    this.targetIndex,
  });

  NavigationState copyWith({
    int? currentIndex,
    bool? isDark,
    bool? isDragging,
    Offset? dragPosition,
    int? targetIndex,
    bool clearDragPosition = false,
    bool clearTargetIndex = false,
  }) {
    return NavigationState(
      currentIndex: currentIndex ?? this.currentIndex,
      isDark: isDark ?? this.isDark,
      isDragging: isDragging ?? this.isDragging,
      dragPosition: clearDragPosition
          ? null
          : (dragPosition ?? this.dragPosition),
      targetIndex: clearTargetIndex
          ? null
          : (targetIndex ?? this.targetIndex),
    );
  }

  @override
  List<Object?> get props => [
        currentIndex,
        isDark,
        isDragging,
        dragPosition,
        targetIndex,
      ];
}

