from transformers import AutoTokenizer, AutoModelForSequenceClassification
import torch
from app.core.config import settings

_tokenizer = AutoTokenizer.from_pretrained(settings.EMO_MODEL)
_model = AutoModelForSequenceClassification.from_pretrained(settings.EMO_MODEL)
_model.eval()

def _softmax(t):
    e = torch.exp(t - t.max())
    return e / e.sum(-1, keepdim=True)

def infer_emotion(text: str):
    with torch.no_grad():
        inputs = _tokenizer(text, return_tensors="pt", truncation=True)
        outputs = _model(**inputs)
        probs = _softmax(outputs.logits[0]).tolist()
    id2label = _model.config.id2label  # 모델이 제공하는 매핑 사용
    scores = {id2label[i]: float(probs[i]) for i in range(len(probs))}
    top = max(scores.items(), key=lambda x: x[1])[0]
    return top, scores
