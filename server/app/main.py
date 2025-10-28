from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api import routes_emotion, routes_prompt, routes_memory, routes_daily

app = FastAPI(title="MindBuddy Backend")

# ✅ 웹(크롬)에서 접근 허용
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ✅ 여기서 /log 경로 등록 (이게 핵심이에요!!)
app.include_router(routes_emotion.router, prefix="/log", tags=["Emotion"])
app.include_router(routes_prompt.router, prefix="/prompt", tags=["Prompt"])
app.include_router(routes_memory.router, prefix="/memory", tags=["Memory"])
app.include_router(routes_daily.router, prefix="/daily", tags=["Daily"])

@app.get("/")
def root():
    return {"message": "MindBuddy server is running 🚀"}
