import 'package:equatable/equatable.dart';

import '../../data/models/separated_track_config.dart';
import '../../../../core/services/audio_analysis_service.dart';

class SeparatedTrackItem extends Equatable {
  final SeparatedTrackConfig config;
  final String? audioUrl;
  final double volume;
  final bool isPlaying;
  final AudioAnalysisResult? analysisResult;
  final bool isAnalyzing;

  const SeparatedTrackItem({
    required this.config,
    this.audioUrl,
    this.volume = 1.0,
    this.isPlaying = false,
    this.analysisResult,
    this.isAnalyzing = false,
  });

  bool get isPlayable {
    if (audioUrl == null || audioUrl!.isEmpty) return false;
    
    // Если анализ показал тишину с высокой уверенностью, трек не воспроизводим
    if (analysisResult != null && 
        analysisResult!.isSilent && 
        analysisResult!.isReliable) {
      return false;
    }
    
    return true;
  }

  bool get isSilent => analysisResult?.isSilent == true;
  bool get hasSilentWarning => analysisResult?.isSilent == true && analysisResult!.isReliable;

  SeparatedTrackItem copyWith({
    SeparatedTrackConfig? config,
    String? audioUrl,
    double? volume,
    bool? isPlaying,
    AudioAnalysisResult? analysisResult,
    bool? isAnalyzing,
  }) {
    return SeparatedTrackItem(
      config: config ?? this.config,
      audioUrl: audioUrl ?? this.audioUrl,
      volume: volume ?? this.volume,
      isPlaying: isPlaying ?? this.isPlaying,
      analysisResult: analysisResult ?? this.analysisResult,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
    );
  }

  @override
  List<Object?> get props => [config, audioUrl, volume, isPlaying, analysisResult, isAnalyzing];
}

