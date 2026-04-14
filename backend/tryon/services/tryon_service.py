"""Virtual try-on service — create requests and run generation."""
import logging
import os
import tempfile
import urllib.request

from django.core.files.base import ContentFile
from django.shortcuts import get_object_or_404

from tryon.models import PersonProfileImage, RequestStatus, TryOnRequest, TryOnResult, TryOnSourceType

logger = logging.getLogger(__name__)

_PLACEHOLDER_NOTES = (
    "Your try-on preview has been queued. "
    "Real virtual try-on generation will be available in a future update."
)


def create_tryon_request(
    *,
    user,
    person_image_id: int,
    source_type: str,
    mix_result_id: int | None = None,
    shop_product_id: int | None = None,
) -> TryOnRequest:
    """
    Validate inputs and create a TryOnRequest, then run generation.

    Ownership rules:
      - person_image must belong to the user
      - mix_result (if used) must belong to the user's session
      - shop_product (if used) must exist and be active (public catalog — no user ownership)

    Args:
        user:             The requesting user.
        person_image_id:  PK of the PersonProfileImage to use.
        source_type:      One of TryOnSourceType values.
        mix_result_id:    Required when source_type == 'mix_result'.
        shop_product_id:  Required when source_type == 'shop_product'.

    Returns:
        Created TryOnRequest (status will be completed after placeholder run).

    Raises:
        Http404 if referenced objects are not found or not accessible.
    """
    person_image = get_object_or_404(
        PersonProfileImage, pk=person_image_id, user=user, is_archived=False
    )

    mix_result = None
    shop_product = None

    if source_type == TryOnSourceType.MIX_RESULT:
        from mixmatch.models import MixResult
        mix_result = get_object_or_404(MixResult, pk=mix_result_id, session__user=user)

    elif source_type == TryOnSourceType.SHOP_PRODUCT:
        from shop.models import Product
        shop_product = get_object_or_404(Product, pk=shop_product_id, is_active=True)

    request = TryOnRequest.objects.create(
        user=user,
        person_image=person_image,
        source_type=source_type,
        mix_result=mix_result,
        shop_product=shop_product,
        status=RequestStatus.PENDING,
    )

    _run_generation(request)
    return request


# ---------------------------------------------------------------------------
# Generation (placeholder + future provider hook)
# ---------------------------------------------------------------------------

def _run_generation(request: TryOnRequest) -> None:
    """
    Attempt real try-on generation; fall back to placeholder result.
    Updates request status and creates TryOnResult in all cases.
    """
    request.status = RequestStatus.PROCESSING
    request.error_message = ""
    request.save(update_fields=["status", "error_message", "updated_at"])

    provider_output = None
    notes = _PLACEHOLDER_NOTES

    try:
        provider_output, notes = _call_tryon_provider(request)
        request.status = RequestStatus.COMPLETED
    except NotImplementedError:
        request.status = RequestStatus.COMPLETED
        logger.info("Try-on placeholder used for request #%s.", request.pk)
    except Exception as exc:
        request.status = RequestStatus.FAILED
        notes = f"Generation failed: {exc}"
        request.error_message = str(exc)[:2000]
        logger.warning("Try-on generation failed for request #%s: %s", request.pk, exc)
    finally:
        update_fields = ["status", "updated_at"]
        if request.error_message:
            update_fields.append("error_message")
        request.save(update_fields=update_fields)

    final_image = _normalize_provider_result(provider_output)

    if request.status == RequestStatus.COMPLETED and not final_image:
        try:
            final_image = _person_image_as_placeholder_content(request)
            notes = (
                "Preview placeholder: menampilkan foto tubuh Anda sampai integrasi "
                "model virtual try-on (AI) selesai — hasil final akan menggantikan ini."
            )
        except Exception as exc:
            logger.exception(
                "Could not create try-on placeholder for request #%s: %s",
                request.pk,
                exc,
            )
            request.status = RequestStatus.FAILED
            msg = f"Could not produce a usable result image: {exc}"
            request.error_message = msg
            notes = msg
            request.save(update_fields=["status", "error_message", "updated_at"])
            final_image = None

    TryOnResult.objects.create(
        request=request,
        result_image=final_image,
        notes=notes,
    )


def _normalize_provider_result(val) -> ContentFile | None:
    """Convert provider output (filesystem path or None) into a storable file."""
    if val is None:
        return None
    if isinstance(val, ContentFile):
        return val
    path = str(val)
    if os.path.isfile(path):
        with open(path, "rb") as fh:
            data = fh.read()
        name = os.path.basename(path) or "tryon_result.jpg"
        return ContentFile(data, name=name)
    logger.warning("Try-on provider returned unusable path: %s", path)
    return None


def _person_image_as_placeholder_content(request: TryOnRequest) -> ContentFile:
    """Return an in-memory copy of the person image for placeholder try-on results."""
    with request.person_image.image.open("rb") as fh:
        raw = fh.read()
    base = os.path.basename(request.person_image.image.name)
    ext = os.path.splitext(base)[1] or ".jpg"
    return ContentFile(raw, name=f"tryon_placeholder_{request.pk}{ext}")


def _call_tryon_provider(request: TryOnRequest) -> tuple[str | ContentFile | None, str]:
    from tryon.ai.client import TryOnAIClient

    outfit_description = _build_outfit_description(request)
    person_image_path = request.person_image.image.path

    temp_files: list[str] = []
    try:
        outfit_paths, temp_files = _resolve_outfit_reference_paths_with_temps(request)
        client = TryOnAIClient()
        result = client.generate_tryon(
            person_image_path,
            outfit_description,
            outfit_image_paths=outfit_paths if outfit_paths else None,
        )
        if result is None:
            raise NotImplementedError("Provider returned no result.")
        return (
            result,
            "Virtual try-on generated from your photo and outfit reference image(s).",
        )
    finally:
        for p in temp_files:
            try:
                os.unlink(p)
            except OSError:
                pass


def _resolve_outfit_reference_paths_with_temps(request: TryOnRequest) -> tuple[list[str], list[str]]:
    """
    Local filesystem paths for outfit reference images.

    Returns:
        (paths, temp_paths_to_delete) — temp paths are from downloaded shop catalog images.
    """
    temps: list[str] = []
    paths: list[str] = []

    if request.source_type == TryOnSourceType.MIX_RESULT and request.mix_result:
        mr = request.mix_result
        try:
            if mr.preview_image:
                p = mr.preview_image.path
                if os.path.isfile(p):
                    paths.append(p)
        except Exception as exc:
            logger.debug("Mix preview_image unavailable: %s", exc)

        if not paths:
            from mixmatch.services.outfit_preview import (
                _collect_edit_paths_and_roles,
                _pick_one_per_slot,
            )
            from mixmatch.services.result_service import resolve_best_outfit_candidate

            pool = list(mr.session.selected_items.all())
            items = resolve_best_outfit_candidate(pool) if pool else []
            if items:
                extra, _ = _collect_edit_paths_and_roles(_pick_one_per_slot(items))
                paths.extend(extra)

        return paths, temps

    if request.source_type == TryOnSourceType.SHOP_PRODUCT and request.shop_product:
        tmp = _download_primary_product_image_temp(request.shop_product)
        if tmp:
            paths.append(tmp)
            temps.append(tmp)
        return paths, temps

    return paths, temps


def _download_primary_product_image_temp(product) -> str | None:
    """Download primary (or first) catalog image to a temp file; caller must unlink."""
    img = product.images.filter(is_primary=True).first()
    if img is None:
        img = product.images.first()
    if img is None or not getattr(img, "image_url", "").strip():
        return None

    url = img.image_url.strip()
    if not url.startswith(("http://", "https://")):
        logger.warning("Shop product image URL not http(s): %s", url[:80])
        return None

    low = url.lower().split("?")[0]
    suffix = ".jpg"
    if low.endswith(".png"):
        suffix = ".png"
    elif low.endswith(".webp"):
        suffix = ".webp"

    fd, path = tempfile.mkstemp(suffix=suffix)
    os.close(fd)
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "MixeraTryOn/1.0"})
        with urllib.request.urlopen(req, timeout=45) as resp:  # noqa: S310
            data = resp.read()
        with open(path, "wb") as f:
            f.write(data)
        return path
    except Exception as exc:
        logger.warning("Failed to download product image for try-on: %s", exc)
        try:
            os.unlink(path)
        except OSError:
            pass
        return None


def _build_outfit_description(request: TryOnRequest) -> str:
    """Build a plain-text outfit description for the try-on provider."""

    if request.source_type == TryOnSourceType.SHOP_PRODUCT and request.shop_product:
        product = request.shop_product
        desc = product.name
        if product.color:
            desc += f" in {product.color}"
        return f"Shop product: {desc}."

    if request.source_type == TryOnSourceType.MIX_RESULT and request.mix_result:
        from mixmatch.services.result_service import resolve_best_outfit_candidate

        pool = list(request.mix_result.session.selected_items.all())
        items = resolve_best_outfit_candidate(pool)
        if not items:
            return "Empty outfit selection."
        parts = []
        for item in items:
            d = item.category
            if item.subcategory:
                d += f" ({item.subcategory})"
            if item.color:
                d += f" in {item.color}"
            parts.append(d)
        style = request.mix_result.style_label
        return f"{style} outfit: " + ", ".join(parts) + "."

    return "No outfit specified."
