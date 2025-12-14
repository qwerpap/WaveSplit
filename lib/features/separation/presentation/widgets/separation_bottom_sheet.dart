import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/overlay/overlay_state.dart' as ov;
import '../../../../core/overlay/overlay_cubit.dart';
import '../../../../core/services/notification_service.dart';
import '../bloc/separation_bloc.dart';
import '../bloc/separation_event.dart';
import '../bloc/separation_state.dart';

class SeparationStatusPanel extends StatefulWidget {
  const SeparationStatusPanel({super.key});

  @override
  State<SeparationStatusPanel> createState() => _SeparationStatusPanelState();
}

class _SeparationStatusPanelState extends State<SeparationStatusPanel> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<SeparationBloc, SeparationState>(
      listener: (context, state) {
        // close sheet when reset to initial after pick
        if (state is SeparationInitial) {
          if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        }

        // keep backward compatibility: also update global overlay when used
        if (state is SeparationUploading) {
          context.read<OverlayCubit>().updateProgress(phase: ov.OverlayPhase.uploading, message: 'Uploading...', progress: state.progress);
        } else if (state is SeparationProcessing) {
          context.read<OverlayCubit>().updateProgress(phase: ov.OverlayPhase.processing, message: 'Processing...', progress: state.progress);
        } else if (state is SeparationCompleted) {
          context.read<OverlayCubit>().hideRequested();
        } else if (state is SeparationFailure) {
          context.read<OverlayCubit>().hideRequested();
        }
      },
      child: BlocBuilder<SeparationBloc, SeparationState>(
        builder: (context, state) {
          return Container(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              MediaQuery.of(context).padding.bottom + 80,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state is SeparationUploading) ...[
                  // uploading with progress bar and percent label
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Uploading...', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(width: 8),
                      Text('${(state.progress * 100).toStringAsFixed(0)}%', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: state.progress, minHeight: 6),
                ] else if (state is SeparationProcessing) ...[
                  // processing with progress bar, percent and job id
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Processing...', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(width: 8),
                      Text('${(state.progress * 100).toStringAsFixed(0)}%', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: state.progress, minHeight: 6),
                  const SizedBox(height: 8),
                  Text('Job: ${state.jobId}', style: Theme.of(context).textTheme.bodySmall),
                ] else if (state is SeparationCompleted) ...[
                  const Text('Separation ready'),
                  const SizedBox(height: 8),
                  Text('Job: ${state.job.id}'),
                  const SizedBox(height: 8),
                  if (state.job.stems.isNotEmpty || state.job.resultUrl != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(state.isPlaying ? Icons.pause : Icons.play_arrow),
                          onPressed: () async {
                            final playbackUrl = state.job.stems.isNotEmpty
                                ? state.job.stems.first.url
                                : state.job.resultUrl;
                            if (playbackUrl == null || playbackUrl.isEmpty) return;

                            if (state.isPlaying) {
                              context.read<SeparationBloc>().add(const PauseTrackEvent());
                            } else {
                              context.read<SeparationBloc>().add(PlayTrackEvent(
                                trackId: state.job.stems.isNotEmpty
                                    ? state.job.stems.first.name
                                    : state.job.id,
                                trackUrl: playbackUrl,
                                volume: state.volume,
                              ));
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        if (state.job.resultUrl != null)
                          ElevatedButton(
                            onPressed: () async {
                              final resultUrl = state.job.resultUrl;
                              if (resultUrl == null) return;
                              final uri = Uri.parse(resultUrl);
                              final open = await NotificationService.showConfirmation(
                                context,
                                title: 'Download',
                                content: 'Open in browser to download result?',
                                confirmText: 'Open',
                                cancelText: 'Cancel',
                              );
                              if (open == true) {
                                try {
                                  await launchUrl(
                                    uri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                } catch (_) {}
                              }
                            },
                            child: const Text('Download'),
                          ),
                      ],
                    ),
                  ] else ...[
                    const Text('No result URL available'),
                  ],
                ] else if (state is SeparationFailure) ...[
                  Text('Error: ${state.message}'),
                ] else ...[
                  const Text('Ready to upload'),
                ],
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
