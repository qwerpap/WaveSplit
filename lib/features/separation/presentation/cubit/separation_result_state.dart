import 'package:equatable/equatable.dart';

import '../../../../core/services/audio_analysis_service.dart';
import '../../data/models/separation_job_model.dart';
import '../models/separated_track_item.dart';

class SeparationResultState extends Equatable {
  final SeparationJobModel? job;
  final List<SeparatedTrackItem> tracks;
  final Map<String, AudioAnalysisResult> analysisResults;
  final String? error;

  const SeparationResultState({
    this.job,
    this.tracks = const [],
    this.analysisResults = const {},
    this.error,
  });

  SeparationResultState copyWith({
    SeparationJobModel? job,
    List<SeparatedTrackItem>? tracks,
    Map<String, AudioAnalysisResult>? analysisResults,
    String? error,
  }) {
    return SeparationResultState(
      job: job ?? this.job,
      tracks: tracks ?? this.tracks,
      analysisResults: analysisResults ?? this.analysisResults,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        job,
        tracks,
        analysisResults,
        error,
      ];
}