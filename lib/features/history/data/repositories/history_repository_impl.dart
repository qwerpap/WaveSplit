import '../../../separation/data/models/separation_job_model.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_local_datasource.dart';
import '../models/track_history_model.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryLocalDataSource localDataSource;

  const HistoryRepositoryImpl({required this.localDataSource});

  @override
  Future<List<TrackHistoryModel>> getTrackHistory() async {
    return await localDataSource.getTrackHistory();
  }

  @override
  Future<void> saveCompletedSeparation(
    SeparationJobModel job,
    String originalFileName,
    String model,
  ) async {
    final historyItem = TrackHistoryModel(
      id: job.id,
      fileName: originalFileName,
      originalPath: '', // Не сохраняем путь к оригинальному файлу
      createdAt: DateTime.now(),
      model: model,
      stemsCount: job.stems.length,
      stemNames: job.stems.map((stem) => stem.name).toList(),
    );

    await localDataSource.saveTrackToHistory(historyItem);
  }

  @override
  Future<void> removeTrackFromHistory(String trackId) async {
    await localDataSource.removeTrackFromHistory(trackId);
  }

  @override
  Future<void> clearHistory() async {
    await localDataSource.clearHistory();
  }
}