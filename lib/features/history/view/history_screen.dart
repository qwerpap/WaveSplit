import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/services/notification_service.dart';
import '../presentation/bloc/history_bloc.dart';
import '../presentation/bloc/history_event.dart';
import '../presentation/bloc/history_state.dart';
import '../../home/widgets/recent_track_card.dart';
import '../data/models/track_history_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Загружаем историю при открытии экрана
    context.read<HistoryBloc>().add(const LoadHistoryEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBgColor,
      appBar: AppBar(
        title: Text('History', style: AppFonts.headlineLarge),
        backgroundColor: AppColors.scaffoldBgColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showClearHistoryDialog(context),
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear History',
          ),
        ],
      ),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is HistoryError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.greyColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading history',
                    style: AppFonts.titleLarge.copyWith(
                      color: AppColors.greyColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: AppFonts.bodyMedium.copyWith(
                      color: AppColors.greyColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<HistoryBloc>().add(const RefreshHistoryEvent()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is HistoryLoaded) {
            if (state.tracks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: 64,
                      color: AppColors.greyColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No history yet',
                      style: AppFonts.titleLarge.copyWith(
                        color: AppColors.greyColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload and separate tracks to see them here',
                      style: AppFonts.bodyMedium.copyWith(
                        color: AppColors.greyColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<HistoryBloc>().add(const RefreshHistoryEvent());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.tracks.length,
                itemBuilder: (context, index) {
                  final track = state.tracks[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Dismissible(
                      key: Key(track.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (direction) {
                        context.read<HistoryBloc>().add(
                          RemoveTrackFromHistoryEvent(track.id),
                        );
                        NotificationService.showTrackRemoved(
                          context,
                          trackName: track.displayName,
                        );
                      },
                      child: RecentTrackCard(
                        track: track,
                        onPlay: () => _onTrackPlay(context, track),
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _onTrackPlay(BuildContext context, TrackHistoryModel track) {
    NotificationService.showPlaybackMessage(
      context,
      trackName: track.displayName,
      modelName: track.modelDisplayName,
    );
  }



  void _showClearHistoryDialog(BuildContext context) async {
    final confirmed = await NotificationService.showClearHistoryConfirmation(context);
    if (confirmed == true && mounted) {
      context.read<HistoryBloc>().add(const ClearHistoryEvent());
      NotificationService.showHistoryCleared(context);
    }
  }
}

