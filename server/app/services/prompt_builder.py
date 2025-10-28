from typing import Dict, Optional

def build_prompt(variant: str, memory: Dict[str, Dict[str, str]], last_emotion: Optional[str]):
    forbidden = ["진단 단정", "약물 권유", "자해/자살 조장"]
    guardrails = {"forbidden": forbidden}

    # 🧠 사용자 메모리 구성
    traits = ", ".join([f"{k}:{v}" for k, v in memory.get("traits", {}).items()]) or "없음"
    ongoing = ", ".join([f"{k}:{v}" for k, v in memory.get("ongoing", {}).items()]) or "없음"
    episodic = ", ".join([f"{k}:{v}" for k, v in memory.get("episodic", {}).items()]) or "없음"
    emo = f"사용자의 최근 감정: {last_emotion}" if last_emotion else "최근 감정 정보 없음"

    # 💬 감정별 말투 설정
    tone_map = {
        "불안": "차분하고 안심시키는 어조로",
        "슬픔": "따뜻하고 위로하는 어조로",
        "분노": "공감하며 진정시켜주는 어조로",
        "당황": "침착하고 안정된 어조로",
        "기쁨": "밝고 긍정적인 어조로",
        "평온": "편안하고 일상적인 어조로",
    }
    tone = tone_map.get(last_emotion, "공감적이고 따뜻한 어조로")

    # 프롬프트 설계
    system = (
            "You are MindBuddy, a Korean CBT-based emotional support assistant.\n"
            "규칙:\n"
            "1) 응답은 2~3문장으로 응답. 1문장은 공감 필요.\n"
            "2) 마지막에 질문 또는 아주 작은 미션 1개만.\n"
            "3) 진단, 약물권유, 자해 혹은 자살 조장 금지. \n"
            f"개인화 메모리: traits={traits}; ongoing={ongoing}; episodic={episodic}. {emo}\n"
            f"말투: {tone}, 짧고 자연스러운 따뜻한 한국어 구어체로."
        )

    # 🧱 가드레일 정보 확장
    guardrails.update({
        "tone": tone,
        "variant": variant,
        "emotion": last_emotion
    })

    return system, guardrails
