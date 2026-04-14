"""Schema definitions for mixmatch AI payloads."""
from dataclasses import dataclass


@dataclass
class OutfitAnalysisResult:
    """Structured output from the mixmatch AI outfit analyzer."""
    style_label: str        # e.g. "Smart Casual", "Street Chic"
    explanation: str        # 1–3 sentence outfit description
    tips: str = ""          # Optional short styling tip or suggestion
