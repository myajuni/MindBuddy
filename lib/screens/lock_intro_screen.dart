// lib/screens/lock_intro_screen.dart 파일

import 'package:flutter/material.dart';
import 'setup_pin_screen.dart';
import '../main.dart'; // 색상

class LockIntroScreen extends StatelessWidget {
  const LockIntroScreen({super.key});

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
                "상담 기록을 안전하게 보호할게요 🔒",
                style: TextStyle(
                  fontSize: 26,
                  color: kDeepText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                "MindBuddy는 당신의 마음 기록을\n무엇보다 소중하게 여깁니다.\n\n"
                "다른 사람이 앱을 보지 않도록\n잠금용 PIN을 설정해주세요.",
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const SetupPinScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kMint,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "PIN 설정하기",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
