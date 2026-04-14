from rest_framework.permissions import BasePermission


class IsApprovedSeller(BasePermission):
    """Admin mengaktifkan user.is_seller di Django admin."""

    message = "Seller access is not enabled for this account."

    def has_permission(self, request, view):
        u = request.user
        return bool(
            u
            and u.is_authenticated
            and getattr(u, "is_seller", False)
        )
