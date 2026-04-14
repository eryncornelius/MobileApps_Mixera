"""Person profile image service — upload and manage person photos."""
from django.core.exceptions import ValidationError
from django.db import transaction

from tryon.models import PersonProfileImage


def upload_person_image(
    *,
    user,
    image_file,
    label: str = "",
    set_active: bool = False,
) -> PersonProfileImage:
    """
    Save a new person profile image for the user.

    Args:
        user:       The owning user.
        image_file: Uploaded image file object.
        label:      Optional descriptive name (e.g. "Summer look").
        set_active: If True, activate this image and deactivate all others.

    Returns:
        Created PersonProfileImage instance.
    """
    with transaction.atomic():
        person_image = PersonProfileImage.objects.create(
            user=user,
            image=image_file,
            label=label,
            is_active=False,
        )
        if set_active:
            _activate(person_image)

    return person_image


def activate_person_image(*, image: PersonProfileImage) -> PersonProfileImage:
    """
    Set this image as the user's active person image.
    Deactivates all other images for the same user atomically.

    Returns:
        Updated PersonProfileImage instance.

    Raises:
        ValidationError if the image is archived (hidden from library).
    """
    if image.is_archived:
        raise ValidationError("Cannot activate an archived person image.")
    with transaction.atomic():
        _activate(image)
    return image


def archive_person_image(*, image: PersonProfileImage) -> None:
    """
    Soft-hide a person image from the library (does not delete DB row or file).

    TryOnRequest references use PROTECT; archiving keeps history and saved previews valid.
    If this image was active, another non-archived image becomes active when available.
    """
    with transaction.atomic():
        if image.is_archived:
            return
        was_active = image.is_active
        image.is_archived = True
        image.is_active = False
        image.save(update_fields=["is_archived", "is_active"])
        if was_active:
            nxt = (
                PersonProfileImage.objects.filter(user=image.user, is_archived=False)
                .order_by("-uploaded_at")
                .first()
            )
            if nxt is not None:
                _activate(nxt)


# ---------------------------------------------------------------------------
# Internal
# ---------------------------------------------------------------------------

def _activate(image: PersonProfileImage) -> None:
    """Deactivate all other images for the user, then activate this one."""
    PersonProfileImage.objects.filter(
        user=image.user
    ).exclude(pk=image.pk).update(is_active=False)
    image.is_active = True
    image.save(update_fields=["is_active"])
