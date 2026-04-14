"""Mix result service — rule-based generation with AI enrichment and fallback."""
import logging
from collections import defaultdict

from django.core.exceptions import ValidationError

from mixmatch.models import MixResult, MixSession, SessionStatus

logger = logging.getLogger(__name__)

_EXTRA_CATEGORIES = ("outer", "shoes", "bag", "accessories", "other")

# ---------------------------------------------------------------------------
# Style detection
# ---------------------------------------------------------------------------

_STYLE_KEYWORD_MAP = {
    "casual": ["casual", "everyday", "relaxed", "streetwear", "basic"],
    "formal": ["formal", "office", "business", "smart", "elegant"],
    "sporty": ["sport", "athletic", "gym", "active", "outdoor"],
    "chic": ["chic", "fashion", "trendy", "stylish", "luxury"],
    "vintage": ["vintage", "retro", "classic", "old-school"],
}


def _detect_style_label(items) -> str:
    """Vote on style label from combined style_tags of all items."""
    all_tags = []
    for item in items:
        tags = item.style_tags or []
        all_tags.extend(t.lower() for t in tags)

    # Special case: dress often signals chic/feminine
    has_dress = any(item.category == "dress" for item in items)
    if has_dress and not all_tags:
        return "Chic"

    votes: dict[str, int] = {style: 0 for style in _STYLE_KEYWORD_MAP}
    for tag in all_tags:
        for style, keywords in _STYLE_KEYWORD_MAP.items():
            if any(kw in tag for kw in keywords):
                votes[style] += 1

    if any(v > 0 for v in votes.values()):
        return max(votes, key=votes.get).capitalize()

    return "Balanced"


# ---------------------------------------------------------------------------
# Score computation
# ---------------------------------------------------------------------------

_COMPLETENESS_BONUS = {
    "outer": 10,
    "shoes": 10,
    "bag": 5,
    "accessories": 5,
}


def _compute_score(items) -> int:
    """
    Score outfit completeness (0–100).

    Base: 50 (guaranteed by having top + bottom).
    Bonuses for additional item categories.
    Color coherence bonus: up to 10 pts for a limited palette.
    """
    categories = {item.category for item in items}

    score = 50
    for cat, bonus in _COMPLETENESS_BONUS.items():
        if cat in categories:
            score += bonus

    # Color coherence: reward fewer distinct colors
    colors = [item.color.strip().lower() for item in items if item.color.strip()]
    if colors:
        unique_colors = len(set(colors))
        if unique_colors == 1:
            score += 10
        elif unique_colors == 2:
            score += 7
        elif unique_colors == 3:
            score += 3

    return min(score, 100)


def _refine_extras(base: list, by_cat: dict, categories: tuple[str, ...]) -> list:
    """Append at most one item per category, picking the option that maximizes outfit score."""
    out = list(base)
    for cat in categories:
        options = by_cat.get(cat) or []
        if not options:
            continue
        if len(options) == 1:
            out.append(options[0])
            continue
        best_opt = None
        best_key = None
        for opt in options:
            cand = out + [opt]
            sc = _compute_score(cand)
            key = (sc, -opt.pk)
            if best_key is None or key > best_key:
                best_key = key
                best_opt = opt
        if best_opt is not None:
            out.append(best_opt)
    return out


def resolve_best_outfit_candidate(all_items: list) -> list:
    """
    From the user's selection (possibly multiple tops/bottoms/dresses), pick ONE outfit.

    - If any dress: choose the dress + best extras; ignore extra tops/bottoms for this outfit.
    - Else: choose the (top, bottom) pair with highest rule score, then best outer/shoes/bag/etc.
    - Deterministic tie-break: higher score, then lower sum of primary garment pks.
    """
    if not all_items:
        return []

    by_cat: dict[str, list] = defaultdict(list)
    for it in all_items:
        by_cat[it.category].append(it)
    for cat in by_cat:
        by_cat[cat].sort(key=lambda x: x.pk)

    if by_cat["dress"]:
        best_out = None
        best_key = None
        for d in by_cat["dress"]:
            cand = [d] + _refine_extras([d], by_cat, _EXTRA_CATEGORIES)
            sc = _compute_score(cand)
            key = (sc, -d.pk)
            if best_key is None or key > best_key:
                best_key = key
                best_out = cand
        return best_out or list(all_items)

    tops = by_cat["top"]
    bottoms = by_cat["bottom"]
    if not tops or not bottoms:
        return list(all_items)

    best_pair = None
    best_key = None
    for t in tops:
        for b in bottoms:
            base = [t, b]
            sc = _compute_score(base)
            key = (sc, (-(t.pk + b.pk), (t.pk, b.pk)))
            if best_key is None or key > best_key:
                best_key = key
                best_pair = base

    if not best_pair:
        return list(all_items)

    return _refine_extras(best_pair, by_cat, _EXTRA_CATEGORIES)


# ---------------------------------------------------------------------------
# Explanation builder
# ---------------------------------------------------------------------------

def _build_explanation(items, style_label: str, score: int) -> str:
    categories = sorted({item.category for item in items})
    category_str = ", ".join(categories)
    colors = [item.color.strip() for item in items if item.color.strip()]
    unique_colors = sorted(set(c.lower() for c in colors))

    parts = [
        f"This {style_label.lower()} outfit combines {category_str}.",
    ]

    if unique_colors:
        if len(unique_colors) <= 2:
            parts.append(
                f"The color palette ({', '.join(unique_colors)}) creates a cohesive look."
            )
        else:
            parts.append(
                f"The mix uses {len(unique_colors)} colors — consider simplifying the palette for a cleaner look."
            )

    if score >= 80:
        parts.append("Overall a well-rounded and complete outfit.")
    elif score >= 60:
        parts.append("A solid combination with room for accessories.")
    else:
        parts.append("A minimal outfit — add shoes or an outer layer to complete it.")

    return " ".join(parts)


# ---------------------------------------------------------------------------
# AI enrichment (optional, with fallback)
# ---------------------------------------------------------------------------

def _enrich_with_ai(
    *,
    items: list,
    score: int,
    fallback_style: str,
    fallback_explanation: str,
) -> tuple[str, str, str]:
    """
    Attempt to enrich style_label, explanation, and tips via OpenAI.

    Returns:
        (style_label, explanation, tips) — either from AI or from fallback values.
    """
    try:
        from mixmatch.ai.client import MixmatchAIClient
        ai_result = MixmatchAIClient().analyze_outfit(items, score)
        style_label = ai_result.style_label or fallback_style
        explanation = ai_result.explanation or fallback_explanation
        tips = ai_result.tips or ""
        logger.debug(
            "AI enrichment succeeded: style=%s, tips=%s",
            style_label, bool(tips),
        )
        return style_label, explanation, tips
    except Exception as exc:
        logger.warning("AI outfit enrichment failed, using rule-based fallback: %s", exc)
        return fallback_style, fallback_explanation, ""


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

def generate_mix_result(*, session: MixSession) -> MixResult:
    """
    Run rule-based outfit analysis and create a MixResult.

    Args:
        session: MixSession in ITEMS_SELECTED state.

    Returns:
        Created MixResult instance.

    Raises:
        ValidationError if session is not in ITEMS_SELECTED state,
        or if a result already exists.
    """
    if session.status != SessionStatus.ITEMS_SELECTED:
        raise ValidationError(
            f"Cannot generate result for session with status '{session.status}'. "
            "Session must have items selected first."
        )

    if hasattr(session, "result"):
        raise ValidationError(
            "A result has already been generated for this session."
        )

    try:
        pool = list(session.selected_items.all())
        items = resolve_best_outfit_candidate(pool)

        # Step 1: Rule-based scoring — always runs, never fails (single best outfit).
        score = _compute_score(items)
        style_label = _detect_style_label(items)
        explanation = _build_explanation(items, style_label, score)
        if len(pool) > len(items):
            explanation = (
                f"From your {len(pool)} selected pieces, this is the strongest single outfit. "
                + explanation
            )
        tips = ""

        # Step 2: AI enrichment — optional, falls back silently.
        style_label, explanation, tips = _enrich_with_ai(
            items=items,
            score=score,
            fallback_style=style_label,
            fallback_explanation=explanation,
        )

        preview_file = None
        try:
            from mixmatch.services.outfit_preview import compose_outfit_preview

            preview_file = compose_outfit_preview(items, session.pk)
        except Exception as exc:
            logger.warning("Outfit preview step failed (continuing without image): %s", exc)

        result = MixResult.objects.create(
            session=session,
            style_label=style_label,
            explanation=explanation,
            tips=tips,
            score=score,
            is_saved=False,
            preview_image=preview_file,
        )

        session.status = SessionStatus.COMPLETED
        session.save(update_fields=["status", "updated_at"])

        return result

    except Exception as exc:
        session.status = SessionStatus.FAILED
        session.save(update_fields=["status", "updated_at"])
        raise ValidationError(f"Generation failed: {exc}") from exc


def toggle_save_result(*, result: MixResult) -> MixResult:
    """Toggle is_saved on a MixResult and return the updated instance."""
    result.is_saved = not result.is_saved
    result.save(update_fields=["is_saved"])
    return result
