// lib/widgets/emotion_overlay.dart 파일

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// 감정별 색상 및 이모지
final Map<String, Color> emotionColors = {
  "기쁨": Colors.yellowAccent,
  "슬픔": Colors.lightBlueAccent,
  "불안": Colors.deepPurpleAccent,
  "분노": Colors.redAccent,
  "평온": Colors.greenAccent,
  "당황": Colors.blueAccent,
};

final Map<String, String> emotionEmojis = {
  "기쁨": "😊",
  "슬픔": "😢",
  "불안": "😰",
  "분노": "😡",
  "평온": "😌",
  "당황": "😳",
};

class EmotionOverlay extends StatefulWidget {
  final String currentEmotion;
  final double currentScore;
  final List<Map<String, dynamic>> emotionHistory;

  const EmotionOverlay({
    super.key,
    required this.currentEmotion,
    required this.currentScore,
    required this.emotionHistory,
  });

  @override
  State<EmotionOverlay> createState() => _EmotionOverlayState();
}

class _EmotionOverlayState extends State<EmotionOverlay> {
  bool _expanded = false;
  void _toggleExpanded() => setState(() => _expanded = !_expanded);

  @override
  Widget build(BuildContext context) {
    final color = emotionColors[widget.currentEmotion] ?? Colors.grey;
    final emoji = emotionEmojis[widget.currentEmotion] ?? "🙂";

    return Positioned(
      top: 80,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(12),
        height: _expanded ? 220 : 70,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // 상단 감정 + 점수 + 토글
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "${widget.currentEmotion} (${widget.currentScore.toStringAsFixed(2)})",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: color.withOpacity(0.8),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: color.withOpacity(0.8),
                  ),
                  onPressed: _toggleExpanded,
                ),
              ],
            ),

            // 확장 상태일 때만 곡선 그래프 표시
            if (_expanded)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: _buildDynamicChart(color),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 🎢 실시간 감정 곡선 그래프
  Widget _buildDynamicChart(Color color) {
    if (widget.emotionHistory.isEmpty) {
      return const SizedBox.shrink();
    }

    // 감정 점수 목록을 FlSpot으로 변환
    final spots = widget.emotionHistory.asMap().entries.map((e) {
      final x = e.key.toDouble();
      final y = (e.value['score'] ?? 0.0).toDouble().clamp(0.0, 1.0);
      return FlSpot(x, y);
    }).toList();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 700),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 1,
          minX: (spots.length > 10)
              ? (spots.length - 10).toDouble()
              : 0, // 최근 10개만 표시
          maxX: spots.length.toDouble(),
          titlesData: FlTitlesData(show: false), // 축/라벨 제거
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),

          // 그래프 말풍선
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (spot) => Colors.black87,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final index = spot.spotIndex;
                  final emotion =
                      widget.emotionHistory[index]['emotion'] ?? '감정';
                  final score = spot.y.toStringAsFixed(3);
                  return LineTooltipItem(
                    '$emotion: $score',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  );
                }).toList();
              },
            ),
          ),

          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              curveSmoothness: 0.5,
              color: color,
              barWidth: 4,
              isStrokeCapRound: true,
              spots: spots,
              belowBarData: BarAreaData(
                show: true,
                color: color.withOpacity(0.25),
              ),
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }
}
