from pydantic import BaseModel

class MemoryUpdateIn(BaseModel):
    user_id: str
    mtype: str   # 'traits'|'ongoing'|'episodic'
    key: str
    value: str
