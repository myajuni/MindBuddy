import 'package:flutter/material.dart';

class EmotionStore extends ChangeNotifier {
  static final EmotionStore instance = EmotionStore._internal();
  EmotionStore._internal();

  String _emotion = "평온";
  double _score = 0.5;
  final List<Map<String, dynamic>> _history = [];

  String get emotion => _emotion;
  double get score => _score;
  List<Map<String, dynamic>> get history => List.unmodifiable(_history);

  void update(String newEmotion, double newScore) {
    _emotion = newEmotion;
    _score = newScore;
    _history.add({'emotion': newEmotion, 'score': newScore});
    notifyListeners();
  }

  void clear() {
    _history.clear();
    _emotion = "평온";
    _score = 0.5;
    notifyListeners();
  }
}
