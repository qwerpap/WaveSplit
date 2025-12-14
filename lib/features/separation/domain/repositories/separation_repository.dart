import 'package:wave_split/features/separation/data/models/separation_job_model.dart';

abstract class SeparationRepository {
  /// Starts separation, returns job id.
  Future<String> startSeparation(String filePath, String model, {void Function(int sent, int total)? onSendProgress});

  /// Get status for job.
  Future<SeparationJobModel> getStatus(String jobId);

  /// Get result download url (if available).
  Future<String?> getResultUrl(String jobId);
}

