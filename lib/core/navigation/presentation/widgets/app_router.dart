import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/history/view/history_screen.dart';
import '../../../../features/home/view/home_screen.dart';
import '../../../../features/profile/view/profile_screen.dart';
import '../../../../features/settings_screen/view/settings_screen.dart';
import '../../../../features/separation/data/models/separation_job_model.dart';
import '../../../../features/separation/presentation/view/separation_result_screen.dart';
import '../../../../features/separation/presentation/bloc/separation_bloc.dart';
import '../../../../features/separation/presentation/bloc/separation_state.dart';
import '../../../../features/history/presentation/bloc/history_bloc.dart';
import '../../../../features/history/presentation/bloc/history_event.dart';
import 'package:talker_flutter/talker_flutter.dart';
import '../../../bloc/bloc_providers.dart';
import '../../data/constants/navigation_constants.dart';
import '../../data/utils/page_transitions.dart';
import '../cubit/navigation_cubit.dart';
import 'bottom_navigation.dart';
import '../../../overlay/overlay_cubit.dart';
import '../../../overlay/overlay_state.dart' as ov;
import '../../../theme/app_fonts.dart';
import '../../../services/notification_service.dart';
import 'dart:async';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: NavigationConstants.home,
    // initialLocation: NavigationConstants.separationResult,
    observers: [TalkerRouteObserver(getIt<Talker>())],
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
          GoRoute(
            path: NavigationConstants.logs,
            pageBuilder: (context, state) => PageTransitions.slideTransition(
              child: TalkerScreen(talker: getIt()),
              state: state,
            ),
          ),
          GoRoute(
            path: NavigationConstants.separationResult,
            pageBuilder: (context, state) {
              final job = state.extra is SeparationJobModel ? state.extra as SeparationJobModel : null;
              return PageTransitions.slideTransition(
                child: SeparationResultScreen(job: job),
                state: state,
              );
            },
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
      child: _SeparationFlowListener(
        child: _NavigationStateUpdater(child: child),
      ),
    );
  }
}

class _SeparationFlowListener extends StatefulWidget {
  final Widget child;

  const _SeparationFlowListener({required this.child});

  @override
  State<_SeparationFlowListener> createState() => _SeparationFlowListenerState();
}

class _SeparationFlowListenerState extends State<_SeparationFlowListener> {
  bool _navigating = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<SeparationBloc, SeparationState>(
      listener: (context, state) {
        final overlayCubit = context.read<OverlayCubit>();
        if (state is SeparationUploading) {
          overlayCubit.showRequested(
            phase: ov.OverlayPhase.uploading,
            message: 'Uploading...',
            progress: state.progress,
          );
          overlayCubit.updateProgress(
            phase: ov.OverlayPhase.uploading,
            message: 'Uploading...',
            progress: state.progress,
          );
        } else if (state is SeparationProcessing) {
          overlayCubit.showRequested(
            phase: ov.OverlayPhase.processing,
            message: 'Processing...',
            progress: state.progress,
          );
          overlayCubit.updateProgress(
            phase: ov.OverlayPhase.processing,
            message: 'Processing...',
            progress: state.progress,
          );
        } else if (state is SeparationCompleted) {
          _handleCompletion(context, state.job);
        } else if (state is SeparationFailure) {
          overlayCubit.reset();
          NotificationService.showError(
            context,
            message: 'Error: ${state.message}',
          );
          _navigating = false;
        } else if (state is SeparationInitial) {
          overlayCubit.reset();
          _navigating = false;
        }
      },
      child: widget.child,
    );
  }

  Future<void> _handleCompletion(BuildContext context, SeparationJobModel job) async {
    if (_navigating || !mounted) return;
    _navigating = true;
    
    final overlayCubit = context.read<OverlayCubit>();
    overlayCubit.hideRequested();
    
    try {
      await overlayCubit.stream.firstWhere((s) => s.uiTarget >= 1.0);
      await Future.delayed(const Duration(milliseconds: 220));
    } catch (_) {}
    
    if (!mounted) {
      _navigating = false;
      return;
    }
    
    final currentPath = GoRouterState.of(context).uri.path;
    if (currentPath != NavigationConstants.separationResult && mounted) {
      await context.push(NavigationConstants.separationResult, extra: job);
      
      // После возврата с экрана результатов
      if (mounted) {
        overlayCubit.reset();
        
        // Обновляем историю на home screen
        try {
          if (mounted) {
            context.read<HistoryBloc>().add(const RefreshHistoryEvent());
          }
        } catch (e) {
          // Игнорируем ошибку если HistoryBloc не найден
        }
      }
    }
    
    _navigating = false;
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
