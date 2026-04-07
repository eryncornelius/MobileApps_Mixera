from rest_framework.permissions import BasePermission


class WardrobePermission(BasePermission):
    """Placeholder permission for wardrobe endpoints."""

    def has_permission(self, request, view):
        return True

