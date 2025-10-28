import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:characters/characters.dart';

/// GPT API를 이용해 대화 내용을 감정 이모지 + 한 줄 요약으로 생성
class EmotionSummarizer {
  static Future<({String emoji, String summary})> summarize(String conversation) async {
    final key = dotenv.env['OPENAI_API_KEY'] ?? '';
    if (key.isEmpty) {
      return (emoji: "😐", summary: "오늘은 무난한 하루였어요.");
    }

    final prompt = """
다음 한국어 대화를 1문장으로 '감정 중심' 요약해줘.
문장 맨 앞에 감정을 대표하는 이모지 1개만 포함해줘. (예: 😊, 😐, ☹️)
출력 형식: "😊 한 줄 요약..."
대화:
$conversation
""";

    try {
      final res = await http.post(
        Uri.parse("https://api.openai.com/v1/chat/completions"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $key",
        },
        body: jsonEncode({
          "model": "gpt-4o-mini",
          "messages": [
            {"role": "system", "content": "You are a concise Korean summarizer."},
            {"role": "user", "content": prompt},
          ],
          "temperature": 0.2,
        }),
      );

      if (res.statusCode != 200) {
        return (emoji: "😐", summary: "오늘은 무난한 하루였어요.");
      }

      final content = (jsonDecode(res.body)["choices"][0]["message"]["content"] as String?)?.trim() ?? "";
      final emoji = content.isNotEmpty ? content.characters.first : "😐";
      final summary = content
          .replaceFirst(emoji, "")
          .trim()
          .replaceFirst(RegExp(r'^[\s:·\-–—]+'), '')
          .trim();

      return (emoji: emoji, summary: summary.isEmpty ? "오늘은 무난한 하루였어요." : summary);
    } catch (_) {
      return (emoji: "😐", summary: "요약 생성 실패");
    }
  }
}

/// 🔧 클래스 인식 꼬임을 우회하기 위한 '탑레벨 래퍼 함수'
Future<({String emoji, String summary})> summarizeConversation(String conversation) =>
    EmotionSummarizer.summarize(conversation);
