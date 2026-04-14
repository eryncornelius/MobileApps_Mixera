"""Build per-candidate JPEG crops from source photo + bounding box (pixels)."""
from __future__ import annotations

import logging
import uuid
from io import BytesIO
from typing import Any, Mapping

from django.core.files.base import ContentFile

logger = logging.getLogger(__name__)


def candidate_crop_content_file(
    photo_path: str, bbox: Mapping[str, Any] | None
) -> ContentFile | None:
    """
    Return an in-memory JPEG suitable for ``DetectedItemCandidate.cropped_image``.

    ``bbox`` uses keys x, y, width, height in **pixel** coordinates (same as AI schema).
    Returns None if the box is missing, invalid, or Pillow / IO fails.
    """
    if not bbox or not isinstance(bbox, dict):
        return None
    try:
        x = int(float(bbox["x"]))
        y = int(float(bbox["y"]))
        w_box = int(float(bbox["width"]))
        h_box = int(float(bbox["height"]))
    except (KeyError, TypeError, ValueError):
        return None

    if w_box < 1 or h_box < 1:
        return None

    try:
        from PIL import Image
    except ImportError:
        logger.warning("Pillow not installed — candidate crops skipped.")
        return None

    try:
        with Image.open(photo_path) as im:
            im.load()
            W, H = im.size
            left = max(0, min(x, W - 1))
            top = max(0, min(y, H - 1))
            right = min(W, left + w_box)
            bottom = min(H, top + h_box)
            if right <= left or bottom <= top:
                return None

            cropped = im.crop((left, top, right, bottom))
            if cropped.mode == "LA":
                cropped = cropped.convert("RGBA")
            if cropped.mode == "RGBA":
                background = Image.new("RGB", cropped.size, (255, 255, 255))
                background.paste(cropped, mask=cropped.split()[3])
                cropped = background
            elif cropped.mode != "RGB":
                cropped = cropped.convert("RGB")

            buf = BytesIO()
            cropped.save(buf, format="JPEG", quality=92, optimize=True)
            buf.seek(0)
            return ContentFile(buf.read(), name=f"crop_{uuid.uuid4().hex}.jpg")
    except Exception as exc:
        logger.warning("Failed to crop candidate from %s: %s", photo_path, exc)
        return None
