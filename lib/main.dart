// lib/main.dart 파일

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/home_tab.dart';
import 'screens/chat_tab.dart';
import 'services/emotion_store.dart';
import 'screens/profile_tab.dart';
import 'screens/voice_chat_page.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/notification_service.dart'; // ⬅ 추가

const kMint = Color(0xFF9BB7D4);
const kDeepText = Color.fromARGB(255, 29, 31, 62);
const kHomeBg = Color(0xFFF0F6FF);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. .env 로드
  await dotenv.load(fileName: ".env");

  // 2. 날짜 포맷 로케일 초기화
  await initializeDateFormatting('ko_KR', null);

  // 3. EmotionStore 데이터 복구
  await EmotionStore.instance.init();

  // 4. 알림 서비스 초기화
  await NotificationService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MindBuddy',
      theme: ThemeData(useMaterial3: true),
      home: const MainShell(),
    );
  }
}

/// ---------------------- 메인 구조 ----------------------
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  /// 🔥 탭 이동할 때마다 새로운 화면을 생성하는 방식
  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const HomeTab(); // ← 매번 새로 생성됨
      case 1:
        return const ChatTab();
      case 2:
        return const ProfileTab();
      default:
        return const HomeTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _index == 0 ? kHomeBg : Colors.white,

      /// 🔥 IndexedStack → 페이지 함수 방식으로 변경
      body: _buildPage(_index),

      floatingActionButton: null,

      // floatingActionButton: _index == 0
      //     ? FloatingActionButton(
      //         backgroundColor: kMint,
      //         onPressed: () {
      //           Navigator.of(context).push(
      //             MaterialPageRoute(builder: (_) => const NewLogPage()),
      //           );
      //         },
      //         child: const Icon(Icons.add, color: Colors.white),
      //       )
      //     : null,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) {
          setState(() => _index = i); // 🔥 탭 이동 시 새 페이지 생성됨
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: kMint,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: '홈'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_rounded), label: '채팅'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded), label: '프로필'),
        ],
      ),
    );
  }
}
