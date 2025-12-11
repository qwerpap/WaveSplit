import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import '../../data/constants/bottom_navigation_constants.dart';
import '../../data/constants/bottom_navigation_ui_constants.dart';
import '../../data/constants/navigation_colors.dart';
import '../../data/constants/navigation_icons.dart';
import '../../data/models/navigation_item.dart';
import '../../data/utils/glass_settings_factory.dart';
import '../cubit/navigation_cubit.dart';
import '../cubit/navigation_state.dart';

class CustomBottomNavigation extends StatelessWidget {
  const CustomBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, state) {
        final cubit = context.read<NavigationCubit>();
        final glassSettings = GlassSettingsFactory.createSettings(state.isDark);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: BottomNavigationUIConstants.horizontalPadding,
              vertical: BottomNavigationUIConstants.verticalPadding,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  BottomNavigationUIConstants.borderRadius,
                ),
                boxShadow: [
                  BoxShadow(
                    color: NavigationColors.getContainerShadowColor(),
                    blurRadius: BottomNavigationUIConstants.shadowBlurRadius,
                    offset: BottomNavigationUIConstants.shadowOffset,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: LiquidGlassLayer(
                settings: glassSettings,
                child: LiquidGlass(
                  shape: LiquidRoundedSuperellipse(
                    borderRadius: BottomNavigationUIConstants.borderRadius,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        BottomNavigationUIConstants.borderRadius,
                      ),
                      border: Border.all(
                        color: NavigationColors.getBorderColor(state.isDark),
                        width: NavigationColors.getBorderWidth(state.isDark),
                      ),
                    ),
                    child: GlassGlow(
                      glowColor: NavigationColors.getGlassGlowColor(),
                      glowRadius:
                          BottomNavigationUIConstants.indicatorGlowRadius,
                      child: GestureDetector(
                        onPanStart: (details) {
                          final box = cubit.containerKey.currentContext
                              ?.findRenderObject() as RenderBox?;
                          if (box != null) {
                            final localPosition =
                                box.globalToLocal(details.globalPosition);
                            cubit.startDrag(localPosition);
                          }
                        },
                        onPanUpdate: (details) {
                          final box = cubit.containerKey.currentContext
                              ?.findRenderObject() as RenderBox?;
                          if (box != null) {
                            final localPosition =
                                box.globalToLocal(details.globalPosition);
                            cubit.updateDrag(localPosition, box.size);
                          }
                        },
                        onPanEnd: (details) => cubit.endDrag(context),
                        onPanCancel: () => cubit.cancelDrag(),
                        child: _NavigationContent(
                          currentIndex: state.currentIndex,
                          isDragging: state.isDragging,
                          targetIndex: state.targetIndex,
                          dragPosition: state.dragPosition,
                          cubit: cubit,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavigationContent extends StatelessWidget {
  final int currentIndex;
  final bool isDragging;
  final int? targetIndex;
  final Offset? dragPosition;
  final NavigationCubit cubit;

  const _NavigationContent({
    required this.currentIndex,
    required this.isDragging,
    required this.targetIndex,
    required this.dragPosition,
    required this.cubit,
  });

  bool _shouldShowIndicator(int index) {
    if (!isDragging || dragPosition == null) {
      return false;
    }

    final box = cubit.containerKey.currentContext
        ?.findRenderObject() as RenderBox?;
    if (box == null) {
      return false;
    }

    final itemWidth =
        box.size.width / BottomNavigationConstants.navigationItems.length;
    final itemStart = index * itemWidth;
    final itemEnd = (index + 1) * itemWidth;

    return dragPosition!.dx >= itemStart && dragPosition!.dx < itemEnd;
  }

  @override
  Widget build(BuildContext context) {
        return RepaintBoundary(
          child: Container(
            key: cubit.containerKey,
            padding: const EdgeInsets.symmetric(
          horizontal: BottomNavigationUIConstants.containerHorizontalPadding,
            ),
            height: BottomNavigationUIConstants.barHeight,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth =
                    constraints.maxWidth /
                    BottomNavigationConstants.navigationItems.length;

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: BottomNavigationConstants.navigationItems.length,
                  itemExtent: itemWidth,
                  itemBuilder: (context, index) {
                final item = BottomNavigationConstants.navigationItems[index];
                    final isSelected = index == currentIndex;
                final showIndicator = isSelected || _shouldShowIndicator(index);

                    return _NavigationItem(
                      item: item,
                      isSelected: isSelected,
                      showIndicator: showIndicator,
                      onTap: () => cubit.navigateToRoute(context, item.route),
                    );
                  },
                );
              },
            ),
          ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  final NavigationItem item;
  final bool isSelected;
  final bool showIndicator;
  final VoidCallback onTap;

  const _NavigationItem({
    required this.item,
    required this.isSelected,
    required this.showIndicator,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = isSelected
        ? NavigationColors.selectedIconColor
        : NavigationColors.unselectedIconColor;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: LiquidStretch(
        child: GlassGlow(
          glowColor: isSelected
              ? NavigationColors.getSelectedGlowColor()
              : NavigationColors.getUnselectedGlowColor(),
          glowRadius: isSelected
              ? BottomNavigationUIConstants.selectedGlowRadius
              : BottomNavigationUIConstants.unselectedGlowRadius,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: BottomNavigationUIConstants.itemVerticalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    if (showIndicator) const _IndicatorShadow(),
                    AnimatedScale(
                      scale: isSelected
                          ? BottomNavigationUIConstants.selectedScale
                          : BottomNavigationUIConstants.unselectedScale,
                      duration:
                          BottomNavigationUIConstants.scaleAnimationDuration,
                      curve: BottomNavigationUIConstants.scaleAnimationCurve,
                      child: Icon(
                        NavigationIcons.getIconByRoute(item.route),
                        color: iconColor,
                        size: BottomNavigationUIConstants.iconSize,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: BottomNavigationUIConstants.iconSpacing),
                Text(
                  item.label,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: BottomNavigationUIConstants.fontSize,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IndicatorShadow extends StatelessWidget {
  const _IndicatorShadow();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: BottomNavigationUIConstants.indicatorPositionOffset,
      right: BottomNavigationUIConstants.indicatorPositionOffset,
      left: BottomNavigationUIConstants.indicatorPositionOffset,
      bottom: BottomNavigationUIConstants.indicatorPositionOffset,
      child: AnimatedContainer(
        duration: BottomNavigationUIConstants.indicatorAnimationDuration,
        curve: BottomNavigationUIConstants.indicatorAnimationCurve,
        child: AnimatedOpacity(
          duration: BottomNavigationUIConstants.indicatorAnimationDuration,
          opacity: 1,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: NavigationColors.getIndicatorShadowColor(),
                  blurRadius: BottomNavigationUIConstants.indicatorShadowBlur,
                  spreadRadius:
                      BottomNavigationUIConstants.indicatorShadowSpread,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
