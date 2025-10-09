from sqlalchemy.orm import Session
from app.db import models

def get_or_assign_variant(db: Session, user_id: str) -> str:
    row = db.query(models.ABVariant).filter(models.ABVariant.user_id == user_id).first()
    if row:
        return row.variant
    v = "A" if (sum(map(ord, user_id)) % 2 == 0) else "B"
    db.add(models.ABVariant(user_id=user_id, variant=v))
    db.commit()
    return v
