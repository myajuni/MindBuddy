//lib/widgets/emotion_ratio_pie.dart 파일

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mindbuddy/services/emotion_store.dart';
import '../widgets/emotion_overlay.dart' show emotionColors;

import 'dart:collection';

class EmotionRatioPie extends StatefulWidget {
  final DateTime selectedDate; // ✅ 캘린더에서 전달받은 날짜
  const EmotionRatioPie({super.key, required this.selectedDate});

  @override
  State<EmotionRatioPie> createState() => _EmotionRatioPieState();
}

class _EmotionRatioPieState extends State<EmotionRatioPie> {
  Map<String, double> _ratio = {};

  @override
  void initState() {
    super.initState();
    _updateData();
    EmotionStore.instance.addListener(_updateData);
  }

  // ✅ 날짜가 바뀔 때마다 데이터 새로 불러오도록 추가
  @override
  void didUpdateWidget(covariant EmotionRatioPie oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      _updateData(); // 👉 캘린더 선택 날짜 바뀌면 그래프 갱신
    }
  }

  @override
  void dispose() {
    EmotionStore.instance.removeListener(_updateData);
    super.dispose();
  }

  void _updateData() {
    final history = EmotionStore.instance.history;
    if (history.isEmpty) {
      setState(() => _ratio = {"평온": 1.0});
      return;
    }

    final target = widget.selectedDate;
    final filtered = history.where((item) {
      final date = DateTime.tryParse(item['date'] ?? '') ?? DateTime.now();
      return date.year == target.year &&
          date.month == target.month &&
          date.day == target.day;
    }).toList();

    if (filtered.isEmpty) {
      setState(() => _ratio = {"평온": 1.0});
      return;
    }

    final counter = HashMap<String, int>();
    for (final item in filtered) {
      final emo = item['emotion'] ?? '평온';
      counter[emo] = (counter[emo] ?? 0) + 1;
    }

    final total = counter.values.fold<int>(0, (a, b) => a + b);
    final ratio = counter.map((k, v) => MapEntry(k, v / total));

    setState(() => _ratio = ratio);
  }

  @override
  Widget build(BuildContext context) {
    final centerEmotion = _ratio.isNotEmpty
        ? _ratio.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : '평온';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("🟣 감정 분포 비율",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 45,
                sections: _ratio.entries.map((e) {
                  return PieChartSectionData(
                    value: e.value,
                    color: emotionColors[e.key] ?? Colors.grey,
                    title: "${e.key}\n${(e.value * 100).toStringAsFixed(0)}%",
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              "가장 자주 느낀 감정: $centerEmotion",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
