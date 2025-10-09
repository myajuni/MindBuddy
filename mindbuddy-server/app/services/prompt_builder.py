from typing import Dict, Optional

def build_prompt(variant: str, memory: Dict[str, Dict[str, str]], last_emotion: Optional[str]):
    forbidden = ["진단 단정", "약물 권유", "자해/자살 조장"]
    guardrails = {"forbidden": forbidden}

    traits = ", ".join([f"{k}:{v}" for k,v in memory.get("traits", {}).items()]) or "없음"
    ongoing = ", ".join([f"{k}:{v}" for k,v in memory.get("ongoing", {}).items()]) or "없음"
    episodic = ", ".join([f"{k}:{v}" for k,v in memory.get("episodic", {}).items()]) or "없음"
    emo = f"사용자의 최근 감정: {last_emotion}" if last_emotion else "최근 감정 정보 없음"

    if variant == "A":
        system = (
            "You are MindBuddy, a Korean CBT-based emotional support assistant.\n"
            "규칙: 1) 응답은 2문장 이하. 2) 마지막에 질문 또는 아주 작은 미션 1개만. "
            "3) 진단/약물권유/자해조장 금지.\n"
            f"개인화 메모리: traits={traits}; ongoing={ongoing}; episodic={episodic}. {emo}\n"
            "말투: 따뜻하고 짧고 편안한 구어체."
        )
    else:
        system = (
            "You are MindBuddy, a Korean CBT-based emotional support assistant.\n"
            "규칙: 1) 2문장. 1문장 공감, 1문장 구체적 미션. 2) 질문 금지, 미션 1개만. "
            "3) 진단/약물권유/자해조장 금지.\n"
            f"개인화 메모리: traits={traits}; ongoing={ongoing}; episodic={episodic}. {emo}\n"
            "말투: 따뜻하고 간결."
        )
    return system, guardrails
