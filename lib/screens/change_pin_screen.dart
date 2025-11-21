// lib/screens/change_pin_screen.dart

import 'package:flutter/material.dart';
import '../main.dart';
import '../user_context.dart';

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  final oldPin = TextEditingController();
  final newPin = TextEditingController();
  String? error;

  Future<void> _updatePin() async {
    final saved = AppUser.pin;

    if (oldPin.text != saved) {
      setState(() => error = "기존 PIN이 일치하지 않아요.");
      return;
    }

    if (newPin.text.length < 4) {
      setState(() => error = "PIN은 최소 4자리를 입력해주세요.");
      return;
    }

    await AppUser.savePin(newPin.text);

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PIN이 변경되었습니다.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kHomeBg,
      appBar: AppBar(
        title: const Text("PIN 번호 변경"),
        backgroundColor: kHomeBg,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _inputBox("기존 PIN", oldPin),
            const SizedBox(height: 20),
            _inputBox("새 PIN", newPin),
            const SizedBox(height: 20),
            if (error != null)
              Text(error!,
                  style: const TextStyle(color: Colors.red, fontSize: 14)),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _updatePin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kMint,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "변경하기",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _inputBox(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: true,
      keyboardType: TextInputType.number,
      maxLength: 6,
      decoration: InputDecoration(
        labelText: label,
        counterText: "",
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
