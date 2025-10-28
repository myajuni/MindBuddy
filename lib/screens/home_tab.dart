import '../user_context.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../main.dart';
// import '../services/memory_store.dart';
import '../services/emotion_diary.dart';   // ← 상대경로가 제일 튼튼함

/// ---------------------- 홈 탭 ----------------------
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});
  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final String userId = AppUser.id; // 필요 시 실제 로그인 ID로 대체
  DateTime _focused = DateTime.now();
  DateTime? _selected;
  List<EmotionLog> _logs = <EmotionLog>[];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final list = await EmotionDiary.getAllLogs(userId);
    setState(() => _logs = list);
  }

  List<EmotionLog> _logsForDay(DateTime day) {
    return _logs.where((e) =>
      e.date.year == day.year &&
      e.date.month == day.month &&
      e.date.day == day.day
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final sel = _selected ?? DateTime.now();
    final dayLogs = _logsForDay(sel);
    final summaryText = dayLogs.isNotEmpty ? dayLogs.first.summary : "이 날의 기록이 없습니다.";

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // 📅 달력
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2027, 12, 31),
            focusedDay: _focused,
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (d) => _selected != null && isSameDay(_selected, d),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selected = selectedDay;
                _focused = focusedDay;
              });
            },
            calendarBuilders: CalendarBuilders(
              // 날짜 셀 중앙에 이모지 표시
              markerBuilder: (context, date, events) {
                final logs = _logsForDay(date);
                if (logs.isEmpty) return const SizedBox.shrink();
                return Center(
                  child: Text(logs.first.emoji, style: const TextStyle(fontSize: 18)),
                );
              },
            ),
            headerStyle: HeaderStyle( // const 빼서 안전
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),

          const SizedBox(height: 16),

          // 📝 선택일 요약 카드
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0,3))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.calendar_month, color: kMint),
                const SizedBox(width: 8),
                Text(
                  DateFormat('M월 d일의 기록').format(sel),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: kDeepText),
                ),
              ]),
              const SizedBox(height: 8),
              Text(summaryText, style: const TextStyle(fontSize: 14)),
            ]),
          ),

          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _loadLogs,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text("갱신"),
            ),
          ),
        ]),
      ),
    );
  }
}

/// ---------------------- 새 기록 페이지 (+ 버튼) ----------------------
class NewLogPage extends StatefulWidget {
  const NewLogPage({super.key});
  @override
  State<NewLogPage> createState() => _NewLogPageState();
}

class _NewLogPageState extends State<NewLogPage> {
  final _controller = TextEditingController();
  String _mood = '🙂 차분함';
  final moods = const ['🙂 차분함', '😌 편안함', '😕 불안함', '😢 슬픔', '😡 화남', '🤩 설렘'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kHomeBg,
      appBar: AppBar(
        backgroundColor: kHomeBg,
        elevation: 0,
        title: const Text('새 기록',
            style: TextStyle(color: kDeepText, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: kDeepText),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('오늘의 감정',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: moods.map((m) {
                final selected = _mood == m;
                return ChoiceChip(
                  label: Text(m),
                  selected: selected,
                  onSelected: (_) => setState(() => _mood = m),
                  selectedColor: kMint,
                  labelStyle:
                      TextStyle(color: selected ? Colors.white : kDeepText),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFE0E0E0)),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text('내용',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 3))
                  ],
                ),
                padding: const EdgeInsets.all(14),
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  expands: true,
                  decoration: const InputDecoration(
                    hintText: '오늘 있었던 일과 감정을 자유롭게 적어보세요…',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kMint,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                label: const Text('저장하기',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$_mood 로 저장했어요!')),
                  );
                  Navigator.pop(context);
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
