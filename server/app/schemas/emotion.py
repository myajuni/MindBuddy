from pydantic import BaseModel
from typing import Dict

class AnalyzeIn(BaseModel):
    user_id: str
    text: str

class AnalyzeOut(BaseModel):
    top_label: str
    scores: Dict[str, float]

class LogIn(AnalyzeIn):
    pass
