// lib/screens/lock_screen.dart

import 'package:flutter/material.dart';
import 'package:mindbuddy/main.dart';
import '../user_context.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _error;

  Future<void> _verifyPin() async {
    final savedPin = AppUser.pin;

    if (_controller.text == savedPin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } else {
      setState(() => _error = "잘못된 PIN이에요.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kHomeBg,
      body: SafeArea(
        child: Center(
          child: Container(
            width: 340,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                    color: Colors.black12, blurRadius: 12, offset: Offset(0, 4))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_rounded, size: 58, color: kMint),
                const SizedBox(height: 12),
                const Text(
                  "잠금 해제",
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: kDeepText),
                ),
                const SizedBox(height: 20),

                // PIN 입력
                TextField(
                  controller: _controller,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 22, letterSpacing: 8, color: kDeepText),
                  decoration: InputDecoration(
                    counterText: "",
                    filled: true,
                    fillColor: kHomeBg,
                    hintText: "PIN 입력",
                    hintStyle:
                        const TextStyle(color: Colors.black45, fontSize: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    errorText: _error,
                  ),
                ),

                const SizedBox(height: 20),

                // 확인 버튼
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kMint,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _verifyPin,
                    child: const Text(
                      "확인",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
