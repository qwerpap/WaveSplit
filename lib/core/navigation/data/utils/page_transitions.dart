import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/navigation_constants.dart';

class PageTransitions {
  PageTransitions._();

  static Page<T> slideTransition<T extends Object?>({
    required Widget child,
    required GoRouterState state,
    Duration duration = NavigationConstants.normalTransition,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = NavigationConstants.fastOutSlowInCurve;

        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  static Page<T> fadeTransition<T extends Object?>({
    required Widget child,
    required GoRouterState state,
    Duration duration = NavigationConstants.normalTransition,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation.drive(
            CurveTween(curve: NavigationConstants.easeInOutCurve),
          ),
          child: child,
        );
      },
    );
  }

  static Page<T> bottomUpTransition<T extends Object?>({
    required Widget child,
    required GoRouterState state,
    Duration duration = NavigationConstants.normalTransition,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = NavigationConstants.easeInOutCurve;

        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  static Page<T> scaleTransition<T extends Object?>({
    required Widget child,
    required GoRouterState state,
    Duration duration = NavigationConstants.normalTransition,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: animation.drive(
            CurveTween(curve: NavigationConstants.easeOutBackCurve),
          ),
          child: child,
        );
      },
    );
  }
}

class CustomTransitionPage<T> extends Page<T> {
  final Widget child;
  final Duration transitionDuration;
  final Widget Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) transitionsBuilder;

  const CustomTransitionPage({
    required super.key,
    required this.child,
    required this.transitionDuration,
    required this.transitionsBuilder,
  });

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder<T>(
      settings: this,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: transitionDuration,
      transitionsBuilder: transitionsBuilder,
    );
  }
}
