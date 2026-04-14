from django.core.exceptions import ValidationError as DjangoValidationError
from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView

from mixmatch.permissions import IsOwner
from mixmatch.selectors.mix_selectors import (
    get_result_for_user,
    get_saved_results_for_user,
    get_session_for_user,
)
from mixmatch.serializers import (
    MixResultDetailSerializer,
    MixSessionDetailSerializer,
    SelectItemsSerializer,
)
from mixmatch.services.mix_service import create_session, set_selected_items
from mixmatch.services.result_service import generate_mix_result, toggle_save_result


def _validation_error_response(exc: DjangoValidationError):
    message = exc.message if hasattr(exc, "message") else str(exc)
    return Response({"detail": message}, status=status.HTTP_400_BAD_REQUEST)


# ---------------------------------------------------------------------------
# POST /api/mixmatch/sessions/
# ---------------------------------------------------------------------------

class MixSessionCreateView(APIView):
    permission_classes = [IsOwner]

    def post(self, request):
        session = create_session(user=request.user)
        return Response(
            MixSessionDetailSerializer(session, context={"request": request}).data,
            status=status.HTTP_201_CREATED,
        )


# ---------------------------------------------------------------------------
# GET  /api/mixmatch/sessions/<id>/
# ---------------------------------------------------------------------------

class MixSessionDetailView(APIView):
    permission_classes = [IsOwner]

    def get(self, request, session_id: int):
        session = get_session_for_user(session_id=session_id, user=request.user)
        return Response(MixSessionDetailSerializer(session, context={"request": request}).data)


# ---------------------------------------------------------------------------
# POST /api/mixmatch/sessions/<id>/select-items/
# ---------------------------------------------------------------------------

class MixSessionSelectItemsView(APIView):
    permission_classes = [IsOwner]

    def post(self, request, session_id: int):
        session = get_session_for_user(session_id=session_id, user=request.user)
        serializer = SelectItemsSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        try:
            session = set_selected_items(
                session=session,
                item_ids=serializer.validated_data["item_ids"],
            )
        except DjangoValidationError as exc:
            return _validation_error_response(exc)

        return Response(MixSessionDetailSerializer(session, context={"request": request}).data)


# ---------------------------------------------------------------------------
# POST /api/mixmatch/sessions/<id>/generate/
# ---------------------------------------------------------------------------

class MixSessionGenerateView(APIView):
    permission_classes = [IsOwner]

    def post(self, request, session_id: int):
        session = get_session_for_user(session_id=session_id, user=request.user)

        try:
            result = generate_mix_result(session=session)
        except DjangoValidationError as exc:
            return _validation_error_response(exc)

        return Response(
            MixResultDetailSerializer(result, context={"request": request}).data,
            status=status.HTTP_201_CREATED,
        )


# ---------------------------------------------------------------------------
# GET /api/mixmatch/results/saved/
# ---------------------------------------------------------------------------


class MixSavedResultsListView(APIView):
    permission_classes = [IsOwner]

    def get(self, request):
        results = get_saved_results_for_user(user=request.user)
        return Response(
            MixResultDetailSerializer(
                results, many=True, context={"request": request}
            ).data
        )


# ---------------------------------------------------------------------------
# GET /api/mixmatch/results/<id>/
# ---------------------------------------------------------------------------

class MixResultDetailView(APIView):
    permission_classes = [IsOwner]

    def get(self, request, result_id: int):
        result = get_result_for_user(result_id=result_id, user=request.user)
        return Response(
            MixResultDetailSerializer(result, context={"request": request}).data
        )


# ---------------------------------------------------------------------------
# POST /api/mixmatch/results/<id>/save/
# ---------------------------------------------------------------------------

class MixResultSaveView(APIView):
    permission_classes = [IsOwner]

    def post(self, request, result_id: int):
        result = get_result_for_user(result_id=result_id, user=request.user)
        result = toggle_save_result(result=result)
        return Response({"id": result.id, "is_saved": result.is_saved})
