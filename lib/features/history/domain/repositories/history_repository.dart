import '../../../separation/data/models/separation_job_model.dart';
import '../../data/models/track_history_model.dart';

abstract class HistoryRepository {
  Future<List<TrackHistoryModel>> getTrackHistory();
  Future<void> saveCompletedSeparation(SeparationJobModel job, String originalFileName, String model);
  Future<void> removeTrackFromHistory(String trackId);
  Future<void> clearHistory();
}