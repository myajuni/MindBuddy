import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mindbuddy/services/emotion_store.dart';
import '../widgets/emotion_overlay.dart' show emotionColors;

/// EmotionRatioPie 와 동일하게 동작하는 주간 감정 막대 그래프
class WeeklyEmotionBar extends StatelessWidget {
  final DateTime selectedDate;
  static const emotionOrder = ["분노", "기쁨", "평온", "슬픔", "당황", "불안"];

  const WeeklyEmotionBar({
    super.key,
    required this.selectedDate,
  });

  /// 월~일 날짜 리스트
  List<DateTime> _weekDays(DateTime day) {
    final monday = day.subtract(Duration(days: day.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  /// 특정 날짜의 감정 카운트 계산 (EmotionRatioPie 방식 그대로)
  Map<String, int> _countForDay(DateTime day) {
    final history = EmotionStore.instance.history;
    final m = <String, int>{};

    for (final item in history) {
      // 날짜 파싱
      final date = DateTime.tryParse(item['date'] ?? '');
      if (date == null) continue;

      // 날짜 같은지 비교
      if (date.year == day.year &&
          date.month == day.month &&
          date.day == day.day) {
        final emo = item['emotion'] ?? '평온'; // 감정명
        m[emo] = (m[emo] ?? 0) + 1;
      }
    }

    return m;
  }

  @override
  Widget build(BuildContext context) {
    const weekdays = ["월", "화", "수", "목", "금", "토", "일"];
    final week = _weekDays(selectedDate);

    // 선택된 날짜가 주간에서 몇 번째인지 계산
    final selectedIndex = week.indexWhere((d) =>
        d.year == selectedDate.year &&
        d.month == selectedDate.month &&
        d.day == selectedDate.day);

    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "📊 주간 감정 변화",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  maxY: 1,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (x, _) => Text(weekdays[x.toInt()],
                            style: const TextStyle(fontSize: 12)),
                      ),
                    ),
                  ),
                  barGroups: _buildBarGroups(week, selectedIndex),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  /// 요일별 stacked bar 생성
  List<BarChartGroupData> _buildBarGroups(
      List<DateTime> days, int selectedIndex) {
    int xIndex = 0;

    return days.map((day) {
      final map = _countForDay(day);
      final total = map.values.fold<int>(0, (a, b) => a + b);
      double cumulative = 0;

      // Stacked bar items
      // 1) 감정 순서에 맞게 정렬
      final sortedEntries = map.entries.toList()
        ..sort((a, b) =>
            emotionOrder.indexOf(a.key).compareTo(emotionOrder.indexOf(b.key)));

      // 2) 정렬된 순서대로 stacked bar 만들기
      final items = sortedEntries.map((entry) {
        final emo = entry.key;
        final count = entry.value;
        final ratio = (total == 0) ? 0.0 : count / total;

        final item = BarChartRodStackItem(
          cumulative,
          cumulative + ratio,
          emotionColors[emo] ?? Colors.grey,
        );

        cumulative += ratio;
        return item;
      }).toList();

      final group = BarChartGroupData(
        x: xIndex,
        barRods: [
          BarChartRodData(
            toY: 1,
            rodStackItems: items,
            width: 22,
            borderRadius: BorderRadius.circular(4),
            color:
                xIndex == selectedIndex ? Colors.black.withOpacity(0.15) : null,
          ),
        ],
      );

      xIndex++;
      return group;
    }).toList();
  }

  /// 색상 범례
  Widget _buildLegend() {
    return Wrap(
      spacing: 12,
      children: emotionColors.entries.map((e) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: e.value,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 4),
            Text(e.key, style: const TextStyle(fontSize: 12)),
          ],
        );
      }).toList(),
    );
  }
}
