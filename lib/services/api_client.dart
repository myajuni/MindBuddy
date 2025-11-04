// lib/services/api_client.dart 파일

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiClient {
  // ✅ FastAPI 서버 주소
  static const String baseUrl = "http://127.0.0.1:8000";

  // 🎯 1. 감정 분석 요청
  static Future<Map<String, dynamic>> analyzeEmotion(String text) async {
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
        return {
          'emotion': data['emotion'] ?? '중립',
          'score': data['score'] ?? 0.0,
        };
      } else {
        debugPrint("❌ Emotion API failed: ${response.statusCode}");
        // 🔹 오류 시에도 동일한 형태(Map)으로 반환
        return {'emotion': '오류', 'score': 0.0};
      }
    } catch (e) {
      debugPrint("⚠️ Emotion API exception: $e");
      // 🔹 예외 발생 시에도 Map 형태로 반환
      return {'emotion': '오류', 'score': 0.0};
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
