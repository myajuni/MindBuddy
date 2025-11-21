// lib/services/danger_words.dart

const dangerWords = [
  "자살",
  "죽고싶",
  "죽으려",
  "살기 싫",
  "죽을",
  "죽어",
  "죽기",
  "죽음",
  "살 의미가",
  "견딜 수 없",
  "견디기가",
  "견디기",
  "버티기 힘들어",
  "정신적으로 너무 힘들어"
];

bool containsDangerWord(String userText) {
  return dangerWords.any((w) => userText.contains(w));
}
