import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wave_split/core/theme/app_colors.dart';
import 'package:wave_split/core/theme/app_fonts.dart';

import '../bloc/separation_bloc.dart';
import '../bloc/separation_event.dart';
import '../bloc/separation_state.dart';

class AudioPlayerWidget extends StatelessWidget {
  const AudioPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SeparationBloc, SeparationState>(
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.5),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: state.activeTrackId == null
              ? const SizedBox.shrink()
              : Container(
                  key: ValueKey(state.activeTrackId),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Компактная строка с названием и временем
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _getTrackName(state.activeTrackId!),
                              style: AppFonts.titleMedium.copyWith(
                                color: AppColors.blackColor,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${_formatDuration(state.currentPosition)} / ${_formatDuration(state.totalDuration)}',
                            style: AppFonts.bodySmall.copyWith(
                              color: AppColors.greyColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 6),
                      
                      // Прогресс бар
                      _buildProgressBar(context, state),
                      
                      const SizedBox(height: 6),
                      
                      // Компактные контролы
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Перемотка назад
                          IconButton(
                            onPressed: () => _seekBackward(context, state),
                            icon: const Icon(Icons.replay_10),
                            iconSize: 20,
                            color: AppColors.primaryColor,
                            padding: const EdgeInsets.all(6),
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          ),
                          
                          const SizedBox(width: 8),
                          
                          // Play/Pause - более компактная кнопка
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () => _togglePlayPause(context, state),
                              icon: Icon(
                                state.isPlaying ? Icons.pause : Icons.play_arrow,
                                color: AppColors.whiteColor,
                                size: 20,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                          
                          const SizedBox(width: 8),
                          
                          // Перемотка вперед
                          IconButton(
                            onPressed: () => _seekForward(context, state),
                            icon: const Icon(Icons.forward_10),
                            iconSize: 20,
                            color: AppColors.primaryColor,
                            padding: const EdgeInsets.all(6),
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildProgressBar(BuildContext context, SeparationState state) {
    final progress = state.totalDuration.inMilliseconds > 0
        ? state.currentPosition.inMilliseconds / state.totalDuration.inMilliseconds
        : 0.0;

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 2.5,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
        activeTrackColor: AppColors.primaryColor,
        inactiveTrackColor: AppColors.lightGreyColor,
        thumbColor: AppColors.primaryColor,
      ),
      child: Slider(
        value: progress.clamp(0.0, 1.0),
        onChanged: (value) => _onSeek(context, value, state.totalDuration),
      ),
    );
  }

  void _onSeek(BuildContext context, double value, Duration totalDuration) {
    final position = Duration(
      milliseconds: (value * totalDuration.inMilliseconds).round(),
    );
    context.read<SeparationBloc>().add(SeekTrackEvent(position));
  }

  void _togglePlayPause(BuildContext context, SeparationState state) {
    if (state.isPlaying) {
      context.read<SeparationBloc>().add(const PauseTrackEvent());
    } else {
      context.read<SeparationBloc>().add(const ResumeTrackEvent());
    }
  }

  void _seekBackward(BuildContext context, SeparationState state) {
    final newPosition = Duration(
      milliseconds: (state.currentPosition.inMilliseconds - 10000).clamp(0, state.totalDuration.inMilliseconds),
    );
    context.read<SeparationBloc>().add(SeekTrackEvent(newPosition));
  }

  void _seekForward(BuildContext context, SeparationState state) {
    final newPosition = Duration(
      milliseconds: (state.currentPosition.inMilliseconds + 10000).clamp(0, state.totalDuration.inMilliseconds),
    );
    context.read<SeparationBloc>().add(SeekTrackEvent(newPosition));
  }

  String _getTrackName(String trackId) {
    switch (trackId.toLowerCase()) {
      case 'vocals':
        return '🎤 Vocals';
      case 'accompaniment':
        return '🎵 Accompaniment';
      case 'drums':
        return '🥁 Drums';
      case 'bass':
        return '🎸 Bass';
      case 'piano':
        return '🎹 Piano';
      case 'other':
        return '🎼 Other';
      default:
        return '🎵 ${trackId.toUpperCase()}';
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}