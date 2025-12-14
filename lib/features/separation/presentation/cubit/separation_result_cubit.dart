import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../../constants/strings.dart';
import '../../../../core/services/audio_analysis_service.dart';
import '../../../../core/services/network_monitor_service.dart';
import '../../../../core/utils/validation_utils.dart';
import '../../data/models/separation_job_model.dart';
import '../../data/models/separated_track_config.dart';
import '../../data/separation_data/separated_tracks_data.dart';
import '../bloc/separation_bloc.dart';
import '../bloc/separation_event.dart';
import '../models/separated_track_item.dart';
import 'separation_result_state.dart';

class SeparationResultCubit extends Cubit<SeparationResultState> {
  final SeparationBloc _separationBloc;
  final Talker _talker = GetIt.instance<Talker>();
  final NetworkMonitorService _networkMonitor = NetworkMonitorService();
  final Set<String> _analyzingTracks = <String>{};
  final Set<String> _completedAnalysis = <String>{};
  final Set<String> _analysisRequested = <String>{};
  Timer? _analysisDebounceTimer;
  bool _disposed = false;

  SeparationResultCubit({
    required SeparationBloc separationBloc,
    SeparationJobModel? initialJob,
  })  : _separationBloc = separationBloc,
        super(SeparationResultState(job: initialJob));

  void initialize() {
    if (state.job != null) {
      _buildAndAnalyzeTracks();
    }
  }

  void updateJob(SeparationJobModel job, Map<String, AudioAnalysisResult> analysisResults) {
    final tracks = _buildTracksFromJob(job, analysisResults);
    emit(state.copyWith(
      job: job,
      tracks: tracks,
      analysisResults: analysisResults,
    ));
    
    _startAnalysisForNewTracks(tracks);
  }

  void _buildAndAnalyzeTracks() {
    if (state.job == null) return;
    
    final tracks = _buildTracksFromJob(state.job!, state.analysisResults);
    emit(state.copyWith(tracks: tracks));
    
    _startAnalysisForNewTracks(tracks);
  }

  List<SeparatedTrackItem> _buildTracksFromJob(
    SeparationJobModel job,
    Map<String, AudioAnalysisResult> analysisResults,
  ) {
    final availableTracks = <SeparatedTrackItem>[];
    
    for (final stem in job.stems) {
      final config = _findConfigForStem(stem.name);
      
      if (config != null) {
        String? finalUrl = stem.url.isNotEmpty ? stem.url : null;
        
        if (finalUrl != null) {
          finalUrl = _correctUrl(finalUrl);
        }
        
        final analysisResult = analysisResults[config.id];
        
        final track = SeparatedTrackItem(
          config: config,
          audioUrl: finalUrl,
          volume: 0.8,
          analysisResult: analysisResult,
          isAnalyzing: false,
        );
        
        availableTracks.add(track);
      }
    }
    
    return availableTracks;
  }

  String _correctUrl(String url) {
    String correctedUrl = url;
    
    if (correctedUrl.contains(':8001/')) {
      correctedUrl = correctedUrl.replaceAll(':8001/', ':8000/');
    }
    
    if (correctedUrl.contains('192.168.31.124:8000/work/') && 
        !correctedUrl.contains('/media/')) {
      correctedUrl = correctedUrl.replaceAll(
        '192.168.31.124:8000/work/', 
        '192.168.31.124:8000/media/work/',
      );
    }
    
    return correctedUrl;
  }

  void _startAnalysisForNewTracks(List<SeparatedTrackItem> tracks) {
    for (final track in tracks) {
      if (track.audioUrl != null && 
          track.analysisResult == null && 
          !_analysisRequested.contains(track.config.id) && 
          !_analyzingTracks.contains(track.config.id) && 
          !_completedAnalysis.contains(track.config.id)) {
        
        _requestAnalysis(track.config.id, track.audioUrl!);
      }
    }
  }

  void _requestAnalysis(String trackId, String audioUrl) {
    if (!ValidationUtils.isValidUrl(audioUrl)) {
      _talker.warning('Invalid URL for analysis: $audioUrl');
      return;
    }

    _analysisRequested.add(trackId);
    _analyzingTracks.add(trackId);
    
    _analysisDebounceTimer?.cancel();
    _analysisDebounceTimer = Timer(const Duration(milliseconds: 100), () {
      if (!_disposed) {
        try {
          _separationBloc.add(
            AnalyzeAudioEvent(trackId: trackId, audioUrl: audioUrl),
          );
        } catch (e) {
          _talker.error('Failed to start audio analysis: $e');
          _analyzingTracks.remove(trackId);
          _analysisRequested.remove(trackId);
        }
      } else {
        _analyzingTracks.remove(trackId);
        _analysisRequested.remove(trackId);
      }
    });
  }

  void onAnalysisCompleted(String trackId, AudioAnalysisResult result) {
    if (!_completedAnalysis.contains(trackId)) {
      _analyzingTracks.remove(trackId);
      _completedAnalysis.add(trackId);
      
      final updatedResults = Map<String, AudioAnalysisResult>.from(state.analysisResults);
      updatedResults[trackId] = result;
      
      final updatedTracks = state.tracks.map((track) {
        if (track.config.id == trackId) {
          return track.copyWith(analysisResult: result);
        }
        return track;
      }).toList();
      
      emit(state.copyWith(
        analysisResults: updatedResults,
        tracks: updatedTracks,
      ));
    }
  }

  SeparatedTrackConfig? _findConfigForStem(String stemName) {
    final normalizedStemName = stemName.toLowerCase().trim();
    
    for (final config in kSeparatedTracksData) {
      final configId = config.id.toLowerCase();
      
      if (normalizedStemName == configId) {
        return config;
      }
      
      switch (normalizedStemName) {
        case 'vocals':
          if (configId == 'vocals') return config;
          break;
        case 'accompaniment':
          if (configId == 'accompaniment') return config;
          break;
        case 'drums':
          if (configId == 'drums') return config;
          break;
        case 'bass':
          if (configId == 'bass') return config;
          break;
        case 'other':
          if (configId == 'other' || configId == 'piano') return config;
          break;
      }
    }
    
    return null;
  }

  Future<void> playTrack(SeparatedTrackItem track) async {
    if (!track.isPlayable || track.audioUrl == null) {
      emit(state.copyWith(error: 'Track not available for playback'));
      return;
    }

    if (!ValidationUtils.isValidUrl(track.audioUrl!)) {
      emit(state.copyWith(error: 'Invalid track URL'));
      return;
    }

    _talker.info('Checking network before playing track: ${track.config.id}');
    final networkOk = await _networkMonitor.checkNetworkForCriticalOperation();
    
    if (!networkOk) {
      emit(state.copyWith(
        error: AppStrings.networkRequiredForPlayback,
      ));
      return;
    }

    _separationBloc.add(PlayTrackEvent(
      trackId: track.config.id,
      trackUrl: track.audioUrl!,
      volume: track.volume,
    ));
  }

  void pauseTrack() {
    _separationBloc.add(const PauseTrackEvent());
  }

  void setVolume(String trackId, double volume) {
    if (!ValidationUtils.isValidVolume(volume)) {
      _talker.warning('Invalid volume value: $volume');
      return;
    }

    final normalized = volume.clamp(0.0, 1.0);
    _separationBloc.add(SetVolumeEvent(normalized));
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }

  Future<void> togglePlayback(SeparatedTrackItem track, bool isCurrentlyPlaying, String? activeTrackId) async {
    if (!track.isPlayable || track.audioUrl == null) {
      emit(state.copyWith(error: 'Track not available for playback'));
      return;
    }

    if (activeTrackId == track.config.id && isCurrentlyPlaying) {
      pauseTrack();
    } else {
      await playTrack(track);
    }
  }

  @override
  Future<void> close() {
    _disposed = true;
    _analysisDebounceTimer?.cancel();
    _analyzingTracks.clear();
    _completedAnalysis.clear();
    _analysisRequested.clear();
    return super.close();
  }
}