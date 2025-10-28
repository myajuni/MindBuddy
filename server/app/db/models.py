from sqlalchemy import Column, Integer, String, Text, DateTime, Date
from datetime import datetime
from app.db.base import Base

class EmotionLog(Base):
    __tablename__ = "emotion_logs"
    id = Column(Integer, primary_key=True)
    user_id = Column(String, index=True)
    text = Column(Text)
    top_label = Column(String, index=True)
    scores_json = Column(Text)
    created_at = Column(DateTime, default=datetime.utcnow, index=True)

class DailyMood(Base):
    __tablename__ = "daily_moods"
    id = Column(Integer, primary_key=True)
    user_id = Column(String, index=True)
    day = Column(Date, index=True)
    label = Column(String)
    method = Column(String)
    created_at = Column(DateTime, default=datetime.utcnow)

class ABVariant(Base):
    __tablename__ = "ab_variants"
    user_id = Column(String, primary_key=True)
    variant = Column(String)  # 'A' or 'B'

class Memory(Base):
    __tablename__ = "memories"
    id = Column(Integer, primary_key=True)
    user_id = Column(String, index=True)
    mtype = Column(String)  # 'traits'|'ongoing'|'episodic'
    key = Column(String, index=True)
    value = Column(Text)
    updated_at = Column(DateTime, default=datetime.utcnow)
