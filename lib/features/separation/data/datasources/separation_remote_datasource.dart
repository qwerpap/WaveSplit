import 'dart:io';

import 'package:dio/dio.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:wave_split/constants/api_constants.dart';

import '../models/separation_job_model.dart';

class SeparationRemoteDataSource {
  final Dio dio;
  final Talker talker;

  SeparationRemoteDataSource({required this.dio, required this.talker});

  Future<String> uploadFile(String filePath, String model, {void Function(int, int)? onSendProgress}) async {
    final fileName = filePath.split(Platform.pathSeparator).last;
    final formData = FormData.fromMap({
      'model': model,
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    talker.info('Upload start | file=$fileName | model=$model');

    final response = await dio.post('${ApiConstants.baseUrl}/api/separate/',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
        onSendProgress: onSendProgress);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data as Map<String, dynamic>;
      talker.info('Upload success | jobId=${data['job_id']} | status=${response.statusCode}');
      return data['job_id'] as String;
    } else {
      talker.warning('Upload failed | status=${response.statusCode}');
      throw Exception('Upload failed: ${response.statusCode}');
    }
  }

  Future<SeparationJobModel> getStatus(String jobId) async {
    final response = await dio.get('${ApiConstants.baseUrl}/api/separate/$jobId/status/');
    if (response.statusCode == 200) {
      final result = SeparationJobModel.fromJson(response.data as Map<String, dynamic>);
      talker.debug('Status polled | jobId=$jobId | status=${result.status} | progress=${result.progress}');
      return result;
    } else {
      talker.warning('Status request failed | jobId=$jobId | status=${response.statusCode}');
      throw Exception('Status request failed: ${response.statusCode}');
    }
  }

  Future<String?> getResultUrl(String jobId) async {
    final response = await dio.get('${ApiConstants.baseUrl}/api/separate/$jobId/status/');
    if (response.statusCode == 200) {
      final json = response.data as Map<String, dynamic>;
      talker.info('Result url fetched | jobId=$jobId | hasUrl=${json['result_url'] != null}');
      return json['result_url'] as String?;
    } else {
      talker.warning('Result request failed | jobId=$jobId | status=${response.statusCode}');
      throw Exception('Result request failed: ${response.statusCode}');
    }
  }
}


