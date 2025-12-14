import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/track_history_model.dart';

abstract class HistoryLocalDataSource {
  Future<List<TrackHistoryModel>> getTrackHistory();
  Future<void> saveTrackToHistory(TrackHistoryModel track);
  Future<void> removeTrackFromHistory(String trackId);
  Future<void> clearHistory();
}

class HistoryLocalDataSourceImpl implements HistoryLocalDataSource {
  static const String _historyKey = 'track_history';
  static const int _maxHistoryItems = 50; // Максимум 50 треков в истории

  @override
  Future<List<TrackHistoryModel>> getTrackHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_historyKey) ?? [];
      
      final tracks = historyJson
          .map((jsonString) {
            try {
              final json = jsonDecode(jsonString) as Map<String, dynamic>;
              return TrackHistoryModel.fromJson(json);
            } catch (e) {
              // Пропускаем поврежденные записи
              return null;
            }
          })
          .where((track) => track != null)
          .cast<TrackHistoryModel>()
          .toList();

      // Сортируем по дате создания (новые сверху)
      tracks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return tracks;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveTrackToHistory(TrackHistoryModel track) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentHistory = await getTrackHistory();
      
      // Удаляем дубликаты (если трек с таким ID уже существует)
      final filteredHistory = currentHistory
          .where((existingTrack) => existingTrack.id != track.id)
          .toList();
      
      // Добавляем новый трек в начало
      filteredHistory.insert(0, track);
      
      // Ограничиваем количество записей
      final limitedHistory = filteredHistory.take(_maxHistoryItems).toList();
      
      // Сохраняем в SharedPreferences
      final historyJson = limitedHistory
          .map((track) => jsonEncode(track.toJson()))
          .toList();
      
      await prefs.setStringList(_historyKey, historyJson);
    } catch (e) {
      // Игнорируем ошибки сохранения
    }
  }

  @override
  Future<void> removeTrackFromHistory(String trackId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentHistory = await getTrackHistory();
      
      final filteredHistory = currentHistory
          .where((track) => track.id != trackId)
          .toList();
      
      final historyJson = filteredHistory
          .map((track) => jsonEncode(track.toJson()))
          .toList();
      
      await prefs.setStringList(_historyKey, historyJson);
    } catch (e) {
      // Игнорируем ошибки удаления
    }
  }

  @override
  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
    } catch (e) {
      // Игнорируем ошибки очистки
    }
  }
}