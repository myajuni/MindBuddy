from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.schemas.prompt import PromptIn, PromptOut
from app.db.session import get_db
from app.db import models
from app.services.prompt_builder import build_prompt

router = APIRouter()

def _memory_bundle(db: Session, user_id: str):
    mem = {"traits": {}, "ongoing": {}, "episodic": {}}
    rows = db.query(models.Memory).filter(models.Memory.user_id == user_id).all()
    for r in rows:
        mem.setdefault(r.mtype, {})[r.key] = r.value
    return mem

@router.post("/prompt", response_model=PromptOut)
def prompt(payload: PromptIn, db: Session = Depends(get_db)):
    mem = _memory_bundle(db, payload.user_id)
    system, guard = build_prompt("A", mem, payload.last_emotion)
    return PromptOut(system_prompt=system, guardrails=guard, variant="A")
