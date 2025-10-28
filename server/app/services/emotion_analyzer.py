# app/services/emotion_analyzer.py
from transformers import AutoTokenizer, AutoModelForSequenceClassification
import torch

# ✅ 모델 로드 (처음 한 번만 다운로드됨)
MODEL_NAME = "Seonghaa/korean-emotion-classifier-roberta"
tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)
model = AutoModelForSequenceClassification.from_pretrained(MODEL_NAME)
model.eval()

labels = ["분노", "불안", "슬픔", "평온", "당황", "기쁨"]

def analyze_emotion(text: str):
    """
    주어진 문장을 감정 레이블과 확률로 변환
    """
    inputs = tokenizer(text, return_tensors="pt", truncation=True, padding=True)
    with torch.no_grad():
        logits = model(**inputs).logits
        probs = torch.softmax(logits, dim=1)[0]
        idx = torch.argmax(probs).item()
        return labels[idx], float(probs[idx])
