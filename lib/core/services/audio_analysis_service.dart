import 'dart:typed_data';
import 'package:dio/dio.dart';

class AudioAnalysisService {
  static final Dio _dio = Dio();

  /// Анализирует аудиофайл на предмет тишины
  static Future<AudioAnalysisResult> analyzeAudioFile(String url) async {
    try {
      // print('🔍 Starting audio analysis for: $url');
      
      // Скачиваем небольшую часть файла для анализа (первые 64KB)
      final response = await _dio.get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Range': 'bytes=0-65535'}, // Первые 64KB
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      // print('📥 Downloaded ${response.data?.length ?? 0} bytes, status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 206) {
        final bytes = response.data as Uint8List;
        final result = _analyzeWavBytes(bytes);
        // print('📊 Analysis result: $result');
        return result;
      } else {
        // print('❌ Download failed with status: ${response.statusCode}');
        return AudioAnalysisResult(
          isSilent: false,
          confidence: 0.0,
          error: 'Failed to download audio data',
        );
      }
    } catch (e) {
      // print('💥 Analysis error: $e');
      return AudioAnalysisResult(
        isSilent: false,
        confidence: 0.0,
        error: 'Analysis failed: ${e.toString()}',
      );
    }
  }

  /// Анализирует байты WAV файла
  static AudioAnalysisResult _analyzeWavBytes(Uint8List bytes) {
    try {
      // Простой анализ WAV файла
      // WAV заголовок обычно 44 байта, данные начинаются после
      if (bytes.length < 100) {
        return AudioAnalysisResult(
          isSilent: true,
          confidence: 1.0,
          error: null,
        );
      }

      // Пропускаем WAV заголовок и анализируем аудиоданные
      final audioDataStart = _findAudioDataStart(bytes);
      if (audioDataStart == -1 || audioDataStart >= bytes.length - 100) {
        return AudioAnalysisResult(
          isSilent: true,
          confidence: 0.8,
          error: null,
        );
      }

      // Анализируем амплитуду аудиосигнала
      final analysisResult = _analyzeAmplitude(bytes, audioDataStart);
      
      return analysisResult;
    } catch (e) {
      return AudioAnalysisResult(
        isSilent: false,
        confidence: 0.0,
        error: 'Byte analysis failed: ${e.toString()}',
      );
    }
  }

  /// Находит начало аудиоданных в WAV файле
  static int _findAudioDataStart(Uint8List bytes) {
    // Ищем "data" chunk в WAV файле
    for (int i = 0; i < bytes.length - 8; i++) {
      if (bytes[i] == 0x64 && // 'd'
          bytes[i + 1] == 0x61 && // 'a'
          bytes[i + 2] == 0x74 && // 't'
          bytes[i + 3] == 0x61) { // 'a'
        // Найден "data" chunk, данные начинаются через 8 байт
        return i + 8;
      }
    }
    
    // Если не найден, предполагаем стандартный заголовок 44 байта
    return 44;
  }

  /// Анализирует амплитуду аудиосигнала
  static AudioAnalysisResult _analyzeAmplitude(Uint8List bytes, int start) {
    int samplesAnalyzed = 0;
    int significantSamples = 0;
    double maxAmplitude = 0.0;
    double totalAmplitude = 0.0;

    // Анализируем каждый второй байт как 16-bit аудио
    for (int i = start; i < bytes.length - 1; i += 2) {
      if (samplesAnalyzed >= 1000) break; // Ограничиваем анализ

      // Читаем 16-bit sample (little endian)
      int sample = bytes[i] | (bytes[i + 1] << 8);
      
      // Конвертируем в signed 16-bit
      if (sample > 32767) sample -= 65536;
      
      double amplitude = sample.abs() / 32768.0;
      totalAmplitude += amplitude;
      
      if (amplitude > maxAmplitude) {
        maxAmplitude = amplitude;
      }
      
      // Считаем значимые сэмплы (амплитуда > 1% от максимума)
      if (amplitude > 0.01) {
        significantSamples++;
      }
      
      samplesAnalyzed++;
    }

    if (samplesAnalyzed == 0) {
      return AudioAnalysisResult(
        isSilent: true,
        confidence: 1.0,
        error: null,
      );
    }

    double averageAmplitude = totalAmplitude / samplesAnalyzed;
    double significantRatio = significantSamples / samplesAnalyzed;

    // Определяем тишину на основе нескольких критериев
    bool isSilent = false;
    double confidence = 0.0;

    if (maxAmplitude < 0.005) {
      // Максимальная амплитуда очень низкая
      isSilent = true;
      confidence = 0.95;
    } else if (averageAmplitude < 0.001) {
      // Средняя амплитуда очень низкая
      isSilent = true;
      confidence = 0.90;
    } else if (significantRatio < 0.05) {
      // Менее 5% значимых сэмплов
      isSilent = true;
      confidence = 0.85;
    } else if (maxAmplitude < 0.02 && averageAmplitude < 0.005) {
      // Комбинация низких показателей
      isSilent = true;
      confidence = 0.75;
    }

    return AudioAnalysisResult(
      isSilent: isSilent,
      confidence: confidence,
      error: null,
      maxAmplitude: maxAmplitude,
      averageAmplitude: averageAmplitude,
      significantSamplesRatio: significantRatio,
    );
  }
}

class AudioAnalysisResult {
  final bool isSilent;
  final double confidence;
  final String? error;
  final double? maxAmplitude;
  final double? averageAmplitude;
  final double? significantSamplesRatio;

  AudioAnalysisResult({
    required this.isSilent,
    required this.confidence,
    this.error,
    this.maxAmplitude,
    this.averageAmplitude,
    this.significantSamplesRatio,
  });

  bool get isReliable => confidence > 0.7;
  
  String get description {
    if (error != null) return 'Analysis failed';
    if (isSilent && isReliable) return 'Silent track detected';
    if (isSilent) return 'Possibly silent track';
    return 'Active audio detected';
  }

  @override
  String toString() {
    return 'AudioAnalysis(silent: $isSilent, confidence: ${(confidence * 100).toInt()}%, '
           'maxAmp: ${maxAmplitude?.toStringAsFixed(3)}, '
           'avgAmp: ${averageAmplitude?.toStringAsFixed(3)})';
  }
}