from sqlalchemy.orm import Session
from app.db import models
from app.db.crud import get_or_assign_variant as _get

def get_or_assign_variant(db: Session, user_id: str) -> str:
    return _get(db, user_id)
