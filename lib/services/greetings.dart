// lib/services/greetings.dart

import 'dart:math';
import '../user_context.dart'; // ← 사용자 이름 불러오기

/// ⏰ 시간대별 기본 인사
String _timeGreeting() {
  final hour = DateTime.now().hour;

  if (hour >= 5 && hour < 11) {
    return "좋은 아침이에요! ☀️";
  } else if (hour >= 11 && hour < 18) {
    return "오후시간 이네요. 점심은 드셨나요? 🌤️";
  } else if (hour >= 18 && hour < 24) {
    return "벌써 저녁이 되었어요. 🌙";
  } else {
    return "고요한 새벽이에요. 🌙";
  }
}

/// 🎯 랜덤 추가 문구
final _extraLines = [
  "오늘 하루는 어떤가요? 😊",
  "지금 기분은 어떤가요? 궁금해요.",
  "편하게 이야기해 주세요. 언제나 듣고 있어요.",
  "무슨 일이 있으신가요? 말해주시면 함께 고민해볼게요.",
  "지금 어떤 감정이 드시나요?",
  "오늘 마음은 괜찮으신가요? 편히 얘기해요.",
];

/// 🙋 최종 인사말 생성
String generateGreeting() {
  final name = AppUser.name.isEmpty ? "사용자" : AppUser.name;

  final timeLine = _timeGreeting();
  final randomLine = _extraLines[Random().nextInt(_extraLines.length)];

  return "$name님, $timeLine\n$randomLine";
}
