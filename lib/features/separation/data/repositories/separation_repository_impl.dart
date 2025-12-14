import 'package:wave_split/features/separation/data/datasources/separation_remote_datasource.dart';
import 'package:wave_split/features/separation/data/models/separation_job_model.dart';
import 'package:wave_split/features/separation/domain/repositories/separation_repository.dart';

class SeparationRepositoryImpl implements SeparationRepository {
  final SeparationRemoteDataSource remote;

  SeparationRepositoryImpl({required this.remote});

  @override
  Future<String> startSeparation(String filePath, String model, {void Function(int, int)? onSendProgress}) {
    return remote.uploadFile(filePath, model, onSendProgress: onSendProgress);
  }

  @override
  Future<SeparationJobModel> getStatus(String jobId) {
    return remote.getStatus(jobId);
  }

  @override
  Future<String?> getResultUrl(String jobId) {
    return remote.getResultUrl(jobId);
  }
}


