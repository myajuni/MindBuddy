import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/emotion_store.dart';
import 'package:intl/date_symbol_data_local.dart';

/// 주간 감정 분포 카드 (EmotionStore 기반 자동 업데이트)
class WeeklyTrendCard extends StatelessWidget {
  final String? comparisonText;
  final DateTime? selectedDate;

  const WeeklyTrendCard({
    super.key,
    this.comparisonText,
    this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('ko_KR', null);

    // ✅ 1️⃣ 주간 감정 데이터 계산
    final weeklyData =
        _computeWeeklyEmotionRatios(EmotionStore.instance.history);

    // ✅ 2️⃣ 여기에 아래 줄을 추가하세요
    final selectedWeekday = selectedDate != null
        ? DateFormat('E', 'ko_KR').format(selectedDate!)
        : null;

    final emotions = ["분노", "기쁨", "평온", "슬픔", "당황", "불안"];
    final colors = {
      "기쁨": Colors.yellowAccent,
      "슬픔": Colors.lightBlueAccent,
      "불안": Colors.deepPurpleAccent,
      "분노": Colors.redAccent,
      "평온": Colors.greenAccent,
      "당황": Colors.blueAccent,
    };

    final order = ["월", "화", "수", "목", "금", "토", "일"]; // ✅ 순서 고정

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "📊 주간 감정 분포",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  maxY: 1,
                  alignment: BarChartAlignment.spaceAround,
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
                        getTitlesWidget: (x, _) {
                          final order = ["월", "화", "수", "목", "금", "토", "일"];
                          return Text(
                            order[x.toInt()],
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: _buildBarGroups(weeklyData, emotions, colors,
                      highlightDay: selectedWeekday),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildLegend(colors),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.chat_bubble_outline,
                    color: Colors.grey, size: 16),
                const SizedBox(width: 4),
                Text(
                  comparisonText ?? "아직 기록이 없습니다.",
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🧮 최근 7일 감정 로그를 감정별 비율로 요약
  Map<String, Map<String, double>> _computeWeeklyEmotionRatios(
      List<Map<String, dynamic>> history) {
    final now = DateTime.now();
    final formatter = DateFormat('E', 'ko_KR'); // 월~일

    // 최근 7일만 필터링
    final recent = history.where((h) {
      final dateStr = h['date']?.toString();
      if (dateStr == null || dateStr.isEmpty) return false;
      final date = DateTime.tryParse(dateStr);
      if (date == null) return false; // ✅ 파싱 실패 시 제외
      return !date.isBefore(now.subtract(const Duration(days: 6)));
    }).toList();

    // 요일별 감정 카운트 누적
    final Map<String, Map<String, int>> count = {};
    for (final log in recent) {
      final dateStr = log['date']?.toString();
      final date = DateTime.tryParse(dateStr ?? '');
      if (date == null) continue;
      final weekday = formatter.format(date); // 월, 화, 수 ...
      final emo = log['emotion'] ?? "평온";

      count.putIfAbsent(weekday, () => {});
      count[weekday]![emo] = (count[weekday]![emo] ?? 0) + 1;
    }

    // 비율 계산
    final Map<String, Map<String, double>> ratios = {};
    for (final day in count.keys) {
      final total = count[day]!.values.fold<int>(0, (a, b) => a + b);
      ratios[day] =
          count[day]!.map((emo, v) => MapEntry(emo, v / total.toDouble()));
    }

    // 월~일 순서 정렬
    final order = ["월", "화", "수", "목", "금", "토", "일"];
    return {for (var d in order) d: ratios[d] ?? {}};
  }

  /// 🟦 감정별 색상 범례
  Widget _buildLegend(Map<String, Color> colors) {
    return Wrap(
      spacing: 8,
      children: colors.entries.map((e) {
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

  /// 🧱 BarGroup 생성 (요일별 감정 누적)
  List<BarChartGroupData> _buildBarGroups(
    Map<String, Map<String, double>> data,
    List<String> emotions,
    Map<String, Color> colors, {
    String? highlightDay,
  }) {
    int i = 0;
    return data.entries.map((entry) {
      double cumulative = 0;
      final stackItems = <BarChartRodStackItem>[];

      for (final emo in emotions) {
        final val = entry.value[emo] ?? 0;
        stackItems.add(
          BarChartRodStackItem(cumulative, cumulative + val, colors[emo]!),
        );
        cumulative += val;
      }

      return BarChartGroupData(
        x: i++,
        barRods: [
          BarChartRodData(
            toY: 1,
            rodStackItems: stackItems,
            width: 22,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }
}
