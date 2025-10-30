import 'package:mindbuddy/services/api_client.dart';
import 'package:mindbuddy/services/memory_store.dart';
import 'package:mindbuddy/screens/chat_tab.dart';
import 'package:flutter/foundation.dart';

class PromptManager {
  final String userId;
  PromptManager(this.userId);

  /// 최초 프롬프트 설정
  Future<String> initializePrompt() async {
    final memory = await MemoryStore.load(userId);
    final base = """
너는 MindBuddy라는 감정 상담 챗봇이야.
사용자의 감정과 기억을 고려해 두 문장 이내로 답해야 해.
""";
    if (memory.traits.isNotEmpty) {
      return "$base\n[사용자 성향: ${memory.traits.join(", ")}]";
    }
    return base;
  }

  /// 실시간 프롬프트 업데이트 (이제 감정 결과를 함께 반환)
  Future<Map<String, dynamic>> updatePrompt(
      String text, List<Map<String, String>> messages) async {
    final emoRes = await ApiClient.analyzeEmotion(text);
    if (emoRes.isEmpty) {
      return {
        "prompt": "You are MindBuddy, a CBT chatbot. Respond empathetically.",
        "emotion": "중립",
        "score": 0.0,
      };
    }

    final emotion = emoRes['emotion'] ?? '중립';
    final score =
        (emoRes['score'] is num) ? (emoRes['score'] as num).toDouble() : 0.0;

    final prompt =
        "You are MindBuddy. The user feels $emotion. Respond warmly in Korean.";

    return {
      "prompt": prompt,
      "emotion": emotion,
      "score": score,
    };
  }
}
