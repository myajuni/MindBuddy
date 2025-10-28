from pydantic import BaseModel
from dotenv import load_dotenv
import os

load_dotenv()

class Settings(BaseModel):
    APP_NAME: str = os.getenv("APP_NAME", "MindBuddy API")
    API_HOST: str = os.getenv("API_HOST", "0.0.0.0")
    API_PORT: int = int(os.getenv("API_PORT", "8000"))
    DATABASE_URL: str = os.getenv("DATABASE_URL", "sqlite:///mindbuddy.db")
    EMO_MODEL: str = os.getenv("EMO_MODEL", "Seonghaa/korean-emotion-classifier-roberta")

settings = Settings()
