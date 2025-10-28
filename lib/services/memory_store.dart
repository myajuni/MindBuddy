import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MemoryStore {
  final List<String> traits;
  final List<Map<String, String>> episodic;

  MemoryStore({required this.traits, required this.episodic});

  static Future<MemoryStore> load(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString("memory_$userId");
    if (raw == null) return MemoryStore(traits: [], episodic: []);
    final data = jsonDecode(raw);
    return MemoryStore(
      traits: List<String>.from(data["traits"]),
      episodic: List<Map<String, String>>.from(data["episodic"]),
    );
  }

  static Future<void> saveEmotion(String userId, String emotion) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("last_emotion_$userId", emotion);
  }

  static Future<void> update(String userId, MemoryStore newMemory) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        "memory_$userId",
        jsonEncode({
          "traits": newMemory.traits,
          "episodic": newMemory.episodic,
        }));
  }
}

// ========= 감정 일기(날짜별 요약) =========
class EmotionLog {
  final DateTime date;
  final String emoji;   // 😊 😐 ☹️ 등
  final String summary; // 한 줄 요약
  final String source;  // 요약의 근거가 된 대화 텍스트(옵션)

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

extension EmotionDiary on MemoryStore {
  static String _key(String userId) => "emotion_logs_$userId";

  /// 전체 로그 불러오기
  static Future<List<EmotionLog>> getAllLogs(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(userId));
    if (raw == null) return [];
    final List list = (jsonDecode(raw) as List);
    return list.map((e) => EmotionLog.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  /// 하루에 1개만 관리(마지막 기록으로 덮어쓰기) – 원하면 append 로 바꿔도 됨
  static Future<void> upsertLog(String userId, EmotionLog log) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAllLogs(userId);
    final sameDay = (EmotionLog x) =>
        x.date.year == log.date.year &&
        x.date.month == log.date.month &&
        x.date.day == log.date.day;

    final filtered = all.where((e) => !sameDay(e)).toList();
    filtered.add(log);
    filtered.sort((a, b) => a.date.compareTo(b.date));

    prefs.setString(_key(userId), jsonEncode(filtered.map((e) => e.toJson()).toList()));
  }

  static Future<List<EmotionLog>> getLogsForDay(String userId, DateTime day) async {
    final all = await getAllLogs(userId);
    return all.where((e) =>
      e.date.year == day.year && e.date.month == day.month && e.date.day == day.day
    ).toList();
  }
}
