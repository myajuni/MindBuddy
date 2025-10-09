import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiClient {
  // ✅ FastAPI 서버 주소
  static const String baseUrl = "http://127.0.0.1:8000";

  // 🎯 1. 감정 분석 요청
  static Future<String> analyzeEmotion(String text) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/log/"), // FastAPI의 /log 엔드포인트
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": "user1",
          "text": text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("✅ Emotion API response: $data");
        return data['emotion'] ?? "중립";
      } else {
        debugPrint("❌ Emotion API failed: ${response.statusCode}");
        return "오류";
      }
    } catch (e) {
      debugPrint("⚠️ Emotion API exception: $e");
      return "오류";
    }
  }

  // 🧠 2. 프롬프트 생성 요청
  static Future<Map<String, dynamic>> buildPrompt(
    String userId,
    String text,
    List<Map<String, String>> history,
    String emotion,
  ) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/prompt"), // FastAPI의 /prompt 엔드포인트
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "last_user_text": text,
          "history": history,
          "last_emotion": emotion,
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        debugPrint("✅ Prompt API response: $data");
        return data;
      } else {
        debugPrint("❌ Prompt API failed: ${res.statusCode}");
        throw Exception("Prompt API failed");
      }
    } catch (e) {
      debugPrint("⚠️ Prompt API exception: $e");
      rethrow;
    }
  }
}
