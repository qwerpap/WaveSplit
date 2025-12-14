import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AudioCacheService {
  static final Dio _dio = Dio();
  static Directory? _cacheDir;

  /// Инициализирует кэш директорию
  static Future<void> initialize() async {
    final appDir = await getApplicationDocumentsDirectory();
    _cacheDir = Directory('${appDir.path}/audio_cache');
    
    if (!await _cacheDir!.exists()) {
      await _cacheDir!.create(recursive: true);
    }
  }

  /// Получает локальный путь к кэшированному файлу или скачивает его
  static Future<String?> getCachedAudioPath(String url) async {
    try {
      if (_cacheDir == null) {
        await initialize();
      }

      // Создаем уникальное имя файла на основе URL
      final urlHash = md5.convert(utf8.encode(url)).toString();
      final fileName = '$urlHash.wav';
      final localFile = File('${_cacheDir!.path}/$fileName');

      // Если файл уже существует, возвращаем его путь
      if (await localFile.exists()) {
        return localFile.path;
      }

      // Скачиваем файл
      final response = await _dio.download(
        url,
        localFile.path,
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        return localFile.path;
      } else {
        return null;
      }
    } catch (e) {
      print('Error caching audio file: $e');
      return null;
    }
  }

  /// Очищает кэш
  static Future<void> clearCache() async {
    if (_cacheDir != null && await _cacheDir!.exists()) {
      await _cacheDir!.delete(recursive: true);
      await _cacheDir!.create(recursive: true);
    }
  }

  /// Получает размер кэша
  static Future<int> getCacheSize() async {
    if (_cacheDir == null || !await _cacheDir!.exists()) {
      return 0;
    }

    int totalSize = 0;
    await for (final entity in _cacheDir!.list(recursive: true)) {
      if (entity is File) {
        totalSize += await entity.length();
      }
    }
    return totalSize;
  }
}