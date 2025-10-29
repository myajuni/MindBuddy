// lib/services/diary_summarizer.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DiarySummarizer {
  /// 오늘 대화를 '일기 형식'으로 요약
  static Future<String> summarizeDiary({
    required String allConversationText,
    String locale = 'ko',
  }) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      return '요약 불가: OPENAI_API_KEY가 설정되지 않았습니다.';
    }

    // 너무 긴 텍스트 대비: 최대 12,000자 정도로 안전 컷
    final safeText = allConversationText.length > 12000
        ? allConversationText.substring(allConversationText.length - 12000)
        : allConversationText;

    final prompt = '''
다음은 오늘 사용자의 챗봇 대화 전체입니다.
핵심 사건(무엇을 했는지), 감정 변화, 성취/배운점, 내일의 다짐을 담아
자연스럽고 따뜻한 "하루 일기" 형식(3~6문장)으로 한국어로 요약해줘.

[대화 원문]
$safeText
''';

    final body = {
      "model": "gpt-4o-mini",
      "messages": [
        {"role": "system", "content": "너는 공감 능력이 뛰어난 한국어 일기 요약가야."},
        {"role": "user", "content": prompt}
      ],
      "temperature": 0.7,
    };

    final res = await http.post(
      Uri.parse("https://api.openai.com/v1/chat/completions"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey",
      },
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) {
      return '요약 중 오류가 발생했습니다: ${res.statusCode} ${res.body}';
    }

    final data = jsonDecode(res.body);
    final content = data["choices"]?[0]?["message"]?["content"]?.toString().trim();
    return (content == null || content.isEmpty) ? '요약 결과가 비어 있습니다.' : content;
  }
}
