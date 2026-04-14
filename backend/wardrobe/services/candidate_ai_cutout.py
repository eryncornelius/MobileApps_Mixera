"""
Per-candidate garment isolation via OpenAI ``images.edit`` (GPT Image family).

Same API as mix / try-on (``client.images.edit``). Default is ``gpt-image-1.5`` (quality,
supports ``input_fidelity='high'``). Set ``OPENAI_WARDROBE_CUTOUT_MODEL=gpt-image-1-mini`` to save cost.
Chat-only IDs (e.g. ``gpt-5.4``) are not valid here.

Tries PNG + transparent background first, then JPEG + white studio background. On any
failure returns None so callers can fall back to bbox PIL crops.
"""
from __future__ import annotations

import base64
import logging
import os
import uuid
from contextlib import ExitStack

from django.conf import settings
from django.core.files.base import ContentFile

logger = logging.getLogger(__name__)


def _cutout_prompt_opaque(
    *,
    category: str,
    subcategory: str,
    color: str,
    bounding_box: dict | None,
) -> str:
    hint = ""
    if bounding_box and isinstance(bounding_box, dict):
        hint = (
            "\nThe garment to extract is approximately inside this pixel box "
            f"(origin top-left): x={bounding_box.get('x')}, y={bounding_box.get('y')}, "
            f"width={bounding_box.get('width')}, height={bounding_box.get('height')}."
        )
    desc = f"type **{category}**"
    if subcategory.strip():
        desc += f", subtype **{subcategory.strip()}**"
    if color.strip():
        desc += f", dominant color **{color.strip()}**"
    return (
        "Image 1 is a real photograph; it may show a person and/or several clothing pieces.\n"
        f"Produce ONE output image showing ONLY the single clothing item: {desc}.{hint}\n"
        "Remove every other garment, person, face, hair, skin, hands, and unrelated props. "
        "The result must be just that one garment, shown clearly (flat lay or ghost mannequin), "
        "with faithful fabric, pattern, cut, and color from the reference.\n"
        "Use a solid pure white (#ffffff) background filling the entire frame. "
        "Tight framing on the garment; no collage, borders, captions, or logos.\n"
    )


def _cutout_prompt_transparent(
    *,
    category: str,
    subcategory: str,
    color: str,
    bounding_box: dict | None,
) -> str:
    # Same isolation goal; ask for alpha (API: background=transparent + output_format=png).
    base = _cutout_prompt_opaque(
        category=category,
        subcategory=subcategory,
        color=color,
        bounding_box=bounding_box,
    )
    return base.replace(
        "Use a solid pure white (#ffffff) background filling the entire frame.",
        "Use a fully transparent background (alpha channel) with no floor, wall, or backdrop.",
    )


def _images_edit_one(
    *,
    photo_path: str,
    prompt: str,
    model: str,
    size: str,
    output_format: str,
    extra_edit_kwargs: dict,
) -> ContentFile | None:
    from common.openai_client import get_openai_client, image_edit_supports_input_fidelity_high

    client = get_openai_client()
    with ExitStack() as stack:
        img_file = stack.enter_context(open(photo_path, "rb"))
        edit_kw: dict = dict(
            model=model,
            image=[img_file],
            prompt=prompt,
            size=size,
            output_format=output_format,
            n=1,
        )
        edit_kw.update(extra_edit_kwargs)
        if image_edit_supports_input_fidelity_high(model):
            try:
                result = client.images.edit(**edit_kw, input_fidelity="high")
            except TypeError:
                result = client.images.edit(**edit_kw)
        else:
            result = client.images.edit(**edit_kw)

    if not result.data or not result.data[0].b64_json:
        logger.warning("OpenAI images.edit returned no image data for wardrobe cutout.")
        return None

    raw = base64.b64decode(result.data[0].b64_json)
    suffix = "png" if output_format == "png" else "jpg"
    name = f"wardrobe_cutout_{uuid.uuid4().hex}.{suffix}"
    logger.info("Wardrobe AI cutout OK (%s bytes, %s).", len(raw), suffix)
    return ContentFile(raw, name=name)


def try_ai_garment_cutout(
    photo_path: str,
    *,
    category: str,
    subcategory: str = "",
    color: str = "",
    bounding_box: dict | None = None,
) -> ContentFile | None:
    """
    Return an image file for ``DetectedItemCandidate.cropped_image``, or None to fall back.
    """
    if not getattr(settings, "WARDROBE_CUTOUT_USE_OPENAI", True):
        return None
    if not getattr(settings, "OPENAI_API_KEY", ""):
        return None
    if not photo_path or not os.path.isfile(photo_path):
        return None

    model = getattr(settings, "OPENAI_WARDROBE_CUTOUT_MODEL", "gpt-image-1.5")
    size = getattr(settings, "OPENAI_WARDROBE_CUTOUT_SIZE", "1024x1024")

    # 1) True cutout: PNG + transparent (matches OpenAI ``background`` on edits API).
    try:
        prompt_t = _cutout_prompt_transparent(
            category=category,
            subcategory=subcategory,
            color=color,
            bounding_box=bounding_box,
        )
        extra: dict = {"background": "transparent"}
        cf = _images_edit_one(
            photo_path=photo_path,
            prompt=prompt_t,
            model=model,
            size=size,
            output_format="png",
            extra_edit_kwargs=extra,
        )
        if cf is not None:
            return cf
    except Exception as exc:
        logger.warning("Wardrobe AI cutout (png/transparent) failed: %s", exc)

    # 2) Same stack as mix / try-on: JPEG studio (opaque).
    try:
        prompt_j = _cutout_prompt_opaque(
            category=category,
            subcategory=subcategory,
            color=color,
            bounding_box=bounding_box,
        )
        cf = _images_edit_one(
            photo_path=photo_path,
            prompt=prompt_j,
            model=model,
            size=size,
            output_format="jpeg",
            extra_edit_kwargs={"quality": "high"},
        )
        if cf is not None:
            return cf
    except Exception as exc:
        logger.warning("Wardrobe AI cutout (jpeg) failed: %s", exc)

    return None
