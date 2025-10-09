import 'package:mindbuddy/services/api_client.dart';
import 'package:mindbuddy/services/memory_store.dart';


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

  /// 실시간 프롬프트 업데이트
  Future<String> updatePrompt(
      String text, List<Map<String, String>> messages) async {
    final emotion = await ApiClient.analyzeEmotion(text);
    if (emotion.isEmpty) {
      return "You are MindBuddy, a CBT chatbot. Respond empathetically.";
    }
    // 나머지 프롬프트 구성 로직
    return "You are MindBuddy. The user feels $emotion. Respond warmly in Korean.";
  }

}
