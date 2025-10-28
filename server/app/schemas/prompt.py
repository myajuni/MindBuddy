from pydantic import BaseModel
from typing import List, Dict, Optional

class PromptIn(BaseModel):
    user_id: str
    last_user_text: str
    history: List[Dict[str, str]] = []
    last_emotion: Optional[str] = None

class PromptOut(BaseModel):
    system_prompt: str
    guardrails: Dict[str, list]
    variant: str
