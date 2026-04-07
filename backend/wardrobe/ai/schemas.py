"""Schema definitions for wardrobe AI payloads.

These dataclasses define the shape of data flowing between the AI client
and the detection service. Keep them in sync with DetectedItemCandidate fields.
"""
from dataclasses import dataclass, field
from typing import Optional


@dataclass
class BoundingBox:
    x: int
    y: int
    width: int
    height: int


@dataclass
class CandidateResult:
    """One detected clothing item from an uploaded photo."""
    category: str           # must match ClothingCategory values
    subcategory: str = ""
    color: str = ""
    style_tags: list = field(default_factory=list)
    confidence: Optional[float] = None
    bounding_box: Optional[BoundingBox] = None
    raw_response: Optional[dict] = None

    def bounding_box_dict(self) -> Optional[dict]:
        if self.bounding_box is None:
            return None
        return {
            "x": self.bounding_box.x,
            "y": self.bounding_box.y,
            "width": self.bounding_box.width,
            "height": self.bounding_box.height,
        }
