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
