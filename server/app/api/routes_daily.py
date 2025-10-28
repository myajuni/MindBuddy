from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from datetime import datetime, date
import json, collections
from app.db.session import get_db
from app.db import models
from typing import Optional

router = APIRouter()

@router.get("/daily/{user_id}")

def daily(user_id: str, day: Optional[str] = None, method: str = "mode", db: Session = Depends(get_db)):

    target = date.fromisoformat(day) if day else datetime.utcnow().date()
    start = datetime.combine(target, datetime.min.time())
    end = datetime.combine(target, datetime.max.time())
    rows = db.query(models.EmotionLog).filter(
        models.EmotionLog.user_id == user_id,
        models.EmotionLog.created_at >= start,
        models.EmotionLog.created_at <= end
    ).all()
    if not rows:
        return {"user_id": user_id, "day": str(target), "label": None}

    if method == "mode":
        counter = collections.Counter([r.top_label for r in rows])
        label, _ = counter.most_common(1)[0]
        used = "mode"
    else:
        acc = {}
        cnt = 0
        for r in rows:
            s = json.loads(r.scores_json)
            for k, v in s.items():
                acc[k] = acc.get(k, 0.0) + float(v)
            cnt += 1
        avg = {k: v / cnt for k, v in acc.items()}
        label = max(avg.items(), key=lambda x: x[1])[0]
        used = "softmax-avg"

    dm = db.query(models.DailyMood).filter(
        models.DailyMood.user_id == user_id,
        models.DailyMood.day == target
    ).first()
    if dm:
        dm.label = label
        dm.method = used
    else:
        db.add(models.DailyMood(user_id=user_id, day=target, label=label, method=used))
    db.commit()
    return {"user_id": user_id, "day": str(target), "label": label, "method": used}
