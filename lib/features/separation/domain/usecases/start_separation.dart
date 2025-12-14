import '../repositories/separation_repository.dart';

class StartSeparation {
  final SeparationRepository repository;

  StartSeparation(this.repository);

  Future<String> call(String filePath, String model, {void Function(int sent, int total)? onSendProgress}) async {
    return await repository.startSeparation(filePath, model, onSendProgress: onSendProgress);
  }
}
