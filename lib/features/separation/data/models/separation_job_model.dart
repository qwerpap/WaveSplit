import 'package:equatable/equatable.dart';

import 'separation_stem_model.dart';

class SeparationJobModel extends Equatable {
  final String id;
  final String status;
  final double progress;
  final String? resultUrl;
  final List<SeparationStemModel> stems;
  final String? originalFileName;

  const SeparationJobModel({
    required this.id,
    required this.status,
    required this.progress,
    this.resultUrl,
    this.stems = const [],
    this.originalFileName,
  });

  factory SeparationJobModel.fromJson(Map<String, dynamic> json) {
    final stemsJson = json['stems'];
    return SeparationJobModel(
      id: json['job_id'] as String,
      status: json['status'] as String? ?? 'unknown',
      progress: (json['progress'] is num) ? (json['progress'] as num).toDouble() : 0.0,
      resultUrl: json['result_url'] as String?,
      stems: (stemsJson is List)
          ? stemsJson
              .whereType<Map<String, dynamic>>()
              .map(SeparationStemModel.fromJson)
              .toList()
          : const [],
      originalFileName: json['original_filename'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, status, progress, resultUrl, stems, originalFileName];
}


