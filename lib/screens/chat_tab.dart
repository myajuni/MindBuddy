import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/prompt_manager.dart';
import 'voice_chat_page.dart';

const kMint = Color(0xFF73C8B6);
const kDeepText = Color(0xFF2E4C58);

class ChatTab extends StatefulWidget {
  const ChatTab({super.key});

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final FlutterTts _tts = FlutterTts();
  bool _isLoading = false;

  // ✅ 사용자 ID는 나중에 로그인 연동 시 변경 가능
  final String userId = "user001";
  late final PromptManager _promptManager;

  @override
  void initState() {
    super.initState();
    _promptManager = PromptManager(userId);
    _tts.setLanguage("ko-KR");
  }

  /// 💬 GPT 대화 처리 (감정 + 프롬프트 + 응답)
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "content": text});
      _isLoading = true;
    });

    try {
      // ✅ 1️⃣ 감정 분석 + 프롬프트 생성
      final systemPrompt = await _promptManager.updatePrompt(text, _messages);
      debugPrint("🧠 프롬프트 생성 완료");

      // ✅ 2️⃣ GPT 응답 요청
      final gptRes = await http.post(
        Uri.parse("https://api.openai.com/v1/chat/completions"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${dotenv.env['OPENAI_API_KEY']}",
        },
        body: jsonEncode({
          "model": "gpt-4o-mini",
          "messages": [
            {"role": "system", "content": systemPrompt},
            ..._messages.map((m) => {
                  "role": m["role"],
                  "content": m["content"],
                }),
          ],
        }),
      );

      if (gptRes.statusCode != 200) {
        throw Exception("GPT API error ${gptRes.statusCode}");
      }

      final data = jsonDecode(gptRes.body);
      final reply = data['choices'][0]['message']['content'] ?? "응답 없음";

      setState(() {
        _messages.add({"role": "assistant", "content": reply});
      });

      // ✅ 3️⃣ 음성으로 읽기
      await _tts.speak(reply);
    } catch (e) {
      debugPrint("❌ Error: $e");
      setState(() {
        _messages.add({"role": "assistant", "content": "서버 오류 또는 네트워크 문제: $e"});
      });
    }

    setState(() => _isLoading = false);
    _controller.clear();
  }

  /// 🎙️ 음성 인터페이스 페이지 열기
  Future<void> _openVoiceChat() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const VoiceChatPage()),
    );

    if (result != null) {
      try {
        final List<Map<String, dynamic>> parsed =
            List<Map<String, dynamic>>.from(result);
        setState(() {
          _messages.addAll(parsed.map((e) => {
                "role": e["role"]?.toString() ?? "",
                "content": e["content"]?.toString() ?? "",
              }));
        });
      } catch (e) {
        debugPrint("⚠️ 음성페이지 결과 파싱 에러: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasInput = _controller.text.trim().isNotEmpty;

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 8),
          const Text("MindBuddy 💬",
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: kDeepText)),
          const Divider(),

          // 💬 메시지 목록
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg["role"] == "user";
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 14),
                    decoration: BoxDecoration(
                      color: isUser ? kMint : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      msg["content"] ?? "",
                      style: TextStyle(
                        color: isUser ? Colors.white : kDeepText,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(color: kMint),
            ),

          // 📝 하단 입력창
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: "MindBuddy에게 이야기해보세요...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                      ),
                    ),
                    onSubmitted: sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                if (hasInput)
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: kMint),
                    onPressed: () => sendMessage(_controller.text),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.mic_none_rounded, color: kMint),
                    onPressed: _openVoiceChat,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
