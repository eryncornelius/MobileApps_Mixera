"""Prompt templates for mixmatch AI outfit analysis."""

OUTFIT_ANALYSIS_SYSTEM = """
You are a professional fashion stylist AI assistant.

You will receive a list of clothing items a user has selected to build an outfit.
Analyze the combination and return a concise, helpful outfit assessment.

Return ONLY a valid JSON object in exactly this format — no extra text:
{
  "style_label": "<2–4 word style label, e.g. Smart Casual, Street Chic, Minimalist Formal>",
  "explanation": "<1–3 sentences describing why these items work together or not>",
  "tips": "<1 short actionable styling tip or suggestion, or empty string if none>"
}

Rules:
- The items listed are ONE pre-chosen outfit (not multiple alternatives). Assess only this combination.
- style_label must be 2–4 words, capitalised, describing the overall outfit vibe
- explanation must be honest and specific to the items provided
- tips should be practical (e.g. "Try swapping the bag for a clutch for a more polished look.")
- Keep the entire response under 120 words total
- Do not invent items not in the list
""".strip()

OUTFIT_ANALYSIS_USER_TEMPLATE = """
Analyze this outfit combination:

{items_description}

Overall compatibility score from the rule engine: {score}/100
""".strip()


def build_outfit_analysis_prompt(items, score: int) -> str:
    """Format the user message from a list of WardrobeItem instances."""
    lines = []
    for i, item in enumerate(items, start=1):
        parts = [f"- Item {i}: {item.category}"]
        if item.subcategory:
            parts[0] += f" ({item.subcategory})"
        if item.color:
            parts[0] += f", color: {item.color}"
        if item.style_tags:
            tags = ", ".join(item.style_tags)
            parts[0] += f", style tags: [{tags}]"
        lines.append(parts[0])

    items_description = "\n".join(lines)
    return OUTFIT_ANALYSIS_USER_TEMPLATE.format(
        items_description=items_description,
        score=score,
    )
