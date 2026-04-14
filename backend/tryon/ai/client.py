"""Virtual try-on via OpenAI Images Edit (gpt-image-1.5) when enabled.

Passes the person photo plus outfit reference image(s): mix `preview_image` and/or
garment files resolved by the service. Falls back to None → placeholder in tryon_service.
"""
from __future__ import annotations

import base64
import logging
from contextlib import ExitStack
from typing import Optional

from django.conf import settings
from django.core.files.base import ContentFile

logger = logging.getLogger(__name__)


class TryOnAIClient:
    """Try-on using `images.edit` with person + outfit reference images."""

    def generate_tryon(
        self,
        person_image_path: str,
        outfit_description: str,
        outfit_image_paths: Optional[list[str]] = None,
    ) -> ContentFile | str | None:
        """
        Generate a virtual try-on image.

        Args:
            person_image_path: Absolute path to the user's body/pose photo.
            outfit_description: Text context (garment names / style) for the model.
            outfit_image_paths: Local paths to outfit reference(s), e.g. mix preview
                composite and/or wardrobe photos. Required for the OpenAI path.

        Returns:
            ContentFile with JPEG bytes, or a filesystem path string, or None to use placeholder.
        """
        paths = outfit_image_paths or []
        if not paths:
            logger.info("Try-on: no outfit image paths — skipping OpenAI.")
            return None

        if not getattr(settings, "TRYON_USE_OPENAI", True):
            logger.info("TRYON_USE_OPENAI is disabled.")
            return None

        if not getattr(settings, "OPENAI_API_KEY", ""):
            logger.info("OPENAI_API_KEY missing — skipping try-on generation.")
            return None

        try:
            return self._openai_image_edit_tryon(
                person_image_path,
                outfit_description,
                paths,
            )
        except NotImplementedError:
            logger.info("Try-on OpenAI path not available.")
            return None
        except Exception as exc:
            logger.warning("Try-on OpenAI call failed: %s", exc)
            return None

    def _openai_image_edit_tryon(
        self,
        person_image_path: str,
        outfit_description: str,
        outfit_paths: list[str],
    ) -> ContentFile:
        import os

        from common.openai_client import get_openai_client, image_edit_supports_input_fidelity_high

        if not os.path.isfile(person_image_path):
            raise FileNotFoundError(f"Person image not found: {person_image_path}")

        for p in outfit_paths:
            if not os.path.isfile(p):
                raise FileNotFoundError(f"Outfit reference not found: {p}")

        model = getattr(settings, "OPENAI_TRYON_MODEL", "gpt-image-1.5")
        size = getattr(settings, "OPENAI_TRYON_SIZE", "1024x1536")

        role_lines = [
            "Image 1: the PERSON — preserve their identity, face, body shape, skin tone, pose, and framing. "
            "Do not replace them with a different model.",
        ]
        for i, _p in enumerate(outfit_paths, start=2):
            role_lines.append(
                f"Image {i}: OUTFIT reference — use these exact garments (fabric, color, cut) for virtual try-on "
                f"on the person from image 1. Natural fit and drape; coherent lighting with the person photo."
            )

        ctx = f"\nAdditional context: {outfit_description.strip()}\n" if outfit_description.strip() else ""
        prompt = (
            "\n".join(role_lines)
            + ctx
            + "\nProduce ONE photorealistic full-image virtual try-on result. "
            "The person from image 1 must appear wearing the outfit from the reference image(s). "
            "No ghost mannequin for the final result — a real person wearing the clothes.\n"
        )

        client = get_openai_client()
        # API order: person first, then outfit reference(s)
        ordered_paths = [person_image_path, *outfit_paths]

        with ExitStack() as stack:
            files = [stack.enter_context(open(p, "rb")) for p in ordered_paths]
            edit_kw = dict(
                model=model,
                image=files,
                prompt=prompt,
                size=size,
                output_format="jpeg",
                quality="high",
                n=1,
            )
            if image_edit_supports_input_fidelity_high(model):
                try:
                    result = client.images.edit(**edit_kw, input_fidelity="high")
                except TypeError:
                    result = client.images.edit(**edit_kw)
            else:
                result = client.images.edit(**edit_kw)

        if not result.data or not result.data[0].b64_json:
            raise RuntimeError("OpenAI images.edit returned no image data for try-on.")

        raw = base64.b64decode(result.data[0].b64_json)
        logger.info("OpenAI try-on OK (%s bytes).", len(raw))
        return ContentFile(raw, name="tryon_result.jpg")
