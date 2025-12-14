import 'dart:io';
import 'package:dio/dio.dart';
import 'package:wave_split/constants/api_constants.dart';

class NetworkTestService {
  static final Dio _dio = Dio();

  /// Тестирует подключение к API
  static Future<NetworkTestResult> testApiConnection() async {
    try {
      // Тест основного API - используем простой GET запрос для проверки доступности
      final response = await _dio.get(
        '${ApiConstants.baseUrl}/api/separate/',
        options: Options(
          headers: {'Origin': 'http://localhost:3000'},
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          validateStatus: (status) => status != null && status < 500, // Принимаем любой статус кроме 5xx
        ),
      );

      if (response.statusCode != null && response.statusCode! < 500) {
        // Любой статус кроме 5xx означает, что сервер доступен
        return NetworkTestResult(
          success: true,
          message: 'API server is accessible (status: ${response.statusCode})',
          baseUrl: ApiConstants.baseUrl,
        );
      } else {
        return NetworkTestResult(
          success: false,
          message: 'API server error: ${response.statusCode}',
          baseUrl: ApiConstants.baseUrl,
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Network error';
      
      if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout - check if backend is running';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Receive timeout - slow network connection';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Connection error - check network and backend URL';
      } else {
        errorMessage = 'Network error: ${e.message}';
      }

      return NetworkTestResult(
        success: false,
        message: errorMessage,
        baseUrl: ApiConstants.baseUrl,
        error: e.toString(),
      );
    } catch (e) {
      return NetworkTestResult(
        success: false,
        message: 'Unexpected error: ${e.toString()}',
        baseUrl: ApiConstants.baseUrl,
        error: e.toString(),
      );
    }
  }

  /// Тестирует доступность медиа файла
  static Future<MediaTestResult> testMediaUrl(String url) async {
    try {
      final response = await _dio.head(
        url,
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      if (response.statusCode == 200) {
        final contentType = response.headers.value('content-type') ?? 'unknown';
        final contentLength = response.headers.value('content-length') ?? 'unknown';
        
        return MediaTestResult(
          success: true,
          message: 'Media file accessible',
          url: url,
          contentType: contentType,
          contentLength: contentLength,
        );
      } else {
        return MediaTestResult(
          success: false,
          message: 'Media file returned status: ${response.statusCode}',
          url: url,
        );
      }
    } on DioException catch (e) {
      return MediaTestResult(
        success: false,
        message: 'Media access error: ${e.message}',
        url: url,
        error: e.toString(),
      );
    } catch (e) {
      return MediaTestResult(
        success: false,
        message: 'Unexpected media error: ${e.toString()}',
        url: url,
        error: e.toString(),
      );
    }
  }

  /// Получает информацию о платформе для диагностики
  static String getPlatformInfo() {
    if (Platform.isIOS) {
      return 'iOS Simulator/Device';
    } else if (Platform.isAndroid) {
      return 'Android Emulator/Device';
    } else if (Platform.isMacOS) {
      return 'macOS Desktop';
    } else if (Platform.isWindows) {
      return 'Windows Desktop';
    } else if (Platform.isLinux) {
      return 'Linux Desktop';
    } else {
      return 'Unknown Platform';
    }
  }
}

class NetworkTestResult {
  final bool success;
  final String message;
  final String baseUrl;
  final String? error;

  NetworkTestResult({
    required this.success,
    required this.message,
    required this.baseUrl,
    this.error,
  });

  @override
  String toString() {
    return 'NetworkTest(success: $success, message: $message, baseUrl: $baseUrl)';
  }
}

class MediaTestResult {
  final bool success;
  final String message;
  final String url;
  final String? contentType;
  final String? contentLength;
  final String? error;

  MediaTestResult({
    required this.success,
    required this.message,
    required this.url,
    this.contentType,
    this.contentLength,
    this.error,
  });

  @override
  String toString() {
    return 'MediaTest(success: $success, message: $message, url: $url, type: $contentType)';
  }
}
