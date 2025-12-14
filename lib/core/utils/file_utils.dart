import 'dart:io';

/// Утилиты для работы с файлами
class FileUtils {
  FileUtils._();

  /// Извлекает имя файла из пути
  static String getFileName(String filePath) {
    return filePath.split('/').last;
  }

  /// Извлекает расширение файла
  static String getFileExtension(String filePath) {
    final fileName = getFileName(filePath);
    final lastDotIndex = fileName.lastIndexOf('.');
    if (lastDotIndex == -1) return '';
    return fileName.substring(lastDotIndex + 1).toLowerCase();
  }

  /// Проверяет, является ли файл аудио файлом
  static bool isAudioFile(String filePath) {
    const audioExtensions = ['mp3', 'wav', 'flac', 'm4a', 'aac', 'ogg', 'wma'];
    final extension = getFileExtension(filePath);
    return audioExtensions.contains(extension);
  }

  /// Форматирует размер файла в читаемый формат
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Проверяет существование файла
  static Future<bool> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Получает размер файла
  static Future<int?> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}