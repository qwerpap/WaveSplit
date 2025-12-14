import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:wave_split/features/separation/domain/repositories/separation_repository.dart';
import 'package:wave_split/core/services/audio_cache_service.dart';
import 'package:wave_split/core/services/audio_analysis_service.dart';
import 'package:wave_split/features/history/domain/repositories/history_repository.dart';

import 'separation_event.dart';
import 'separation_state.dart';

class SeparationBloc extends Bloc<SeparationEvent, SeparationState> {
  final SeparationRepository repository;
  final HistoryRepository historyRepository;
  final Talker _talker = GetIt.instance<Talker>();
  String? _currentFileName;
  String? _currentModel;
  Timer? _pollTimer;
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;

  SeparationBloc({
    required this.repository,
    required this.historyRepository,
  }) : super(const SeparationInitial()) {
    on<StartSeparationEvent>(_onStart);
    on<PollStatusEvent>(_onPollStatus);
    on<AnalyzeAudioEvent>(_onAnalyzeAudio);
    on<PlayTrackEvent>(_onPlayTrack);
    on<PauseTrackEvent>(_onPauseTrack);
    on<ResumeTrackEvent>(_onResumeTrack);
    on<StopTrackEvent>(_onStopTrack);
    on<SeekTrackEvent>(_onSeekTrack);
    on<SetVolumeEvent>(_onSetVolume);
    on<UpdatePositionEvent>(_onUpdatePosition);

    _playerStateSubscription = _player.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed) {
        add(const StopTrackEvent());
      }
    });

    // Отслеживаем позицию воспроизведения
    _positionSubscription = _player.onPositionChanged.listen((position) {
      add(UpdatePositionEvent(position: position, duration: state.totalDuration));
    });

    // Отслеживаем длительность трека
    _durationSubscription = _player.onDurationChanged.listen((duration) {
      add(UpdatePositionEvent(position: state.currentPosition, duration: duration));
    });
  }

  Future<void> _onStart(StartSeparationEvent event, Emitter<SeparationState> emit) async {
    try {
      _talker.info('Starting separation | file=${event.filePath} | model=${event.model}');
      
      // Сохраняем информацию о файле для истории
      _currentFileName = event.filePath.split('/').last;
      _currentModel = event.model;
      
      emit(const SeparationUploading(0.0));
      final jobId = await repository.startSeparation(event.filePath, event.model);
      _talker.info('Separation started | jobId=$jobId');
      emit(SeparationProcessing(jobId: jobId, progress: 0.0));

      // start polling
      _pollTimer?.cancel();
      _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
        add(PollStatusEvent(jobId));
      });
    } catch (e) {
      _talker.error('Separation start failed: $e');
      emit(SeparationFailure(e.toString()));
    }
  }

  Future<void> _onPollStatus(PollStatusEvent event, Emitter<SeparationState> emit) async {
    try {
      final job = await repository.getStatus(event.jobId);
      if (job.status == 'finished' || job.status == 'completed' || job.progress >= 0.999) {
        _pollTimer?.cancel();
        _talker.info('Separation completed | jobId=${job.id} | stems=${job.stems.length}');
        
        _talker.info('Separation completed | stems: ${job.stems.map((s) => s.name).join(', ')}');
        
        if (job.stems.isNotEmpty) {
          // Сохраняем в историю
          if (_currentFileName != null && _currentModel != null) {
            try {
              await historyRepository.saveCompletedSeparation(
                job,
                _currentFileName!,
                _currentModel!,
              );
              _talker.info('Separation saved to history');
            } catch (e) {
              _talker.warning('Failed to save to history: $e');
            }
          }
          
          emit(SeparationCompleted(job: job));
        } else {
          _talker.warning('No stems found in completed job');
          emit(const SeparationFailure('No stems found in result'));
        }
      } else {
        emit(SeparationProcessing(jobId: job.id, progress: job.progress));
      }
    } catch (e) {
      _pollTimer?.cancel();
      _talker.error('Status polling failed: $e');
      emit(SeparationFailure(e.toString()));
    }
  }

  Future<void> _onPlayTrack(PlayTrackEvent event, Emitter<SeparationState> emit) async {
    try {
      _talker.info('Playing track | trackId=${event.trackId} | url=${event.trackUrl}');
      
      // Проверяем URL перед воспроизведением
      if (!event.trackUrl.startsWith('http')) {
        throw Exception('Invalid URL format: ${event.trackUrl}');
      }
      
      await _player.stop();
      await _player.setVolume(event.volume);
      
      _talker.info('Caching audio file for iOS compatibility: ${event.trackUrl}');
      
      // Кэшируем файл локально для iOS
      final cachedPath = await AudioCacheService.getCachedAudioPath(event.trackUrl);
      
      if (cachedPath != null) {
        _talker.info('Playing cached file: $cachedPath');
        await _player.play(DeviceFileSource(cachedPath));
      } else {
        _talker.warning('Failed to cache file, trying direct URL');
        await _player.play(UrlSource(event.trackUrl));
      }
      
      emit(state.copyWith(
        activeTrackId: event.trackId, 
        isPlaying: true,
        volume: event.volume,
      ));
      
      _talker.info('Track playback started successfully');
    } catch (e) {
      _talker.error('Playback failed for URL ${event.trackUrl}: $e');
      
      // Более детальная информация об ошибке
      String errorMessage = 'Audio playback failed';
      if (e.toString().contains('DarwinAudioError')) {
        errorMessage = 'iOS Audio Error: Try using cached playback or check audio format';
      } else if (e.toString().contains('PlatformException')) {
        errorMessage = 'Platform Error: ${e.toString()}';
      } else if (e.toString().contains('Failed to set source')) {
        errorMessage = 'Audio Source Error: Unable to load audio from URL or cache';
      }
      
      emit(SeparationFailure('$errorMessage\n\nURL: ${event.trackUrl}\n\nTip: Audio file will be cached locally for better iOS compatibility'));
    }
  }

  Future<void> _onPauseTrack(PauseTrackEvent event, Emitter<SeparationState> emit) async {
    await _player.pause();
    emit(state.copyWith(isPlaying: false));
  }

  Future<void> _onResumeTrack(ResumeTrackEvent event, Emitter<SeparationState> emit) async {
    await _player.resume();
    emit(state.copyWith(isPlaying: true));
  }

  Future<void> _onStopTrack(StopTrackEvent event, Emitter<SeparationState> emit) async {
    await _player.stop();
    emit(state.copyWith(activeTrackId: null, isPlaying: false));
  }

  Future<void> _onSeekTrack(SeekTrackEvent event, Emitter<SeparationState> emit) async {
    await _player.seek(event.position);
    // Не обновляем state, так как position больше не отслеживается
  }

  Future<void> _onSetVolume(SetVolumeEvent event, Emitter<SeparationState> emit) async {
    await _player.setVolume(event.volume);
    emit(state.copyWith(volume: event.volume));
  }

  Future<void> _onAnalyzeAudio(AnalyzeAudioEvent event, Emitter<SeparationState> emit) async {
    try {
      _talker.info('Analyzing audio | trackId=${event.trackId} | url=${event.audioUrl}');
      
      final analysisResult = await AudioAnalysisService.analyzeAudioFile(event.audioUrl);
      
      _talker.info('Audio analysis completed | trackId=${event.trackId} | result=$analysisResult');
      
      // Обновляем состояние с результатами анализа только если это SeparationCompleted
      if (state is SeparationCompleted) {
        final currentState = state as SeparationCompleted;
        
        // Проверяем, что результат еще не добавлен (избегаем дублирования)
        if (!currentState.analysisResults.containsKey(event.trackId)) {
          final updatedResults = Map<String, AudioAnalysisResult>.from(currentState.analysisResults);
          updatedResults[event.trackId] = analysisResult;
          
          emit(currentState.copyWith(analysisResults: updatedResults));
        } else {
          _talker.warning('Analysis result for ${event.trackId} already exists, skipping update');
        }
      } else {
        _talker.warning('Attempted to analyze audio but state is not SeparationCompleted: ${state.runtimeType}');
      }
    } catch (e) {
      _talker.error('Audio analysis failed | trackId=${event.trackId}: $e');
      // Не эмитим ошибку, просто логируем - анализ не критичен для работы приложения
    }
  }

  Future<void> _onUpdatePosition(UpdatePositionEvent event, Emitter<SeparationState> emit) async {
    emit(state.copyWith(
      currentPosition: event.position,
      totalDuration: event.duration,
    ));
  }



  @override
  Future<void> close() {
    _pollTimer?.cancel();
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _player.dispose();
    return super.close();
  }
}


