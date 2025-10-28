🧠 MindBuddy Server (FastAPI)

AI 감정 분석 + 맞춤형 GPT 프롬프트 생성 서버
— Flutter 클라이언트(lib/)와 연동되는 백엔드 시스템

🚀 프로젝트 개요

MindBuddy는 사용자의 감정을 실시간으로 인식하고,
대화 맥락에 따라 심리상담 스타일의 GPT 프롬프트를 구성하는 AI 감정 상담 챗봇 서버입니다.
이 저장소는 FastAPI 기반 서버를 포함하며, Flutter 앱에서 감정 분석 및 대화 생성을 담당합니다.

⚙️ 환경 설정 (macOS / Linux 기준)
1️⃣ 프로젝트 디렉토리 이동
cd server

2️⃣ Python 3.10 설치 (macOS Homebrew)
brew install python@3.10


⚠️ Python 3.11 이상에서는 일부 transformer 모델 로딩이 불안정할 수 있습니다.

3️⃣ 가상환경 생성 및 활성화
# 가상환경 생성
python3.10 -m venv .venv

# Mac / Linux
source .venv/bin/activate

# Windows (PowerShell)
.venv\Scripts\activate


✅ 항상 (venv) 표시가 터미널 앞에 붙어 있어야 정상입니다.
만약 “ModuleNotFoundError: No module named 'dotenv'” 오류가 발생하면,
잘못된 Python 버전으로 venv가 만들어진 것이므로 .venv를 삭제하고 다시 3.10으로 생성하세요.

4️⃣ 필수 패키지 설치
pip install -r requirements.txt


5️⃣ .env 파일 생성 (프로젝트 루트 mindbuddy/ 위치)
OPENAI_API_KEY=sk-XXXXXXXXXXXXXXXXXXXXXXXX

⚠️ .env 파일은 server/app/core/config.py 에서 자동으로 로드됩니다.

6️⃣ 서버 실행
bash run.sh


또는 수동으로:

uvicorn app.main:app --host 0.0.0.0 --port 8000

7️⃣ 서버 접속 확인

브라우저에서 아래 주소로 접속 👇

http://127.0.0.1:8000/


정상 메시지:

{"message": "MindBuddy server is running 🚀"}


API 문서 (Swagger UI):

http://127.0.0.1:8000/docs

