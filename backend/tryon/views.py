from django.core.exceptions import ValidationError as DjangoValidationError
from rest_framework import status
from rest_framework.parsers import FormParser, MultiPartParser
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from tryon.selectors.tryon_selectors import (
    get_person_image_for_user,
    get_person_images_for_user,
    get_request_for_user,
    get_result_for_user,
    get_saved_tryon_results_for_user,
)
from tryon.serializers import (
    PersonProfileImageSerializer,
    PersonProfileImageUploadSerializer,
    TryOnRequestCreateSerializer,
    TryOnRequestDetailSerializer,
    TryOnResultSerializer,
    TryOnSavedEntrySerializer,
)
from tryon.services.result_save_service import toggle_tryon_result_save
from tryon.services.person_service import (
    activate_person_image,
    archive_person_image,
    upload_person_image,
)
from tryon.services.tryon_service import create_tryon_request


def _validation_error_response(exc: DjangoValidationError):
    message = exc.message if hasattr(exc, "message") else str(exc)
    return Response({"detail": message}, status=status.HTTP_400_BAD_REQUEST)


# ---------------------------------------------------------------------------
# POST /api/tryon/person-images/
# GET  /api/tryon/person-images/
# ---------------------------------------------------------------------------

class PersonImageListCreateView(APIView):
    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def get(self, request):
        images = get_person_images_for_user(user=request.user)
        return Response(
            PersonProfileImageSerializer(
                images, many=True, context={"request": request}
            ).data
        )

    def post(self, request):
        serializer = PersonProfileImageUploadSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        image = upload_person_image(
            user=request.user,
            image_file=serializer.validated_data["image"],
            label=serializer.validated_data.get("label", ""),
            set_active=serializer.validated_data.get("set_active", False),
        )
        return Response(
            PersonProfileImageSerializer(image, context={"request": request}).data,
            status=status.HTTP_201_CREATED,
        )


# ---------------------------------------------------------------------------
# PATCH /api/tryon/person-images/{id}/activate/
# ---------------------------------------------------------------------------

class PersonImageActivateView(APIView):
    permission_classes = [IsAuthenticated]

    def patch(self, request, image_id: int):
        image = get_person_image_for_user(image_id=image_id, user=request.user)
        image = activate_person_image(image=image)
        return Response(
            PersonProfileImageSerializer(image, context={"request": request}).data
        )


# ---------------------------------------------------------------------------
# DELETE /api/tryon/person-images/{id}/
# ---------------------------------------------------------------------------

class PersonImageDeleteView(APIView):
    permission_classes = [IsAuthenticated]

    def delete(self, request, image_id: int):
        """Soft-archive: hidden from library; DB row + file kept for TryOnRequest PROTECT FK."""
        image = get_person_image_for_user(image_id=image_id, user=request.user)
        try:
            archive_person_image(image=image)
        except DjangoValidationError as exc:
            return _validation_error_response(exc)
        return Response(status=status.HTTP_204_NO_CONTENT)


# ---------------------------------------------------------------------------
# POST /api/tryon/requests/
# ---------------------------------------------------------------------------

class TryOnRequestCreateView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = TryOnRequestCreateSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        try:
            tryon_request = create_tryon_request(
                user=request.user,
                person_image_id=serializer.validated_data["person_image_id"],
                source_type=serializer.validated_data["source_type"],
                mix_result_id=serializer.validated_data.get("mix_result_id"),
                shop_product_id=serializer.validated_data.get("shop_product_id"),
            )
        except DjangoValidationError as exc:
            return _validation_error_response(exc)

        return Response(
            TryOnRequestDetailSerializer(
                tryon_request, context={"request": request}
            ).data,
            status=status.HTTP_201_CREATED,
        )


# ---------------------------------------------------------------------------
# GET /api/tryon/requests/{id}/
# ---------------------------------------------------------------------------

class TryOnRequestDetailView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, request_id: int):
        tryon_request = get_request_for_user(request_id=request_id, user=request.user)
        return Response(
            TryOnRequestDetailSerializer(
                tryon_request, context={"request": request}
            ).data
        )


# ---------------------------------------------------------------------------
# GET /api/tryon/results/saved/
# ---------------------------------------------------------------------------


class TryOnSavedResultsListView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        results = get_saved_tryon_results_for_user(user=request.user)
        return Response(
            TryOnSavedEntrySerializer(
                results, many=True, context={"request": request}
            ).data
        )


# ---------------------------------------------------------------------------
# POST /api/tryon/results/{id}/save/
# ---------------------------------------------------------------------------


class TryOnResultSaveView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, result_id: int):
        result = get_result_for_user(result_id=result_id, user=request.user)
        result = toggle_tryon_result_save(result=result)
        return Response({"id": result.id, "is_saved": result.is_saved})


# ---------------------------------------------------------------------------
# GET /api/tryon/results/{id}/
# ---------------------------------------------------------------------------


class TryOnResultDetailView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, result_id: int):
        result = get_result_for_user(result_id=result_id, user=request.user)
        return Response(
            TryOnResultSerializer(result, context={"request": request}).data
        )
