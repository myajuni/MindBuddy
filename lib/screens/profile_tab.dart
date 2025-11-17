// lib/screens/profile_tab.dart 파일

import 'dart:convert';
import 'dart:typed_data';
import '../user_context.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'notification_settings_screen.dart';

/// ---------------------- 프로필 탭 ----------------------
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String _name = ''; // 화면에는 "건우님" 으로 표시
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
        return AlertDialog(
          title: const Text('이름 변경'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: '이름을 입력해 주세요',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
              child: const Text('저장'),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      setState(() => _name = result);
      AppUser.name = result;
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '프로필 아이콘 선택',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                // 📷 내 사진에서 선택
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  iconColor: kMint,
                  title: const Text('내 사진에서 선택'),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    await _pickAvatarFromGallery();
                  },
                ),
                if (_avatarBytes != null)
                  ListTile(
                    leading: const Icon(Icons.refresh_rounded),
                    title: const Text('기본 아이콘으로 되돌리기'),
                    onTap: () async {
                      Navigator.of(ctx).pop();
                      setState(() => _avatarBytes = null);
                      await _saveProfile();
                    },
                  ),
                const Divider(),
                const SizedBox(height: 8),

                // 기본 아이콘 선택
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: List.generate(_avatarIcons.length, (i) {
                    final selected = i == _avatarIndex && _avatarBytes == null;
                    return GestureDetector(
                      onTap: () async {
                        setState(() {
                          _avatarIndex = i;
                          _avatarBytes = null; // 사진 대신 아이콘 사용
                        });
                        await _saveProfile();
                        if (context.mounted) {
                          Navigator.of(ctx).pop();
                        }
                      },
                      child: CircleAvatar(
                        radius: selected ? 30 : 26,
                        backgroundColor:
                            selected ? kMint.withOpacity(0.3) : kMint,
                        child: Icon(
                          _avatarIcons[i],
                          color: Colors.white,
                          size: selected ? 30 : 26,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('닫기'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _name.isEmpty ? '사용자님' : '${_name}님'; // 이름 비어있으면 기본 문구

    return SafeArea(
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
            Icons.info_rounded,
            "앱 정보",
            () {
              // TODO: 앱 정보 화면 연결하고 싶으면 여기 Navigator.push 추가
            },
          ),
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
