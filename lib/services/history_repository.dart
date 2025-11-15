import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryRepository {
  static const _kOnboarded = 'onboarded';
  static const _kEssayHistory = 'essay_history_v1';
  static const _kInterviewHistory = 'interview_history_v1';

  Future<bool> getOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kOnboarded) ?? false;
  }

  Future<void> setOnboarded(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboarded, value);
  }

  Future<void> addEssayEntry({
    required String text,
    required String feedback,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kEssayHistory) ?? <String>[];
    final entry = {
      'timestamp': DateTime.now().toIso8601String(),
      'text': text,
      'feedback': feedback,
    };
    raw.insert(0, jsonEncode(entry));
    await prefs.setStringList(_kEssayHistory, raw.take(50).toList());
  }

  Future<List<Map<String, dynamic>>> loadEssayHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kEssayHistory) ?? <String>[];
    return raw.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  Future<void> addInterviewEntry({
    required String niche,
    required String mode,
    required List<Map<String, String>> qna,
    required String feedback,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kInterviewHistory) ?? <String>[];
    final entry = {
      'timestamp': DateTime.now().toIso8601String(),
      'niche': niche,
      'mode': mode,
      'qna': qna,
      'feedback': feedback,
    };
    raw.insert(0, jsonEncode(entry));
    await prefs.setStringList(_kInterviewHistory, raw.take(50).toList());
  }

  Future<List<Map<String, dynamic>>> loadInterviewHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kInterviewHistory) ?? <String>[];
    return raw.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }
}
