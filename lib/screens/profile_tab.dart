import 'package:flutter/material.dart';
import '../main.dart';

/// ---------------------- 프로필 탭 ----------------------
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const CircleAvatar(
              radius: 36,
              backgroundColor: kMint,
              child: Icon(Icons.person, color: Colors.white, size: 40)),
          const SizedBox(height: 12),
          const Center(
            child: Text("건우님",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: kDeepText)),
          ),
          const SizedBox(height: 24),
          _profileTile(Icons.book_rounded, "내 기록", () {}),
          _profileTile(Icons.notifications_rounded, "알림 설정", () {}),
          _profileTile(Icons.color_lens_rounded, "테마 변경", () {}),
          _profileTile(Icons.info_rounded, "앱 정보", () {}),
        ],
      ),
    );
  }

  Widget _profileTile(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: kMint),
        title: Text(title, style: const TextStyle(color: kDeepText)),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
