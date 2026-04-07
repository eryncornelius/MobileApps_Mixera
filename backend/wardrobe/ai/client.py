"""AI client for wardrobe clothing detection.

Currently returns a single placeholder candidate per image.
Replace _call_openai() with real OpenAI Vision API calls when ready.

Usage:
    from wardrobe.ai.client import WardrobeAIClient
    client = WardrobeAIClient()
    results = client.detect_items(image_path)  # list[CandidateResult]
"""
import logging
from typing import List

from wardrobe.ai.schemas import CandidateResult

logger = logging.getLogger(__name__)


class WardrobeAIClient:
    """
    Placeholder AI client. Swap _call_openai() for real logic later.
    The public interface (detect_items) must not change.
    """

    def detect_items(self, image_path: str) -> List[CandidateResult]:
        """
        Analyze an image and return a list of detected clothing candidates.

        Args:
            image_path: Absolute filesystem path to the uploaded image.

        Returns:
            List of CandidateResult — may be empty if nothing detected.
        """
        try:
            return self._call_openai(image_path)
        except Exception as exc:
            logger.warning("AI detection skipped (not configured): %s", exc)
            return self._placeholder_result()

    # ------------------------------------------------------------------
    # Internal
    # ------------------------------------------------------------------

    def _call_openai(self, image_path: str) -> List[CandidateResult]:
        """
        TODO: Replace with real OpenAI Vision API call.

        Example integration point:
            import openai, base64
            from wardrobe.ai.prompts import CLOTHING_DETECTION_SYSTEM, CLOTHING_DETECTION_USER

            with open(image_path, "rb") as f:
                b64 = base64.b64encode(f.read()).decode()

            response = openai.chat.completions.create(
                model="gpt-4o",
                messages=[
                    {"role": "system", "content": CLOTHING_DETECTION_SYSTEM},
                    {"role": "user", "content": [
                        {"type": "text", "text": CLOTHING_DETECTION_USER},
                        {"type": "image_url", "image_url": {"url": f"data:image/jpeg;base64,{b64}"}},
                    ]},
                ],
                response_format={"type": "json_object"},
            )
            items = response.choices[0].message.content  # parse JSON array
            return [CandidateResult(**item) for item in items]
        """
        raise NotImplementedError("OpenAI integration not yet configured.")

    def _placeholder_result(self) -> List[CandidateResult]:
        """One placeholder candidate so the review flow works end-to-end."""
        return [
            CandidateResult(
                category="other",
                subcategory="",
                color="",
                style_tags=[],
                confidence=None,
            )
        ]
