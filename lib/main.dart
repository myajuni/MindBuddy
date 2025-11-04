// lib/main.dart 파일

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/home_tab.dart';
import 'screens/chat_tab.dart';
import 'services/emotion_store.dart';
import 'screens/profile_tab.dart';
import 'screens/voice_chat_page.dart';
import 'package:intl/date_symbol_data_local.dart';

const kMint = Color(0xFF9BB7D4);
const kDeepText = Color.fromARGB(255, 29, 31, 62);
const kHomeBg = Color(0xFFF0F6FF);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ 1️⃣ .env 먼저 로드
  await dotenv.load(fileName: ".env");

  // ✅ 2️⃣ 날짜 포맷 로케일 초기화 (가장 먼저!)
  await initializeDateFormatting('ko_KR', null);

  // ✅ 3️⃣ EmotionStore의 암호화 데이터 복원
  await EmotionStore.instance.init();

  // ✅ 4️⃣ 앱 실행
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

  final _pages = const [
    HomeTab(),
    ChatTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _index == 0 ? kHomeBg : Colors.white,
      body: IndexedStack(index: _index, children: _pages),
      floatingActionButton: _index == 0
          ? FloatingActionButton(
              backgroundColor: kMint,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NewLogPage()),
                );
              },
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
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
