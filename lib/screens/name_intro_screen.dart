// lib/screens/name_intro_screen.dart 파일

import 'package:flutter/material.dart';
import '../user_context.dart';
import 'lock_intro_screen.dart';
import '../main.dart'; // 색상 사용

class NameIntroScreen extends StatefulWidget {
  const NameIntroScreen({super.key});

  @override
  State<NameIntroScreen> createState() => _NameIntroScreenState();
}

class _NameIntroScreenState extends State<NameIntroScreen> {
  final TextEditingController _controller = TextEditingController();

  Future<void> _saveName() async {
    final name = _controller.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("이름을 입력해주세요.")),
      );
      return;
    }

    await AppUser.saveName(name);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LockIntroScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kHomeBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                "MindBuddy에 오신 걸 환영해요!",
                style: TextStyle(
                  fontSize: 28,
                  color: kDeepText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                "당신의 마음을 기록하고,\n조금 더 편안한 하루를 만들 수 있도록 도울게요.",
                style: TextStyle(fontSize: 16, height: 1.4),
              ),
              const SizedBox(height: 40),
              const Text(
                "먼저, 어떻게 불러드릴까요?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: "이름을 입력하세요",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveName,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kMint,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "다음",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
