import '../user_context.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // Timer
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart'; // today log 저장
import 'package:intl/intl.dart'; // 날짜 키 포맷
import 'package:mindbuddy/services/diary_summarizer.dart'; // 일기형 요약 서비스

import 'package:mindbuddy/services/prompt_manager.dart';
import 'voice_chat_page.dart';

// 🔽 서비스 파일들은 패키지 경로 + 별칭으로 고정
import 'package:mindbuddy/services/emotion_diary.dart';
import 'package:mindbuddy/services/emotion_summarizer.dart';
// (memory_store가 필요 없으면 빼도 됨)

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;


const kMint = Color(0xFF9BB7D4);
const kDeepText = Color.fromARGB(255, 29, 31, 62);
const kSoftBlue = Color.fromARGB(255, 81, 99, 172);

// ====== 기능 토글 플래그 ======
const bool kEnablePerMessageEmotionDiary = false; // 기존: 매 발화 감정일기 저장 (OFF 권장)
const bool kEnableDiarySummaryFab = true;        // 새 기능: 3회 이상 발화 시 FAB 대상

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
  final String userId = AppUser.id;
  late final PromptManager _promptManager;

  // ====== 오늘 로그/FAB 상태 ======
  late String _todayKey;       // 예: conv_yyyy-MM-dd (대화 원문)
  late String _todayDiaryKey;  // 예: diary_yyyy-MM-dd (요약문)
  int _userUtterCount = 0;     // 오늘 사용자 발화 수

  // --- FAB 자동 표시/숨김 제어 ---
  final ScrollController _scroll = ScrollController();
  bool _fabEligible = false;   // 3회 이상 발화 조건 충족 여부
  bool _fabVisible = false;    // 현재 보이는지 (3초간 true)
  Timer? _fabHideTimer;

  bool _summarizing = false;

  // ===== 로컬 파일 경로/IO =====
  Future<File> _todayLogFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/mindbuddy/conversations');
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return File('${folder.path}/$dateStr.json');
  }

  Future<List<String>> _loadTodayLogsFromDisk() async {
  // 🌐 웹에서는 파일 시스템 접근이 불가능하므로 그냥 SharedPreferences만 사용
  if (kIsWeb) return [];

  try {
    final file = await _todayLogFile();
    if (!await file.exists()) return [];
    final txt = await file.readAsString();
    final data = jsonDecode(txt);
    if (data is List) return data.cast<String>();
    return [];
  } catch (_) {
    return [];
  }
}

  Future<void> _saveTodayLogsToDisk(List<String> logs) async {
  if (kIsWeb) return; // 웹에서는 파일 저장 생략 (SharedPreferences만)
  try {
    final file = await _todayLogFile();
    await file.writeAsString(jsonEncode(logs), flush: true);
  } catch (e) {
    debugPrint('파일 저장 실패: $e');
  }
}

  @override
  void initState() {
    super.initState();
    _promptManager = PromptManager(userId);
    _tts.setLanguage("ko-KR");

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _todayKey = 'conv_$today';
    _todayDiaryKey = 'diary_$today';
    _restoreTodayState();

    // 스크롤 시 FAB 3초 재노출
    _scroll.addListener(() {
      if (_fabEligible) _showFabTemporarily();
    });
  }

  @override
  void dispose() {
    _fabHideTimer?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _restoreTodayState() async {
    final sp = await SharedPreferences.getInstance();

    // 1) SharedPreferences에서 카운트/로그 불러오기
    _userUtterCount = sp.getInt('count_$_todayKey') ?? 0;
    List<String> logs = sp.getStringList(_todayKey) ?? [];

    // 2) 디스크(JSON)에 있는 로그 병합
    final diskLogs = await _loadTodayLogsFromDisk();
    if (diskLogs.isNotEmpty) {
      final merged = <String>{...logs, ...diskLogs}.toList()..sort();
      logs = merged;
      await sp.setStringList(_todayKey, logs);
    }

    // 3) 3회 이상이면 FAB 대상
    _fabEligible = kEnableDiarySummaryFab && _userUtterCount >= 3;
    if (_fabEligible) _showFabTemporarily();

    setState(() {});
  }

  // ====== 오늘 로그 유틸 ======
  Future<void> _appendTodayLog({required String role, required String text}) async {
    final sp = await SharedPreferences.getInstance();
    final List<String> logs = sp.getStringList(_todayKey) ?? [];
    final timestamp = DateFormat('HH:mm').format(DateTime.now());
    logs.add('[$timestamp][$role] $text');
    await sp.setStringList(_todayKey, logs);
    await _saveTodayLogsToDisk(logs); // 디스크에도 동기 저장
  }

  Future<void> _incUserCountAndMaybeShowFab() async {
    final sp = await SharedPreferences.getInstance();
    _userUtterCount += 1;
    await sp.setInt('count_$_todayKey', _userUtterCount);

    if (!_fabEligible && kEnableDiarySummaryFab && _userUtterCount >= 3) {
      _fabEligible = true;            // 처음 3회 달성
      _showFabTemporarily();
    } else if (_fabEligible) {
      _showFabTemporarily();          // 이미 대상이면 갱신
    }
  }

  void _showFabTemporarily() {
    if (!_fabEligible) return;
    if (mounted) setState(() => _fabVisible = true);
    _fabHideTimer?.cancel();
    _fabHideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _fabVisible = false);
    });
  }

  // ===== FAB → 오늘 일기 요약 (다이얼로그 X, 캘린더 저장 O) =====
  Future<void> _onTapSummaryFab() async {
    setState(() => _summarizing = true);
    try {
      final sp = await SharedPreferences.getInstance();
      final logs = sp.getStringList(_todayKey) ?? [];
      if (logs.isEmpty) {
        _showSnack('저장할 대화가 없습니다.');
        return;
      }

      final allText = logs.join('\n');

      final diaryText = await DiarySummarizer.summarizeDiary(
        allConversationText: allText,
      );

      String emoji = '🗒️';
      try {
        final emo = await EmotionSummarizer.summarize(allText);
        if (emo.emoji.isNotEmpty) emoji = emo.emoji;
      } catch (_) {}

      final now = DateTime.now();
      await EmotionDiary.upsertLog(
        userId,
        EmotionLog(
          date: DateTime(now.year, now.month, now.day),
          emoji: emoji,
          summary: diaryText,
          source: allText,
        ),
      );

      await sp.setString(_todayDiaryKey, diaryText);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('오늘의 대화 요약이 캘린더에 저장됐어요.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      _showSnack('요약/저장 중 오류: $e');
    } finally {
      if (mounted) setState(() => _summarizing = false);
    }
  }

  /// 💬 GPT 대화 처리 (감정 + 프롬프트 + 응답)
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "content": text});
      _isLoading = true;
    });

    await _appendTodayLog(role: 'user', text: text);
    await _incUserCountAndMaybeShowFab();

    try {
      final systemPrompt = await _promptManager.updatePrompt(text, _messages);

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

      await _appendTodayLog(role: 'assistant', text: reply);

      if (kEnablePerMessageEmotionDiary) {
        try {
          final convo = _messages.take(50)
              .map((m) => "${m["role"]}: ${m["content"]}")
              .join("\n");

          final summary = await EmotionSummarizer.summarize(convo);
          final now = DateTime.now();

          await EmotionDiary.upsertLog(
            userId,
            EmotionLog(
              date: DateTime(now.year, now.month, now.day),
              emoji: summary.emoji,
              summary: summary.summary,
              source: convo,
            ),
          );
        } catch (e) {
          debugPrint("⚠️ 감정 일기 저장 실패: $e");
        }
      }

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

        for (final e in parsed) {
          final role = e["role"]?.toString() ?? "";
          final content = e["content"]?.toString() ?? "";
          if (role.isEmpty || content.isEmpty) continue;

          await _appendTodayLog(role: role, text: content);
          if (role == 'user') {
            await _incUserCountAndMaybeShowFab();
          }
        }
      } catch (e) {
        debugPrint("⚠️ 음성페이지 결과 파싱 에러: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasInput = _controller.text.trim().isNotEmpty;

    // 위치/스페이서 계산 (FAB가 메시지 가리지 않게)
    final keyboard = MediaQuery.of(context).viewInsets.bottom;
    const inputBarHeight = 72.0; // 하단 입력창(텍스트필드+여백) 대략 높이
    const fabHeight = 56.0;
    const fabGap = 16.0;
    final bottomOffset = (keyboard > 0) ? keyboard + fabGap : inputBarHeight + fabGap;

    return SafeArea(
      child: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 8),
              const Text(
                "MindBuddy 💬",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kDeepText,
                ),
              ),
              const Divider(),

              // 💬 메시지 목록
              Expanded(
                child: ListView.builder(
                  controller: _scroll, // 스크롤 감지
                  padding: const EdgeInsets.all(12),
                  // FAB가 보일 때만 스페이서 1칸 추가
                  itemCount: _messages.length + ((_fabEligible && _fabVisible) ? 1 : 0),
                  itemBuilder: (context, index) {
                    final isSpacer =
                        (_fabEligible && _fabVisible) && (index == _messages.length);
                    if (isSpacer) {
                      // FAB 높이 + 아래 오프셋만큼 여백을 넣어 메시지 가림 방지
                      return SizedBox(height: bottomOffset + fabHeight);
                    }

                    final msg = _messages[index];
                    final isUser = msg["role"] == "user";
                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 14,
                        ),
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
                        icon: const Icon(Icons.send_rounded, color: kSoftBlue),
                        onPressed: () => sendMessage(_controller.text),
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.mic_none_rounded, color: kSoftBlue),
                        onPressed: _openVoiceChat,
                      ),
                  ],
                ),
              ),
            ],
          ),

          // ===== 오늘의 대화 요약 FAB: 3초 뒤 자동 숨김 + 스크롤 시 3초 재등장 (채팅창 위 중앙) =====
          if (_fabEligible && _fabVisible)
            Positioned(
              left: 0,
              right: 0,
              bottom: bottomOffset, // 키보드/입력창 보정값
              child: Center(
                child: FloatingActionButton.extended(
                  onPressed: _summarizing ? null : _onTapSummaryFab,
                  icon: _summarizing
                      ? const SizedBox(
                          width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.auto_stories),
                  label: Text(_summarizing ? '요약 중...' : '오늘의 대화 요약'),
                  elevation: 4,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ✅ SnackBar 함수 (클래스 내부)
  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }
}
