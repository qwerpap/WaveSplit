import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../data/constants/bottom_navigation_constants.dart';
import '../utils/navigation_utils.dart';
import 'navigation_state.dart';

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit({
    required String currentLocation,
    required bool isDark,
  }) : super(
          NavigationState(
            currentIndex: NavigationUtils.getCurrentIndex(currentLocation),
            isDark: isDark,
          ),
        );

  final GlobalKey _containerKey = GlobalKey();
  RenderBox? _cachedBox;
  double? _cachedItemWidth;

  GlobalKey get containerKey => _containerKey;

  void updateCurrentRoute(String currentLocation) {
    final newIndex = NavigationUtils.getCurrentIndex(currentLocation);
    if (newIndex != state.currentIndex) {
      emit(state.copyWith(currentIndex: newIndex));
    }
  }

  void updateTheme(bool isDark) {
    if (isDark != state.isDark) {
      emit(state.copyWith(isDark: isDark));
    }
  }

  RenderBox? _getRenderBox() {
    if (_cachedBox != null) {
      final currentBox =
          _containerKey.currentContext?.findRenderObject() as RenderBox?;
      if (currentBox == _cachedBox) {
        return _cachedBox;
      }
    }
    _cachedBox =
        _containerKey.currentContext?.findRenderObject() as RenderBox?;
    _cachedItemWidth = null;
    return _cachedBox;
  }

  double _getItemWidth(RenderBox box) {
    if (_cachedItemWidth != null) {
      return _cachedItemWidth!;
    }
    _cachedItemWidth =
        box.size.width / BottomNavigationConstants.navigationItems.length;
    return _cachedItemWidth!;
  }

  void startDrag(Offset localPosition) {
    _cachedBox = null;
    _cachedItemWidth = null;
    emit(
      state.copyWith(
        isDragging: true,
        dragPosition: localPosition,
      ),
    );
  }

  void updateDrag(Offset localPosition, Size containerSize) {
    final clampedPosition = Offset(
      localPosition.dx.clamp(0.0, containerSize.width),
      localPosition.dy.clamp(0.0, containerSize.height),
    );

    final box = _getRenderBox();
    int? targetIndex;
    if (box != null) {
      final itemWidth = _getItemWidth(box);
      targetIndex = (clampedPosition.dx / itemWidth)
          .floor()
          .clamp(0, BottomNavigationConstants.navigationItems.length - 1);
    }

    emit(
      state.copyWith(
        dragPosition: clampedPosition,
        targetIndex: targetIndex,
      ),
    );
  }

  void endDrag(BuildContext context) {
    if (state.targetIndex != null &&
        state.targetIndex != state.currentIndex) {
      final targetRoute =
          BottomNavigationConstants.navigationItems[state.targetIndex!].route;
      context.go(targetRoute);
    }

    emit(
      state.copyWith(
        isDragging: false,
        clearDragPosition: true,
        clearTargetIndex: true,
      ),
    );
  }

  void cancelDrag() {
    emit(
      state.copyWith(
        isDragging: false,
        clearDragPosition: true,
        clearTargetIndex: true,
      ),
    );
  }

  bool shouldShowIndicator(int index) {
    if (!state.isDragging || state.dragPosition == null) {
      return false;
    }

    final box = _getRenderBox();
    if (box == null) {
      return false;
    }

    final itemWidth = _getItemWidth(box);
    final itemStart = index * itemWidth;
    final itemEnd = (index + 1) * itemWidth;

    return state.dragPosition!.dx >= itemStart &&
        state.dragPosition!.dx < itemEnd;
  }

  void navigateToRoute(BuildContext context, String route) {
    context.go(route);
  }
}

