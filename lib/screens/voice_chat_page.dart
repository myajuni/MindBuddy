// lib/screens/voice_chat_page.dart 파일

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/prompt_manager.dart';
import '../widgets/emotion_overlay.dart';
import 'package:mindbuddy/services/emotion_store.dart';
import 'package:mindbuddy/services/danger_words.dart';

const kMint = Color.fromARGB(255, 119, 161, 206);
const kDeepText = Color.fromARGB(255, 29, 31, 62);
const kSoftBlue = Color.fromARGB(255, 81, 99, 172);
const kBg = Color(0xFFF8FAFC);

class VoiceChatPage extends StatefulWidget {
  const VoiceChatPage({super.key});

  @override
  State<VoiceChatPage> createState() => _VoiceChatPageState();
}

class _VoiceChatPageState extends State<VoiceChatPage> {
  late stt.SpeechToText _speech;
  final FlutterTts _tts = FlutterTts();

  bool _isListening = false;
  bool _isProcessing = false;
  final List<Map<String, String>> _messages = [];

  // ✅ 추가된 부분
  late final PromptManager _promptManager;
  final String _userId = "user001";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _tts.setLanguage("ko-KR");
    _tts.setSpeechRate(0.48);
    _tts.setPitch(1.0);

    _promptManager = PromptManager(_userId); // ✅ 프롬프트 매니저 초기화
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize();
    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("음성 인식 불가: 권한을 확인해주세요.")),
      );
      return;
    }

    setState(() => _isListening = true);
    _speech.listen(
      onResult: (result) {
        if (result.finalResult && result.recognizedWords.isNotEmpty) {
          _speech.stop();
          _sendToGPT(result.recognizedWords);
        }
      },
      listenMode: stt.ListenMode.confirmation,
      localeId: "ko_KR",
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  /// 🧠 GPT 요청 및 응답 표시 (ChatTab과 동일한 로직)
  Future<void> _sendToGPT(String userText) async {
    setState(() {
      _isProcessing = true;
      _isListening = false;
      _messages.add({"role": "user", "content": userText});
    });

    // 🔥 자살방지
    if (containsDangerWord(userText)) {
      final msg = "⚠️ 지금 많이 힘드신 것 같아요.\n\n"
          "혼자 감당하시지 않아도 괜찮아요.\n"
          "지금 즉시 도움을 받을 수 있는 번호입니다.\n\n"
          "📞 24시간 자살예방 상담전화 1393\n"
          "📞 정신건강 위기 상담 1577-0199\n\n"
          "지금 바로 연락해보세요.";

      setState(() {
        _messages.add({"role": "assistant", "content": msg});
        _isProcessing = false;
      });

      await _tts.speak("지금 매우 힘들어 보이네요. 24시간 자살 예방 상담 전화 1393에 연락해보세요.");
      return; // ⛔ GPT 호출하지 않고 즉시 종료
    }

    try {
      // ✅ 1️⃣ 감정 분석 + 프롬프트 생성
      final res = await _promptManager.updatePrompt(userText, _messages);
      final systemPrompt = res["prompt"];
      debugPrint("🧠 프롬프트 생성 완료");

      // 감정 결과 사용 (ChatTab과 동일)
      EmotionStore.instance.update(
        res["emotion"] ?? "중립",
        (res["score"] is num) ? (res["score"] as num).toDouble() : 0.0,
      );

      // ✅ 2️⃣ GPT 응답 요청
      final response = await http.post(
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'] ?? "응답이 비어있어요.";
        setState(() {
          _messages.add({"role": "assistant", "content": reply});
          _isProcessing = false;
        });
        await _tts.speak(reply);
      } else {
        setState(() {
          _messages.add({
            "role": "assistant",
            "content": "서버 오류 (${response.statusCode})",
          });
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({"role": "assistant", "content": "네트워크 오류: $e"});
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _messages);
        return false;
      },
      child: Scaffold(
        backgroundColor: kBg,
        appBar: AppBar(
          backgroundColor: kBg,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: kDeepText),
            onPressed: () => Navigator.pop(context, _messages),
          ),
          title: const Text(
            "음성 대화 모드",
            style: TextStyle(color: kDeepText, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              // 기존 UI 전체를 Column으로 감쌈
              Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        final isUser = msg["role"] == "user";
                        return Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isUser ? kMint : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              msg["content"] ?? "",
                              style: TextStyle(
                                color: isUser ? Colors.white : kDeepText,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  if (_isProcessing)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: CircularProgressIndicator(color: kMint),
                    ),

                  // 🎙️ 마이크 버튼
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: GestureDetector(
                      onTap: () {
                        if (_isListening) {
                          _stopListening();
                        } else {
                          _startListening();
                        }
                      },
                      child: Container(
                        height: 90,
                        width: 90,
                        decoration: BoxDecoration(
                          color: _isListening ? Colors.redAccent : kSoftBlue,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // === 🧠 감정 플로팅 위젯 추가 부분 ===
              EmotionOverlay(
                currentEmotion: EmotionStore.instance.emotion,
                currentScore: EmotionStore.instance.score,
                emotionHistory: EmotionStore.instance.history,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
