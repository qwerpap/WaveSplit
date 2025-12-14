import 'package:equatable/equatable.dart';

class TrackHistoryModel extends Equatable {
  final String id;
  final String fileName;
  final String originalPath;
  final DateTime createdAt;
  final String model; // 'two_stems' or 'four_stems'
  final int stemsCount;
  final List<String> stemNames;
  final String? thumbnailPath;

  const TrackHistoryModel({
    required this.id,
    required this.fileName,
    required this.originalPath,
    required this.createdAt,
    required this.model,
    required this.stemsCount,
    required this.stemNames,
    this.thumbnailPath,
  });

  factory TrackHistoryModel.fromJson(Map<String, dynamic> json) {
    return TrackHistoryModel(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      originalPath: json['originalPath'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      model: json['model'] as String,
      stemsCount: json['stemsCount'] as int,
      stemNames: List<String>.from(json['stemNames'] as List),
      thumbnailPath: json['thumbnailPath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'originalPath': originalPath,
      'createdAt': createdAt.toIso8601String(),
      'model': model,
      'stemsCount': stemsCount,
      'stemNames': stemNames,
      'thumbnailPath': thumbnailPath,
    };
  }

  String get displayName {
    // Убираем расширение файла для отображения
    final name = fileName.split('.').first;
    return name.length > 20 ? '${name.substring(0, 20)}...' : name;
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else {
      return '${(difference.inDays / 7).floor()} week${(difference.inDays / 7).floor() > 1 ? 's' : ''} ago';
    }
  }

  String get modelDisplayName {
    return model == 'two_stems' ? '2 stems' : '4 stems';
  }

  @override
  List<Object?> get props => [
        id,
        fileName,
        originalPath,
        createdAt,
        model,
        stemsCount,
        stemNames,
        thumbnailPath,
      ];
}