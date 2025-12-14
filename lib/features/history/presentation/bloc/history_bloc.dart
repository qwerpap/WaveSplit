import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../domain/repositories/history_repository.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final HistoryRepository repository;
  final Talker _talker = GetIt.instance<Talker>();

  HistoryBloc({required this.repository}) : super(const HistoryInitial()) {
    on<LoadHistoryEvent>(_onLoadHistory);
    on<RefreshHistoryEvent>(_onRefreshHistory);
    on<RemoveTrackFromHistoryEvent>(_onRemoveTrack);
    on<ClearHistoryEvent>(_onClearHistory);
  }

  Future<void> _onLoadHistory(LoadHistoryEvent event, Emitter<HistoryState> emit) async {
    if (state is! HistoryLoaded) {
      emit(const HistoryLoading());
    }

    try {
      _talker.info('Loading track history');
      final tracks = await repository.getTrackHistory();
      _talker.info('Loaded ${tracks.length} tracks from history');
      emit(HistoryLoaded(tracks));
    } catch (e) {
      _talker.error('Failed to load history: $e');
      emit(HistoryError(e.toString()));
    }
  }

  Future<void> _onRefreshHistory(RefreshHistoryEvent event, Emitter<HistoryState> emit) async {
    try {
      _talker.info('Refreshing track history');
      final tracks = await repository.getTrackHistory();
      _talker.info('Refreshed ${tracks.length} tracks from history');
      emit(HistoryLoaded(tracks));
    } catch (e) {
      _talker.error('Failed to refresh history: $e');
      emit(HistoryError(e.toString()));
    }
  }

  Future<void> _onRemoveTrack(RemoveTrackFromHistoryEvent event, Emitter<HistoryState> emit) async {
    try {
      _talker.info('Removing track from history: ${event.trackId}');
      await repository.removeTrackFromHistory(event.trackId);
      
      // Обновляем состояние
      if (state is HistoryLoaded) {
        final currentTracks = (state as HistoryLoaded).tracks;
        final updatedTracks = currentTracks
            .where((track) => track.id != event.trackId)
            .toList();
        emit(HistoryLoaded(updatedTracks));
      }
      
      _talker.info('Track removed from history successfully');
    } catch (e) {
      _talker.error('Failed to remove track from history: $e');
      emit(HistoryError(e.toString()));
    }
  }

  Future<void> _onClearHistory(ClearHistoryEvent event, Emitter<HistoryState> emit) async {
    try {
      _talker.info('Clearing all history');
      await repository.clearHistory();
      emit(const HistoryLoaded([]));
      _talker.info('History cleared successfully');
    } catch (e) {
      _talker.error('Failed to clear history: $e');
      emit(HistoryError(e.toString()));
    }
  }
}