/// Утилиты для валидации данных
class ValidationUtils {
  ValidationUtils._();

  /// Проверяет валидность URL
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Проверяет, не пустая ли строка
  static bool isNotEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  /// Проверяет валидность пути к файлу
  static bool isValidFilePath(String? filePath) {
    if (!isNotEmpty(filePath)) return false;
    
    try {
      // Базовая проверка на наличие недопустимых символов
      final invalidChars = ['<', '>', ':', '"', '|', '?', '*'];
      for (final char in invalidChars) {
        if (filePath!.contains(char)) return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Проверяет валидность ID задачи
  static bool isValidJobId(String? jobId) {
    if (!isNotEmpty(jobId)) return false;
    
    // ID должен содержать только буквы, цифры, дефисы и подчеркивания
    final regex = RegExp(r'^[a-zA-Z0-9_-]+$');
    return regex.hasMatch(jobId!);
  }

  /// Проверяет валидность значения громкости (0.0 - 1.0)
  static bool isValidVolume(double? volume) {
    return volume != null && volume >= 0.0 && volume <= 1.0;
  }

  /// Проверяет валидность прогресса (0.0 - 1.0)
  static bool isValidProgress(double? progress) {
    return progress != null && progress >= 0.0 && progress <= 1.0;
  }
}