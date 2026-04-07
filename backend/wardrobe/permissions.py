from rest_framework.permissions import IsAuthenticated


class IsOwner(IsAuthenticated):
    """
    Allows access only to authenticated users.
    Object-level ownership is enforced inside each view/selector
    (queries are always scoped to request.user).
    """
    pass
