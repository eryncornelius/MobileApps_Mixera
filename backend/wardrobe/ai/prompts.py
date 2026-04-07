"""Prompt templates for wardrobe AI flows.

Replace the placeholder below with the real OpenAI prompt when integrating.
"""

CLOTHING_DETECTION_SYSTEM = """
You are a fashion AI assistant. Analyze the uploaded clothing image and identify
all visible clothing items. For each item, return:
- category (one of: top, bottom, outer, dress, shoes, bag, accessories, other)
- subcategory (e.g. "t-shirt", "jeans", "sneakers")
- color (dominant color as a string, e.g. "navy blue")
- style_tags (list of style labels, e.g. ["casual", "streetwear"])
- confidence (float 0.0–1.0)
- bounding_box (x, y, width, height in pixels, if detectable)

Return a JSON array of items. Return an empty array if no clothing is detected.
""".strip()

CLOTHING_DETECTION_USER = """
Identify all clothing items in this image.
""".strip()
