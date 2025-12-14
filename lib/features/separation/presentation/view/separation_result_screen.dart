import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../constants/strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/services/notification_service.dart';
import '../../data/models/separation_job_model.dart';
import '../bloc/separation_bloc.dart';
import '../bloc/separation_state.dart';
import '../cubit/separation_result_cubit.dart';
import '../cubit/separation_result_state.dart';

import '../widgets/audio_player_widget.dart';
import '../widgets/network_diagnostic_dialog.dart';
import '../widgets/separated_track_card.dart';
import '../widgets/separation_app_bar.dart';
import '../widgets/track_info_section.dart';

class SeparationResultScreen extends StatefulWidget {
  const SeparationResultScreen({super.key, this.job});

  final SeparationJobModel? job;

  @override
  State<SeparationResultScreen> createState() => _SeparationResultScreenState();
}

class _SeparationResultScreenState extends State<SeparationResultScreen> {
  late final SeparationResultCubit _resultCubit;

  @override
  void initState() {
    super.initState();
    _resultCubit = SeparationResultCubit(
      separationBloc: context.read<SeparationBloc>(),
      initialJob: widget.job,
    );
    _resultCubit.initialize();
  }

  @override
  void dispose() {
    _resultCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom + 120;

    return BlocProvider.value(
      value: _resultCubit,
      child: MultiBlocListener(
        listeners: [
          BlocListener<SeparationBloc, SeparationState>(
            listener: (context, state) {
              if (state is SeparationFailure) {
                NotificationService.showNetworkError(
                  context,
                  message: state.message,
                  onDiagnose: () => _showNetworkDiagnostics(context),
                );
              } else if (state is SeparationCompleted) {
                _resultCubit.updateJob(state.job, state.analysisResults);
              }
            },
          ),
          BlocListener<SeparationResultCubit, SeparationResultState>(
            listener: (context, state) {
              if (state.error != null) {
                NotificationService.showNetworkError(
                  context,
                  message: state.error!,
                  onDiagnose: () => _showNetworkDiagnostics(context),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<SeparationResultCubit, SeparationResultState>(
          builder: (context, resultState) {
            return BlocBuilder<SeparationBloc, SeparationState>(
              buildWhen: (previous, current) {
                if (previous.runtimeType != current.runtimeType) return true;
                if (previous.activeTrackId != current.activeTrackId) return true;
                if (previous.isPlaying != current.isPlaying) return true;
                if (previous.volume != current.volume) return true;
                return false;
              },
              builder: (context, separationState) {
                final trackTitle = resultState.job?.originalFileName ?? AppStrings.defaultTrackTitle;
                final tracks = resultState.tracks;

                return Scaffold(
                  backgroundColor: AppColors.scaffoldBgColor,
                  appBar: const PreferredSize(
                    preferredSize: Size.fromHeight(60),
                    child: SeparationAppBar(),
                  ),
                  body: ListView(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 12,
                      bottom: bottomPadding,
                    ),
                    children: [
                      TrackInfoSection(
                        title: trackTitle,
                        artist: AppStrings.unknownArtist,
                        duration: null,
                      ),
                      const SizedBox(height: 16),
                      const AudioPlayerWidget(),
                      const SizedBox(height: 12),
                      Text(AppStrings.separatedTracks, style: AppFonts.headlineLarge),
                      const SizedBox(height: 12),
                      if (tracks.isEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.lightGreyColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              AppStrings.noStemsAvailable,
                              style: AppFonts.titleMedium.copyWith(color: AppColors.greyColor),
                            ),
                          ),
                        ),
                      ] else ...[
                        ...tracks.map(
                          (track) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: SeparatedTrackCard(
                              track: track.copyWith(
                                isPlaying: separationState.activeTrackId == track.config.id && separationState.isPlaying,
                                volume: separationState.activeTrackId == track.config.id ? separationState.volume : track.volume,
                              ),
                              onVolumeChanged: track.isPlayable 
                                  ? (value) => _resultCubit.setVolume(track.config.id, value)
                                  : null,
                              onPlayToggle: track.isPlayable 
                                  ? () async => await _resultCubit.togglePlayback(
                                        track,
                                        separationState.isPlaying,
                                        separationState.activeTrackId,
                                      )
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }



  void _showNetworkDiagnostics(BuildContext context, [String? testUrl]) {
    showDialog(
      context: context,
      builder: (context) => NetworkDiagnosticDialog(testUrl: testUrl),
    );
  }
}
