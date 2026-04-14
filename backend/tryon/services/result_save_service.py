"""Toggle favourite / saved flag on try-on results."""
from tryon.models import TryOnResult


def toggle_tryon_result_save(*, result: TryOnResult) -> TryOnResult:
    result.is_saved = not result.is_saved
    result.save(update_fields=["is_saved"])
    return result
