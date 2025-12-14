import 'package:equatable/equatable.dart';

import '../../data/models/separation_job_model.dart';
import '../../../../core/services/audio_analysis_service.dart';

abstract class SeparationState extends Equatable {
  final String? activeTrackId;
  final bool isPlaying;
  final double volume;
  final Map<String, AudioAnalysisResult> analysisResults;
  final Duration currentPosition;
  final Duration totalDuration;

  const SeparationState({
    this.activeTrackId,
    this.isPlaying = false,
    this.volume = 0.8,
    this.analysisResults = const {},
    this.currentPosition = Duration.zero,
    this.totalDuration = Duration.zero,
  });

  SeparationState copyWith({
    String? activeTrackId,
    bool? isPlaying,
    double? volume,
    Map<String, AudioAnalysisResult>? analysisResults,
    Duration? currentPosition,
    Duration? totalDuration,
  });

  @override
  List<Object?> get props => [activeTrackId, isPlaying, volume, analysisResults, currentPosition, totalDuration];
}

class SeparationInitial extends SeparationState {
  const SeparationInitial();

  @override
  SeparationInitial copyWith({
    String? activeTrackId,
    bool? isPlaying,
    double? volume,
    Map<String, AudioAnalysisResult>? analysisResults,
    Duration? currentPosition,
    Duration? totalDuration,
  }) {
    return const SeparationInitial();
  }
}

class SeparationUploading extends SeparationState {
  final double progress;

  const SeparationUploading(this.progress);

  @override
  List<Object?> get props => [progress];

  @override
  SeparationUploading copyWith({
    String? activeTrackId,
    bool? isPlaying,
    double? volume,
    Map<String, AudioAnalysisResult>? analysisResults,
    Duration? currentPosition,
    Duration? totalDuration,
  }) {
    return SeparationUploading(progress);
  }
}

class SeparationProcessing extends SeparationState {
  final String jobId;
  final double progress;

  const SeparationProcessing({required this.jobId, required this.progress});

  @override
  List<Object?> get props => [jobId, progress];

  @override
  SeparationProcessing copyWith({
    String? activeTrackId,
    bool? isPlaying,
    double? volume,
    Map<String, AudioAnalysisResult>? analysisResults,
    Duration? currentPosition,
    Duration? totalDuration,
  }) {
    return SeparationProcessing(jobId: jobId, progress: progress);
  }
}

class SeparationCompleted extends SeparationState {
  final SeparationJobModel job;

  const SeparationCompleted({
    required this.job,
    super.activeTrackId,
    super.isPlaying,
    super.volume,
    super.analysisResults,
    super.currentPosition,
    super.totalDuration,
  });

  @override
  List<Object?> get props => [
        job,
        activeTrackId,
        isPlaying,
        volume,
        analysisResults,
        currentPosition,
        totalDuration,
      ];

  @override
  SeparationCompleted copyWith({
    String? activeTrackId,
    bool? isPlaying,
    double? volume,
    Map<String, AudioAnalysisResult>? analysisResults,
    Duration? currentPosition,
    Duration? totalDuration,
  }) {
    return SeparationCompleted(
      job: job,
      activeTrackId: activeTrackId ?? this.activeTrackId,
      isPlaying: isPlaying ?? this.isPlaying,
      volume: volume ?? this.volume,
      analysisResults: analysisResults ?? this.analysisResults,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
    );
  }
}

class SeparationFailure extends SeparationState {
  final String message;

  const SeparationFailure(this.message);

  @override
  List<Object?> get props => [message];

  @override
  SeparationFailure copyWith({
    String? activeTrackId,
    bool? isPlaying,
    double? volume,
    Map<String, AudioAnalysisResult>? analysisResults,
    Duration? currentPosition,
    Duration? totalDuration,
  }) {
    return SeparationFailure(message);
  }
}




