from rest_framework.permissions import BasePermission


class MixmatchPermission(BasePermission):
    """Placeholder permission for mixmatch endpoints."""

    def has_permission(self, request, view):
        return True

