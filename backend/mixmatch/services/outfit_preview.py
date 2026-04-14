"""
Mix Match outfit preview.

Primary: OpenAI `images.edit` with a GPT Image model, passing real wardrobe files as
`image=[...]` plus a preservation prompt (`input_fidelity="high"` only when the model supports it).
Synchronous — no webhooks / ngrok required.

Fallback: PIL vertical stack if `MIX_PREVIEW_USE_OPENAI` is off, no API key, or the call fails.
"""
from __future__ import annotations

import base64
import logging
import os
from collections import defaultdict
from contextlib import ExitStack
from io import BytesIO

from django.conf import settings
from django.core.files.base import ContentFile

logger = logging.getLogger(__name__)

_PREVIEW_W = 720
_PREVIEW_H = 1080
_BG = (245, 243, 240)

# Stack width as fraction of canvas — keeps top & bottom visually one column
_STACK_W_FRAC = 0.58
# How much consecutive body pieces overlap (fraction of the shorter piece height)
_STACK_OVERLAP_FRAC = 0.14
# Outer slightly wider than stack
_OUTER_W_FRAC = 0.64


def compose_outfit_preview(items: list, session_id: int) -> ContentFile | None:
    if not items:
        return None

    slots = _pick_one_per_slot(items)

    if getattr(settings, "MIX_PREVIEW_USE_OPENAI", True) and getattr(settings, "OPENAI_API_KEY", ""):
        try:
            ai_file = _gpt_image_edit_preview(slots, session_id)
            if ai_file is not None:
                return ai_file
        except Exception as exc:
            logger.warning("OpenAI mix preview failed, using PIL fallback: %s", exc)

    try:
        return _compose_vertical_stack_preview(items, session_id)
    except Exception as exc:
        logger.exception("Outfit stack preview failed: %s", exc)
        return None


def _wardrobe_file_path(item) -> str | None:
    try:
        f = item.image
        if not f:
            return None
        path = f.path
    except Exception:
        return None
    return path if path and os.path.isfile(path) else None


def _collect_edit_paths_and_roles(slots: dict) -> tuple[list[str], list[str]]:
    """Ordered file paths + matching prompt lines (Image 1, Image 2, …)."""
    sequence: list[tuple[str, str]] = []

    if slots["dress"]:
        sequence.append(("dress", "DRESS (full garment)"))
    else:
        if slots["top"]:
            sequence.append(("top", "TOP"))
        if slots["bottom"]:
            sequence.append(("bottom", "BOTTOM"))
    if slots["outer"]:
        sequence.append(("outer", "OUTERWEAR"))
    if slots["shoes"]:
        sequence.append(("shoes", "SHOES"))
    if slots["bag"]:
        sequence.append(("bag", "BAG"))
    if slots["accessories"]:
        sequence.append(("accessories", "ACCESSORY"))

    key_to_item = {
        "dress": slots["dress"],
        "top": slots["top"],
        "bottom": slots["bottom"],
        "outer": slots["outer"],
        "shoes": slots["shoes"],
        "bag": slots["bag"],
        "accessories": slots["accessories"],
    }

    paths: list[str] = []
    roles: list[str] = []
    for key, label in sequence:
        it = key_to_item.get(key)
        if it is None:
            continue
        p = _wardrobe_file_path(it)
        if not p:
            continue
        n = len(paths) + 1
        paths.append(p)
        roles.append(
            f"Image {n}: the {label} — exact reference garment; preserve fabric, weave, color, "
            f"shape, stitching, and details; do not redesign or substitute a different item."
        )

    return paths, roles


def _build_gpt_edit_prompt(role_lines: list[str]) -> str:
    joined = "\n".join(role_lines)
    return (
        f"{joined}\n\n"
        "Use the uploaded images in order as the ONLY garment references.\n"
        "Create ONE photorealistic studio photograph showing ONLY the outfit — no person, no model, "
        "no face, no hands, no skin, no hair, no body or limbs visible anywhere.\n"
        "Show the garments as if on an invisible ghost mannequin or hollow mannequin: natural worn "
        "shape and proportions (e.g. top with bottom), but the clothing alone; empty neckline and "
        "sleeves where a body would be, no human figure.\n"
        "Professional soft lighting, neutral plain studio background (no scene, no props except "
        "the listed garments if needed).\n"
        "Preserve the exact garment appearance from each reference — not a flat collage, not a "
        "stacked product mockup, not new invented clothing.\n"
    )


def _gpt_image_edit_preview(slots: dict, session_id: int) -> ContentFile | None:
    paths, role_lines = _collect_edit_paths_and_roles(slots)
    if not paths:
        return None

    from common.openai_client import get_openai_client, image_edit_supports_input_fidelity_high

    client = get_openai_client()
    model = getattr(settings, "OPENAI_MIX_PREVIEW_MODEL", "gpt-image-1.5")
    size = getattr(settings, "OPENAI_MIX_PREVIEW_SIZE", "1024x1536")
    prompt = _build_gpt_edit_prompt(role_lines)

    with ExitStack() as stack:
        files = [stack.enter_context(open(p, "rb")) for p in paths]
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

    if not result.data:
        logger.warning("OpenAI images.edit returned empty data for session #%s", session_id)
        return None

    b64 = result.data[0].b64_json
    if not b64:
        logger.warning("OpenAI images.edit missing b64_json for session #%s", session_id)
        return None

    raw = base64.b64decode(b64)
    logger.info("OpenAI mix preview OK for session #%s (%s bytes).", session_id, len(raw))
    return ContentFile(raw, name=f"mix_preview_{session_id}.jpg")


def _pick_one_per_slot(items: list) -> dict[str, object | None]:
    by_cat: dict[str, list] = defaultdict(list)
    for it in items:
        by_cat[it.category].append(it)
    for cat in by_cat:
        by_cat[cat].sort(key=lambda x: x.pk)

    dress = by_cat["dress"][0] if by_cat["dress"] else None
    if dress:
        top = bottom = None
    else:
        top = by_cat["top"][0] if by_cat["top"] else None
        bottom = by_cat["bottom"][0] if by_cat["bottom"] else None

    return {
        "dress": dress,
        "top": top,
        "bottom": bottom,
        "outer": by_cat["outer"][0] if by_cat["outer"] else None,
        "shoes": by_cat["shoes"][0] if by_cat["shoes"] else None,
        "bag": by_cat["bag"][0] if by_cat["bag"] else None,
        "accessories": by_cat["accessories"][0] if by_cat["accessories"] else None,
    }


def _open_rgba(path: str):
    from PIL import Image

    return Image.open(path).convert("RGBA")


def _load_item_image(item):
    try:
        path = item.image.path
    except Exception:
        return None
    try:
        return _open_rgba(path)
    except Exception as exc:
        logger.warning("Could not open wardrobe image for item #%s: %s", item.pk, exc)
        return None


def _scale_to_width(im, target_w: int):
    from PIL import Image

    iw, ih = im.size
    if iw <= 0 or ih <= 0:
        return im
    if iw == target_w:
        return im
    nh = max(1, int(round(ih * (target_w / iw))))
    return im.resize((target_w, nh), Image.Resampling.LANCZOS)


def _paste_rgba(canvas, im, x: int, y: int) -> None:
    if im.mode == "RGBA":
        canvas.paste(im, (x, y), im)
    else:
        canvas.paste(im.convert("RGB"), (x, y))


def _compose_vertical_stack_preview(items: list, session_id: int) -> ContentFile | None:
    try:
        from PIL import Image
    except ImportError:
        logger.warning("Pillow not installed — outfit preview skipped.")
        return None

    slots = _pick_one_per_slot(items)
    W, H = _PREVIEW_W, _PREVIEW_H
    canvas = Image.new("RGB", (W, H), _BG)

    stack_w = int(W * _STACK_W_FRAC)
    x_center = W // 2

    # --- Build main column: bottom → top (paint order), positions top-above-bottom with overlap ---
    dress = slots["dress"]
    top_item = slots["top"]
    bottom_item = slots["bottom"]

    stack_boxes: list[tuple[int, int, int, int]] = []  # (x,y,w,h) per pasted layer for outer/shoes

    if dress is not None:
        im = _load_item_image(dress)
        if im is not None:
            im = _scale_to_width(im, stack_w)
            max_h = int(H * 0.88)
            if im.height > max_h:
                scale = max_h / im.height
                nw = max(1, int(im.width * scale))
                nh = max(1, int(im.height * scale))
                im = im.resize((nw, nh), Image.Resampling.LANCZOS)
            x = x_center - im.width // 2
            y = (H - im.height) // 2
            _paste_rgba(canvas, im, x, y)
            stack_boxes.append((x, y, im.width, im.height))
    else:
        loaded: list[tuple[str, object]] = []
        if bottom_item is not None:
            bim = _load_item_image(bottom_item)
            if bim is not None:
                loaded.append(("bottom", _scale_to_width(bim, stack_w)))
        if top_item is not None:
            tim = _load_item_image(top_item)
            if tim is not None:
                loaded.append(("top", _scale_to_width(tim, stack_w)))

        if not loaded:
            pass
        elif len(loaded) == 1:
            _role, im = loaded[0]
            x = x_center - im.width // 2
            y = (H - im.height) // 2
            _paste_rgba(canvas, im, x, y)
            stack_boxes.append((x, y, im.width, im.height))
        else:
            # Order in list: we appended bottom then top → paint bottom first, then top overlapping down
            bottom_im = loaded[0][1]
            top_im = loaded[1][1]
            overlap = int(
                min(bottom_im.height, top_im.height) * _STACK_OVERLAP_FRAC
            )
            stack_h = top_im.height + bottom_im.height - overlap
            y0 = (H - stack_h) // 2
            y_top = y0
            y_bottom = y0 + top_im.height - overlap
            x_top = x_center - top_im.width // 2
            x_bot = x_center - bottom_im.width // 2
            _paste_rgba(canvas, bottom_im, x_bot, y_bottom)
            _paste_rgba(canvas, top_im, x_top, y_top)
            stack_boxes.append((x_bot, y_bottom, bottom_im.width, bottom_im.height))
            stack_boxes.append((x_top, y_top, top_im.width, top_im.height))

    if not stack_boxes and slots["outer"] is None and slots["shoes"] is None:
        if slots["bag"] is None and slots["accessories"] is None:
            return None

    # Bounding box of the outfit column (for outer placement)
    if stack_boxes:
        min_x = min(b[0] for b in stack_boxes)
        min_y = min(b[1] for b in stack_boxes)
        max_x = max(b[0] + b[2] for b in stack_boxes)
        max_y = max(b[1] + b[3] for b in stack_boxes)
    else:
        min_x, min_y = int(W * 0.2), int(H * 0.15)
        max_x, max_y = int(W * 0.8), int(H * 0.75)

    # --- Outer: wider, centered, over torso (upper 2/3 of stack) ---
    if slots["outer"] is not None:
        oim = _load_item_image(slots["outer"])
        if oim is not None:
            ow = int(W * _OUTER_W_FRAC)
            oim = _scale_to_width(oim, ow)
            ox = x_center - oim.width // 2
            # Anchor upper body: align top of outer slightly above stack top
            oy = min_y - int(H * 0.02)
            if oy + oim.height > H - 8:
                oy = H - 8 - oim.height
            if oy < 4:
                oy = 4
            _paste_rgba(canvas, oim, ox, oy)

    # --- Shoes: under stack, slight upward overlap into pant hem ---
    if slots["shoes"] is not None and stack_boxes:
        sim = _load_item_image(slots["shoes"])
        if sim is not None:
            shoe_w = int(stack_w * 0.92)
            sim = _scale_to_width(sim, shoe_w)
            sx = x_center - sim.width // 2
            overlap_foot = int(min(sim.height, 80) * 0.25)
            sy = max_y - overlap_foot
            if sy + sim.height > H - 6:
                sy = H - 6 - sim.height
            if sy < max_y - int(sim.height * 0.55):
                sy = max_y - int(sim.height * 0.55)
            _paste_rgba(canvas, sim, sx, sy)

    # --- Bag / accessory: corners, small ---
    acc_w = int(W * 0.22)
    if slots["bag"] is not None:
        bim = _load_item_image(slots["bag"])
        if bim is not None:
            bim = _scale_to_width(bim, acc_w)
            _paste_rgba(canvas, bim, W - bim.width - 16, 24)
    if slots["accessories"] is not None:
        aim = _load_item_image(slots["accessories"])
        if aim is not None:
            aim = _scale_to_width(aim, acc_w)
            left_x = 16 if slots["bag"] is not None else W - aim.width - 16
            _paste_rgba(canvas, aim, left_x, 24)

    buf = BytesIO()
    canvas.save(buf, format="JPEG", quality=90, optimize=True)
    buf.seek(0)
    return ContentFile(buf.read(), name=f"mix_preview_{session_id}.jpg")
