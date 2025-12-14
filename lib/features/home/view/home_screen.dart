import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wave_split/core/overlay/overlay_cubit.dart';
import 'package:wave_split/core/overlay/overlay_state.dart' as ov;
import 'package:wave_split/features/separation/presentation/bloc/separation_state.dart';
import 'package:wave_split/features/history/presentation/bloc/history_bloc.dart';
import 'package:wave_split/features/history/presentation/bloc/history_state.dart';
import 'package:wave_split/features/history/data/models/track_history_model.dart';
import 'package:wave_split/features/separation/presentation/bloc/separation_bloc.dart';

import '../../../core/theme/app_fonts.dart';
import '../../../core/services/navigation_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/navigation/data/constants/navigation_constants.dart';
import '../../../constants/strings.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/recent_track_card.dart';
import '../widgets/separation_card.dart';
import '../widgets/upload_card.dart';
import '../data/home_data.dart';
import '../presentation/cubit/home_cubit.dart';
import '../presentation/cubit/home_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeCubit _homeCubit;

  @override
  void initState() {
    super.initState();
    _homeCubit = HomeCubit(
      separationBloc: context.read<SeparationBloc>(),
      historyBloc: context.read<HistoryBloc>(),
    );
    _homeCubit.initialize();
  }

  @override
  void dispose() {
    _homeCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom + 120;

    return MultiBlocProvider(
      providers: [BlocProvider.value(value: _homeCubit)],
      child: MultiBlocListener(
        listeners: [
          BlocListener<SeparationBloc, SeparationState>(
            listener: (context, state) {
              if (state is SeparationFailure) {
                NotificationService.showError(
                  context,
                  message: state.message,
                );
              } else if (state is SeparationCompleted) {
                _homeCubit.refreshHistory();
              }
            },
          ),
          BlocListener<HomeCubit, HomeState>(
            listener: (context, state) {
              if (state.error != null) {
                NotificationService.showFilePickingError(
                  context,
                  message: state.error!,
                );
                _homeCubit.clearError();
              }

              if (state.recentTrackMessage != null) {
                NotificationService.showInfo(
                  context,
                  message: state.recentTrackMessage!,
                  duration: const Duration(seconds: 2),
                );
                _homeCubit.clearRecentTrackMessage();
              }

              // Навигация к логам при достижении 7 тапов
              if (state.logoTapCount >= 7 || state.logsTapCount >= 7) {
                _homeCubit.resetTapCounts();
                NavigationService.navigatePush(
                  context,
                  NavigationConstants.logs,
                );
              }
            },
          ),
        ],
        child: Scaffold(
          appBar: const PreferredSize(
            preferredSize: Size.fromHeight(65),
            child: HomeAppBar(),
          ),
          body: ListView(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: bottomPadding,
            ),
            children: [
              BlocBuilder<HomeCubit, HomeState>(
                builder: (context, homeState) {
                  return UploadCard(
                    onPressed: homeState.isPickingFile
                        ? null
                        : () => _homeCubit.uploadFile(),
                    isLoading: homeState.isPickingFile,
                  );
                },
              ),
              const SizedBox(height: 8),
              // Inline progress bar under UploadCard
              BlocBuilder<OverlayCubit, ov.OverlayState>(
                builder: (context, overlayState) {
                  if (!overlayState.visible ||
                      overlayState.phase == ov.OverlayPhase.none) {
                    return const SizedBox.shrink();
                  }
                  final percent = (overlayState.uiTarget * 100)
                      .clamp(0.0, 100.0)
                      .toInt();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        overlayState.phase == ov.OverlayPhase.uploading
                            ? 'Uploading...'
                            : 'Processing...',
                        style: AppFonts.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: overlayState.uiTarget,
                          minHeight: 8,
                          backgroundColor: Theme.of(
                            context,
                          ).dividerColor.withValues(alpha: 0.08),
                          valueColor: AlwaysStoppedAnimation(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('$percent%', style: AppFonts.titleSmall),
                      const SizedBox(height: 10),
                    ],
                  );
                },
              ),
              const SizedBox(height: 2),
              const Text(
                AppStrings.separationMode,
                style: AppFonts.displaySmall,
              ),
              const SizedBox(height: 10),
              BlocBuilder<HomeCubit, HomeState>(
                builder: (context, homeState) {
                  return Row(
                    children: List.generate(kSeparationOptions.length, (i) {
                      final item = kSeparationOptions[i];
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: i == 0 ? 0 : 8,
                            right: i == kSeparationOptions.length - 1 ? 0 : 8,
                          ),
                          child: SeparationCard(
                            model: item,
                            isActive: homeState.selectedSeparationIndex == i,
                            onTap: () => _homeCubit.selectSeparationMode(i),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
              const SizedBox(height: 40),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _homeCubit.incrementLogsTapCount(),
                child: const Text(
                  AppStrings.recentTracks,
                  style: AppFonts.displaySmall,
                ),
              ),
              const SizedBox(height: 10),
              BlocBuilder<HistoryBloc, HistoryState>(
                builder: (context, historyState) {
                  TrackHistoryModel? mostRecentTrack;

                  if (historyState is HistoryLoaded &&
                      historyState.tracks.isNotEmpty) {
                    mostRecentTrack = historyState.tracks.first;
                  }

                  return RecentTrackCard(
                    track: mostRecentTrack,
                    onPlay: mostRecentTrack != null
                        ? () => _homeCubit.playRecentTrack(
                              mostRecentTrack!.displayName,
                              mostRecentTrack.modelDisplayName,
                            )
                        : null,
                  );
                },
              ),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _homeCubit.incrementLogoTapCount(),
                  child: const SizedBox(height: 20, width: 140),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}
