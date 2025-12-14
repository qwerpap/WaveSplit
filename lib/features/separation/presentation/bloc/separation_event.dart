import 'package:equatable/equatable.dart';

abstract class SeparationEvent extends Equatable {
  const SeparationEvent();
  @override
  List<Object?> get props => [];
}

class StartSeparationEvent extends SeparationEvent {
  final String filePath;
  final String model;

  const StartSeparationEvent({required this.filePath, required this.model});

  @override
  List<Object?> get props => [filePath, model];
}

class PollStatusEvent extends SeparationEvent {
  final String jobId;
  const PollStatusEvent(this.jobId);

  @override
  List<Object?> get props => [jobId];
}

class PlayTrackEvent extends SeparationEvent {
  final String trackId;
  final String trackUrl;
  final double volume;

  const PlayTrackEvent({
    required this.trackId,
    required this.trackUrl,
    required this.volume,
  });

  @override
  List<Object?> get props => [trackId, trackUrl, volume];
}

class PauseTrackEvent extends SeparationEvent {
  const PauseTrackEvent();
}

class ResumeTrackEvent extends SeparationEvent {
  const ResumeTrackEvent();
}

class StopTrackEvent extends SeparationEvent {
  const StopTrackEvent();
}

class SeekTrackEvent extends SeparationEvent {
  final Duration position;

  const SeekTrackEvent(this.position);

  @override
  List<Object?> get props => [position];
}

class SetVolumeEvent extends SeparationEvent {
  final double volume;

  const SetVolumeEvent(this.volume);

  @override
  List<Object?> get props => [volume];
}

class AnalyzeAudioEvent extends SeparationEvent {
  final String trackId;
  final String audioUrl;

  const AnalyzeAudioEvent({
    required this.trackId,
    required this.audioUrl,
  });

  @override
  List<Object?> get props => [trackId, audioUrl];
}

class UpdatePositionEvent extends SeparationEvent {
  final Duration position;
  final Duration duration;

  const UpdatePositionEvent({
    required this.position,
    required this.duration,
  });

  @override
  List<Object?> get props => [position, duration];
}




