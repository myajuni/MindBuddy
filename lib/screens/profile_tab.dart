// lib/screens/profile_tab.dart 파일

import 'dart:convert';
import 'dart:typed_data';
import '../user_context.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'notification_settings_screen.dart';
import 'change_pin_screen.dart';

/// ---------------------- 프로필 탭 ----------------------
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String _name = '';
  int _avatarIndex = 0;
  Uint8List? _avatarBytes; // 갤러리에서 고른 사진
  final ImagePicker _picker = ImagePicker();

  // 기본 아바타 아이콘 목록
  final List<IconData> _avatarIcons = const [
    Icons.person,
    Icons.sentiment_satisfied_rounded,
    Icons.self_improvement_rounded,
    Icons.psychology_rounded,
    Icons.favorite_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final sp = await SharedPreferences.getInstance();
    final name = sp.getString('profile_name');
    final avatarIndex = sp.getInt('profile_avatar') ?? 0;
    final avatarBytesBase64 = sp.getString('profile_avatar_bytes');

    setState(() {
      if (name != null && name.isNotEmpty) {
        _name = name;
        AppUser.name = name;
      }
      _avatarIndex = avatarIndex.clamp(0, _avatarIcons.length - 1);
      if (avatarBytesBase64 != null) {
        try {
          _avatarBytes = base64Decode(avatarBytesBase64);
        } catch (_) {
          _avatarBytes = null;
        }
      }
    });
  }

  Future<void> _saveProfile() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('profile_name', _name);
    await sp.setInt('profile_avatar', _avatarIndex);

    if (_avatarBytes != null) {
      await sp.setString('profile_avatar_bytes', base64Encode(_avatarBytes!));
    } else {
      await sp.remove('profile_avatar_bytes');
    }
  }

  // 이름 변경 다이얼로그
  Future<void> _changeName() async {
    final controller = TextEditingController(text: _name);

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: kHomeBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목
                Text(
                  "이름 변경",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kDeepText,
                  ),
                ),
                const SizedBox(height: 16),

                // 입력창
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: '이름을 입력해 주세요',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: kMint, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: kMint.withOpacity(0.4)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: kMint, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 버튼 행
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text(
                        "취소",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop(controller.text.trim());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kMint,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "저장",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      setState(() => _name = result);
      await AppUser.saveName(result);
      await _saveProfile();
    }
  }

  // 갤러리에서 이미지 선택
  Future<void> _pickAvatarFromGallery() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    setState(() {
      _avatarBytes = bytes;
    });
    await _saveProfile();
  }

// 아바타 선택 바텀시트
  Future<void> _changeAvatar() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목
                Text(
                  "프로필 이미지 선택",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: kDeepText,
                  ),
                ),
                const SizedBox(height: 16),

                // 내 사진에서 선택
                _bottomSheetTile(
                  icon: Icons.photo_library_outlined,
                  text: "내 사진에서 선택",
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    await _pickAvatarFromGallery();
                  },
                ),

                // 기본 아이콘으로 되돌리기 (이미 사진 선택한 경우만)
                if (_avatarBytes != null)
                  _bottomSheetTile(
                    icon: Icons.refresh_rounded,
                    text: "기본 아이콘으로 되돌리기",
                    onTap: () async {
                      Navigator.of(ctx).pop();
                      setState(() => _avatarBytes = null);
                      await _saveProfile();
                    },
                  ),

                const SizedBox(height: 12),
                Divider(color: Colors.grey.withOpacity(0.3)),
                const SizedBox(height: 12),

                // 기본 아이콘 선택 영역
                Text(
                  "기본 아이콘",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: kDeepText,
                  ),
                ),
                const SizedBox(height: 14),

                // 기본 아이콘 그리드
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: List.generate(_avatarIcons.length, (i) {
                    final selected = i == _avatarIndex && _avatarBytes == null;
                    return GestureDetector(
                      onTap: () async {
                        setState(() {
                          _avatarIndex = i;
                          _avatarBytes = null;
                        });
                        await _saveProfile();
                        if (context.mounted) {
                          Navigator.of(ctx).pop();
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected ? kMint.withOpacity(0.3) : kMint,
                        ),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.transparent,
                          child: Icon(
                            _avatarIcons[i],
                            color: Colors.white,
                            size: selected ? 32 : 28,
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text(
                      "닫기",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _bottomSheetTile({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: kMint, size: 26),
      title: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: kDeepText,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 6),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _name.isEmpty ? '사용자님' : '${_name}님'; // 이름 비어있으면 기본 문구

    return Scaffold(
      backgroundColor: kHomeBg, // 화면 전체 배경색
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 8),

            // 프로필 이미지 (탭: 변경, 길게: 기본 아이콘으로)
            Center(
              child: GestureDetector(
                onTap: _changeAvatar,
                onLongPress: () async {
                  if (_avatarBytes != null) {
                    setState(() => _avatarBytes = null);
                    await _saveProfile();
                  }
                },
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: kMint,
                  child: _avatarBytes != null
                      ? ClipOval(
                          child: Image.memory(
                            _avatarBytes!,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          _avatarIcons[_avatarIndex],
                          color: Colors.white,
                          size: 40,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 이름 (탭해서 변경)
            GestureDetector(
              onTap: _changeName,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: kDeepText,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.edit_rounded,
                      size: 18,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 메뉴: 알림 설정 / 앱 정보
            _profileTile(
              Icons.notifications_rounded,
              "알림 설정",
              () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const NotificationSettingsScreen(),
                  ),
                );
              },
            ),
            _profileTile(
              Icons.lock_outline_rounded,
              "PIN 번호 변경",
              () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ChangePinScreen()),
                );
              },
            ),
            _profileTile(
              Icons.info_rounded,
              "앱 정보",
              () {
                // TODO: 앱 정보 화면 연결하고 싶으면 여기 Navigator.push 추가
              },
            ),
          ],
        ),
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
