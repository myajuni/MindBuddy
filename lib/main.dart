import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/chat_tab.dart';
import 'screens/home_tab.dart';
import 'screens/profile_tab.dart';

const kMint = Color(0xFF73C8B6);
const kDeepText = Color(0xFF2E4C58);
const kHomeBg = Color(0xFFF0F6FF);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
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

/// ---------------------- 홈 탭 ----------------------
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "안녕하세요, 건우님 🌿",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: kDeepText,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "오늘의 감정 상태를 기록해보세요",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // 검색창
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "감정, 키워드, 일기 검색...",
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // 오늘의 추천
            const Text(
              "오늘의 추천",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.0,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                SuggestionCard(title: "마음 안정 음악"),
                SuggestionCard(title: "명상 가이드"),
                SuggestionCard(title: "감정 기록 팁"),
                SuggestionCard(title: "스트레스 완화"),
              ],
            ),

            // 최근 감정 기록을 아래로 내리기
            const SizedBox(height: 40),
            const Text(
              "최근 감정 기록",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            const Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    EmotionLog(text: "기분이 차분해졌어요"),
                    EmotionLog(text: "조금 외로웠던 하루"),
                    EmotionLog(text: "성취감을 느꼈어요"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------- 카드 구성 ----------------------
class SuggestionCard extends StatelessWidget {
  final String title;
  const SuggestionCard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: kDeepText,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "클릭하여 자세히 보기",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

/// ---------------------- 감정 기록 카드 ----------------------
class EmotionLog extends StatelessWidget {
  final String text;
  const EmotionLog({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.chat_bubble_outline, color: kMint),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

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

/// ---------------------- 새 기록 페이지 (+ 버튼) ----------------------
class NewLogPage extends StatefulWidget {
  const NewLogPage({super.key});
  @override
  State<NewLogPage> createState() => _NewLogPageState();
}

class _NewLogPageState extends State<NewLogPage> {
  final _controller = TextEditingController();
  String _mood = '🙂 차분함';
  final moods = const ['🙂 차분함', '😌 편안함', '😕 불안함', '😢 슬픔', '😡 화남', '🤩 설렘'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kHomeBg,
      appBar: AppBar(
        backgroundColor: kHomeBg,
        elevation: 0,
        title: const Text('새 기록',
            style: TextStyle(color: kDeepText, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: kDeepText),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('오늘의 감정',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: moods.map((m) {
                final selected = _mood == m;
                return ChoiceChip(
                  label: Text(m),
                  selected: selected,
                  onSelected: (_) => setState(() => _mood = m),
                  selectedColor: kMint,
                  labelStyle:
                      TextStyle(color: selected ? Colors.white : kDeepText),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFE0E0E0)),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text('내용',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 3))
                  ],
                ),
                padding: const EdgeInsets.all(14),
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  expands: true,
                  decoration: const InputDecoration(
                    hintText: '오늘 있었던 일과 감정을 자유롭게 적어보세요…',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kMint,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                label: const Text('저장하기',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$_mood 로 저장했어요!')),
                  );
                  Navigator.pop(context);
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
