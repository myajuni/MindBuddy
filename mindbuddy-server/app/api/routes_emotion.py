# app/api/routes_emotion.py
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from app.services.emotion_analyzer import analyze_emotion

router = APIRouter()

class EmotionRequest(BaseModel):
    user_id: str
    text: str

@router.post("/")
async def detect_emotion(req: EmotionRequest):
    """
    사용자의 텍스트를 받아 감정(분노, 불안, 슬픔, 평온, 당황, 기쁨)을 분석합니다.
    """
    try:
        emotion, score = analyze_emotion(req.text)
        return {"user_id": req.user_id, "emotion": emotion, "score": score}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
