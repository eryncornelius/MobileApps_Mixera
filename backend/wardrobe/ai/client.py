"""AI client for wardrobe clothing detection.

Public interface:
    from wardrobe.ai.client import WardrobeAIClient
    client = WardrobeAIClient()
    results = client.detect_items(image_path)  # list[CandidateResult]

The public `detect_items()` signature must not change — detection_service.py
depends on it and is unaffected by internal changes here.
"""
import base64
import json
import logging
from typing import List

from django.conf import settings

from wardrobe.ai.prompts import CLOTHING_DETECTION_SYSTEM, CLOTHING_DETECTION_USER
from wardrobe.ai.schemas import BoundingBox, CandidateResult

logger = logging.getLogger(__name__)

# Fixed set of valid category values — mirrors ClothingCategory enum.
_VALID_CATEGORIES = {
    "top", "bottom", "outer", "dress", "shoes", "bag", "accessories", "other"
}

# Keyword → category alias table used when the model returns a non-canonical value.
_CATEGORY_ALIASES: dict[str, str] = {
    "shirt": "top", "blouse": "top", "sweater": "top", "hoodie": "top",
    "tank": "top", "polo": "top", "tee": "top",
    "pants": "bottom", "skirt": "bottom", "shorts": "bottom", "jeans": "bottom",
    "trousers": "bottom", "leggings": "bottom",
    "jacket": "outer", "coat": "outer", "blazer": "outer", "cardigan": "outer",
    "vest": "outer", "windbreaker": "outer",
    "sneaker": "shoes", "boot": "shoes", "heel": "shoes", "sandal": "shoes",
    "loafer": "shoes", "flat": "shoes", "pump": "shoes",
    "purse": "bag", "backpack": "bag", "handbag": "bag", "tote": "bag",
    "clutch": "bag", "satchel": "bag",
    "hat": "accessories", "cap": "accessories", "scarf": "accessories",
    "belt": "accessories", "watch": "accessories", "glasses": "accessories",
    "sunglasses": "accessories", "necklace": "accessories", "earring": "accessories",
    "bracelet": "accessories", "ring": "accessories",
}

# Supported MIME types for base64 image data URLs.
_MIME_BY_EXT = {
    "jpg": "image/jpeg",
    "jpeg": "image/jpeg",
    "png": "image/png",
    "webp": "image/webp",
    "heic": "image/heic",
}


def _map_category(raw: str) -> str:
    """Map model-returned category string to a valid ClothingCategory value."""
    clean = raw.strip().lower()
    if clean in _VALID_CATEGORIES:
        return clean
    for keyword, mapped in _CATEGORY_ALIASES.items():
        if keyword in clean:
            return mapped
    return "other"


def _parse_bounding_box(data) -> BoundingBox | None:
    if not isinstance(data, dict):
        return None
    try:
        return BoundingBox(
            x=int(data["x"]),
            y=int(data["y"]),
            width=int(data["width"]),
            height=int(data["height"]),
        )
    except (KeyError, ValueError, TypeError):
        return None


def _parse_items(raw_json: dict) -> List[CandidateResult]:
    items_data = raw_json.get("items", [])
    if not isinstance(items_data, list):
        logger.warning("Unexpected AI response shape: 'items' is not a list")
        return []

    results = []
    for item in items_data:
        if not isinstance(item, dict):
            continue
        try:
            category = _map_category(item.get("category", "other"))
            confidence = item.get("confidence")
            if confidence is not None:
                confidence = max(0.0, min(1.0, float(confidence)))

            results.append(
                CandidateResult(
                    category=category,
                    subcategory=str(item.get("subcategory", "") or ""),
                    color=str(item.get("color", "") or ""),
                    style_tags=[
                        str(t) for t in (item.get("style_tags") or [])
                        if isinstance(t, str)
                    ],
                    confidence=confidence,
                    bounding_box=_parse_bounding_box(item.get("bounding_box")),
                    raw_response=item,
                )
            )
        except Exception as exc:
            logger.warning("Skipping malformed candidate item: %s — %s", item, exc)

    return results


class WardrobeAIClient:
    """
    Calls OpenAI Vision to detect clothing items in an uploaded photo.
    Falls back to a single placeholder candidate if AI is unavailable.
    """

    def detect_items(self, image_path: str) -> List[CandidateResult]:
        """
        Analyze an image file and return detected clothing candidates.

        Args:
            image_path: Absolute filesystem path to the uploaded image.

        Returns:
            List of CandidateResult (may be a single placeholder on failure).
        """
        try:
            return self._call_openai(image_path)
        except Exception as exc:
            logger.warning(
                "Wardrobe AI detection failed for '%s', using placeholder: %s",
                image_path, exc,
            )
            return self._placeholder_result()

    # ------------------------------------------------------------------
    # Internal
    # ------------------------------------------------------------------

    def _call_openai(self, image_path: str) -> List[CandidateResult]:
        from common.openai_client import get_openai_client

        client = get_openai_client()
        model = getattr(settings, "OPENAI_MODEL", "gpt-4o-mini")

        ext = image_path.rsplit(".", 1)[-1].lower()
        mime = _MIME_BY_EXT.get(ext, "image/jpeg")

        with open(image_path, "rb") as f:
            b64_image = base64.b64encode(f.read()).decode("utf-8")

        response = client.chat.completions.create(
            model=model,
            messages=[
                {"role": "system", "content": CLOTHING_DETECTION_SYSTEM},
                {
                    "role": "user",
                    "content": [
                        {"type": "text", "text": CLOTHING_DETECTION_USER},
                        {
                            "type": "image_url",
                            "image_url": {
                                "url": f"data:{mime};base64,{b64_image}",
                                "detail": "low",  # faster + cheaper; sufficient for classification
                            },
                        },
                    ],
                },
            ],
            response_format={"type": "json_object"},
            max_completion_tokens=800,
        )

        raw_content = response.choices[0].message.content
        logger.debug("Wardrobe AI raw response: %s", raw_content)

        raw_json = json.loads(raw_content)
        results = _parse_items(raw_json)

        if not results:
            logger.info("AI returned no items for %s — using placeholder.", image_path)
            return self._placeholder_result()

        return results

    def _placeholder_result(self) -> List[CandidateResult]:
        """Single placeholder so the review flow works when AI is unavailable."""
        return [
            CandidateResult(
                category="other",
                subcategory="",
                color="",
                style_tags=[],
                confidence=None,
            )
        ]
