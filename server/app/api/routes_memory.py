from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.schemas.memory import MemoryUpdateIn
from app.db.session import get_db
from app.db import models
from datetime import datetime

router = APIRouter()

@router.post("/memory/update")
def memory_update(payload: MemoryUpdateIn, db: Session = Depends(get_db)):
    row = db.query(models.Memory).filter(
        models.Memory.user_id == payload.user_id,
        models.Memory.mtype == payload.mtype,
        models.Memory.key == payload.key
    ).first()
    if row:
        row.value = payload.value
        row.updated_at = datetime.utcnow()
    else:
        db.add(models.Memory(
            user_id=payload.user_id,
            mtype=payload.mtype,
            key=payload.key,
            value=payload.value
        ))
    db.commit()
    return {"ok": True}
