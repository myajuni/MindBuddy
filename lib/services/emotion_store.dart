// lib/services/emotion_store.dart 파일

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 🔒 AES 암호화된 감정 데이터 저장소
class EmotionStore extends ChangeNotifier {
  static final EmotionStore instance = EmotionStore._internal();
  EmotionStore._internal();

  // 내부 상태
  String _emotion = "평온";
  double _score = 0.5;
  final List<Map<String, dynamic>> _history = [];

  // 보안 스토리지
  static const _secureKey = 'secure_emotion_history';
  static const _storage = FlutterSecureStorage();

  // Getter
  String get emotion => _emotion;
  double get score => _score;
  List<Map<String, dynamic>> get history => List.unmodifiable(_history);

  // ✅ 앱 시작 시 호출 (저장된 감정 기록 불러오기)
  Future<void> init() async {
    final jsonStr = await _storage.read(key: _secureKey);
    if (jsonStr == null) return;

    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is List) {
        _history.clear();
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            _history.add(item);
          } else if (item is Map) {
            _history.add(Map<String, dynamic>.from(item));
          }
        }

        // 가장 최근 감정 복원
        if (_history.isNotEmpty) {
          _emotion = _history.last['emotion'] ?? "평온";
          _score = (_history.last['score'] ?? 0.5).toDouble();
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint("❌ EmotionStore 복원 실패: $e");
    }
  }

  // ✅ 감정 업데이트 + 암호화 저장
  Future<void> update(String newEmotion, double newScore) async {
    _emotion = newEmotion;
    _score = newScore;
    _history.add({
      'emotion': newEmotion,
      'score': newScore,
      'date': DateTime.now().toIso8601String(),
    });
    await _saveToSecureStorage();
    notifyListeners();
  }

  // ✅ 안전하게 저장
  Future<void> _saveToSecureStorage() async {
    try {
      final jsonStr = jsonEncode(_history);
      await _storage.write(key: _secureKey, value: jsonStr);
    } catch (e) {
      debugPrint("❌ EmotionStore 저장 실패: $e");
    }
  }

  // ✅ 전체 초기화
  Future<void> clear() async {
    _history.clear();
    _emotion = "평온";
    _score = 0.5;
    await _storage.delete(key: _secureKey);
    notifyListeners();
  }
}
