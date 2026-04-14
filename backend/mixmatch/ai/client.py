"""AI client for mixmatch outfit analysis.

Public interface:
    from mixmatch.ai.client import MixmatchAIClient
    client = MixmatchAIClient()
    result = client.analyze_outfit(items, score)  # OutfitAnalysisResult
"""
import json
import logging

from django.conf import settings

from mixmatch.ai.prompts import OUTFIT_ANALYSIS_SYSTEM, build_outfit_analysis_prompt
from mixmatch.ai.schemas import OutfitAnalysisResult

logger = logging.getLogger(__name__)


class MixmatchAIClient:
    """
    Enriches rule-based outfit results with AI-generated style labels,
    explanations, and tips. Raises on failure — caller must handle fallback.
    """

    def analyze_outfit(self, items: list, score: int) -> OutfitAnalysisResult:
        """
        Ask the AI to analyze an outfit selection and return enriched output.

        Args:
            items: List of WardrobeItem instances.
            score: Integer compatibility score computed by the rule engine (0–100).

        Returns:
            OutfitAnalysisResult with style_label, explanation, tips.

        Raises:
            Exception if AI call fails (let caller decide on fallback).
        """
        return self._call_openai(items, score)

    # ------------------------------------------------------------------
    # Internal
    # ------------------------------------------------------------------

    def _call_openai(self, items: list, score: int) -> OutfitAnalysisResult:
        from common.openai_client import get_openai_client

        client = get_openai_client()
        model = getattr(settings, "OPENAI_MODEL", "gpt-4o-mini")

        user_message = build_outfit_analysis_prompt(items, score)

        response = client.chat.completions.create(
            model=model,
            messages=[
                {"role": "system", "content": OUTFIT_ANALYSIS_SYSTEM},
                {"role": "user", "content": user_message},
            ],
            response_format={"type": "json_object"},
            max_completion_tokens=800,
            temperature=0.4,  # low variance for consistent styling advice
        )

        raw_content = response.choices[0].message.content
        logger.debug("Mixmatch AI raw response: %s", raw_content)

        data = json.loads(raw_content)
        return OutfitAnalysisResult(
            style_label=str(data.get("style_label", "Balanced")).strip() or "Balanced",
            explanation=str(data.get("explanation", "")).strip(),
            tips=str(data.get("tips", "")).strip(),
        )
