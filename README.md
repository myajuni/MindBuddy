# 🧠 MindBuddy

**MindBuddy** is a Flutter-based AI emotional companion app that supports daily emotional tracking, journaling, and GPT-based empathetic conversations.

---

## 🚀 Features
- 🎙️ Voice-based and text-based chat with GPT
- 💭 Emotion recognition via FastAPI backend
- 📊 Emotion trend visualization (FL Chart)
- 📔 Daily emotion diary summarization
- 🔒 Secure emotion storage using FlutterSecureStorage

---

## 🛠️ Tech Stack
- **Frontend**: Flutter (Material 3)
- **Backend**: FastAPI (for emotion analysis & prompt generation)
- **AI**: OpenAI GPT (for diary summarization & chat)
- **Storage**: FlutterSecureStorage + SharedPreferences

---

## 📂 Project Structure
lib/
├── main.dart
├── screens/
│ ├── home_tab.dart
│ ├── chat_tab.dart
│ ├── profile_tab.dart
│ └── voice_chat_page.dart
├── services/
│ ├── api_client.dart
│ ├── emotion_store.dart
│ ├── prompt_manager.dart
│ └── diary_summarizer.dart
└── widgets/
├── emotion_overlay.dart
├── emotion_ratio_pie.dart
└── weekly_trend_card.dart


---

## ⚙️ Setup
1. Clone this repository:
   ```bash
   git clone https://github.com/myajuni/MindBuddy.git
   cd MindBuddy

2. Install dependencies:
    flutter pub get

3. Create your .env file:
    OPENAI_API_KEY=your_openai_key_here

4. Run the app:
    flutter run