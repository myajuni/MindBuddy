// lib/services/emotion_diary.dart 파일

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EmotionLog {
  final DateTime date;
  final String emoji; // 😊 😐 ☹️ 등
  final String summary; // 한 줄 요약
  final String source; // 요약 근거 텍스트(옵션)

  EmotionLog({
    required this.date,
    required this.emoji,
    required this.summary,
    required this.source,
  });

  Map<String, dynamic> toJson() => {
        "date": date.toIso8601String(),
        "emoji": emoji,
        "summary": summary,
        "source": source,
      };

  static EmotionLog fromJson(Map<String, dynamic> j) => EmotionLog(
        date: DateTime.parse(j["date"] as String),
        emoji: j["emoji"] as String? ?? "😐",
        summary: j["summary"] as String? ?? "",
        source: j["source"] as String? ?? "",
      );
}

class EmotionDiary {
  static String _key(String userId) => "emotion_logs_$userId";

  static Future<List<EmotionLog>> getAllLogs(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(userId));
    if (raw == null) return [];
    final List list = jsonDecode(raw) as List;
    return list
        .map((e) => EmotionLog.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<void> upsertLog(String userId, EmotionLog log) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAllLogs(userId);

    bool sameDay(EmotionLog x) =>
        x.date.year == log.date.year &&
        x.date.month == log.date.month &&
        x.date.day == log.date.day;

    final filtered = all.where((e) => !sameDay(e)).toList();
    filtered.add(log);
    filtered.sort((a, b) => a.date.compareTo(b.date));

    prefs.setString(
      _key(userId),
      jsonEncode(filtered.map((e) => e.toJson()).toList()),
    );
  }

  static Future<List<EmotionLog>> getLogsForDay(
      String userId, DateTime day) async {
    final all = await getAllLogs(userId);
    return all
        .where((e) =>
            e.date.year == day.year &&
            e.date.month == day.month &&
            e.date.day == day.day)
        .toList();
  }
}
