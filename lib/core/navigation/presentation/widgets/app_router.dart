import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/history_screen/view/history_screen.dart';
import '../../../../features/home_screen/view/home_screen.dart';
import '../../../../features/profile_screen/view/profile_screen.dart';
import '../../../../features/settings_screen/view/settings_screen.dart';
import '../../../bloc/bloc_providers.dart';
import '../../data/constants/navigation_constants.dart';
import '../../data/utils/page_transitions.dart';
import '../cubit/navigation_cubit.dart';
import 'bottom_navigation.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: NavigationConstants.home,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: NavigationConstants.home,
            pageBuilder: (context, state) => PageTransitions.fadeTransition(
              child: const HomeScreen(),
              state: state,
            ),
          ),
          GoRoute(
            path: NavigationConstants.history,
            pageBuilder: (context, state) => PageTransitions.fadeTransition(
              child: const HistoryScreen(),
              state: state,
            ),
          ),
          GoRoute(
            path: NavigationConstants.settings,
            pageBuilder: (context, state) => PageTransitions.fadeTransition(
              child: const SettingsScreen(),
              state: state,
            ),
          ),
          GoRoute(
            path: NavigationConstants.profile,
            pageBuilder: (context, state) => PageTransitions.fadeTransition(
              child: const ProfileScreen(),
              state: state,
            ),
          ),
        ],
      ),
    ],
  );
}

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProviders.wrapWithProviders(
      context: context,
      child: _NavigationStateUpdater(child: child),
    );
  }
}

class _NavigationStateUpdater extends StatefulWidget {
  final Widget child;

  const _NavigationStateUpdater({required this.child});

  @override
  State<_NavigationStateUpdater> createState() =>
      _NavigationStateUpdaterState();
}

class _NavigationStateUpdaterState extends State<_NavigationStateUpdater> {
  String? _lastLocation;
  Brightness? _lastBrightness;

  void _updateNavigationState() {
    if (!mounted) return;
    
    final cubit = context.read<NavigationCubit>();
    final newLocation = GoRouterState.of(context).uri.path;
    final newBrightness = MediaQuery.platformBrightnessOf(context);
    final newIsDark = newBrightness == Brightness.dark;

    if (_lastLocation != newLocation) {
      cubit.updateCurrentRoute(newLocation);
      _lastLocation = newLocation;
    }
    if (_lastBrightness != newBrightness) {
      cubit.updateTheme(newIsDark);
      _lastBrightness = newBrightness;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateNavigationState();
    });
    
    AppRouter.router.routerDelegate.addListener(_onRouterChanged);
  }

  @override
  void dispose() {
    AppRouter.router.routerDelegate.removeListener(_onRouterChanged);
    super.dispose();
  }

  void _onRouterChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateNavigationState();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newBrightness = MediaQuery.platformBrightnessOf(context);
    
    if (_lastBrightness != newBrightness) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateNavigationState();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          widget.child,
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNavigation(),
          ),
        ],
      ),
    );
  }
}
