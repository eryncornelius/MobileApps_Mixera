from django.core.exceptions import ValidationError as DjangoValidationError
from rest_framework import status
from rest_framework.parsers import FormParser, MultiPartParser
from rest_framework.response import Response
from rest_framework.views import APIView

from wardrobe.models import WardrobeItem
from wardrobe.permissions import IsOwner
from wardrobe.selectors.item_selectors import get_category_summary_for_user, get_items_for_user
from wardrobe.selectors.upload_selectors import get_batch_for_user
from wardrobe.serializers import (
    CandidateBatchUpdateSerializer,
    DetectedItemCandidateSerializer,
    UploadBatchCreateSerializer,
    UploadBatchDetailSerializer,
    WardrobeItemSerializer,
)
from wardrobe.services.candidate_service import update_candidates
from wardrobe.services.detection_service import run_detection_for_batch
from wardrobe.services.upload_service import add_photos_to_batch, create_batch
from wardrobe.services.wardrobe_item_service import confirm_batch


def _validation_error_response(exc: DjangoValidationError):
    message = exc.message if hasattr(exc, "message") else str(exc)
    return Response({"detail": message}, status=status.HTTP_400_BAD_REQUEST)


# ---------------------------------------------------------------------------
# POST /api/wardrobe/upload-batches/
# GET  /api/wardrobe/upload-batches/  (not required by spec but cheap to add)
# ---------------------------------------------------------------------------

class UploadBatchListCreateView(APIView):
    permission_classes = [IsOwner]
    parser_classes = [MultiPartParser, FormParser]

    def post(self, request):
        # MultiPartParser puts multiple files under the same key in request.FILES
        images = request.FILES.getlist("images")
        serializer = UploadBatchCreateSerializer(data={"images": images})
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        try:
            batch = create_batch(user=request.user)
            add_photos_to_batch(batch=batch, images=serializer.validated_data["images"])
            run_detection_for_batch(batch=batch)
        except DjangoValidationError as exc:
            return _validation_error_response(exc)

        return Response(
            UploadBatchDetailSerializer(batch).data,
            status=status.HTTP_201_CREATED,
        )


# ---------------------------------------------------------------------------
# GET   /api/wardrobe/upload-batches/<id>/
# ---------------------------------------------------------------------------

class UploadBatchDetailView(APIView):
    permission_classes = [IsOwner]

    def get(self, request, batch_id: int):
        batch = get_batch_for_user(batch_id=batch_id, user=request.user)
        return Response(UploadBatchDetailSerializer(batch).data)


# ---------------------------------------------------------------------------
# PATCH /api/wardrobe/upload-batches/<id>/candidates/
# ---------------------------------------------------------------------------

class UploadBatchCandidatesUpdateView(APIView):
    permission_classes = [IsOwner]

    def patch(self, request, batch_id: int):
        batch = get_batch_for_user(batch_id=batch_id, user=request.user)
        serializer = CandidateBatchUpdateSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        try:
            updated = update_candidates(
                batch=batch,
                updates=serializer.validated_data["candidates"],
            )
        except DjangoValidationError as exc:
            return _validation_error_response(exc)

        return Response(
            DetectedItemCandidateSerializer(updated, many=True).data
        )


# ---------------------------------------------------------------------------
# POST /api/wardrobe/upload-batches/<id>/confirm/
# ---------------------------------------------------------------------------

class UploadBatchConfirmView(APIView):
    permission_classes = [IsOwner]

    def post(self, request, batch_id: int):
        batch = get_batch_for_user(batch_id=batch_id, user=request.user)

        try:
            items = confirm_batch(batch=batch)
        except DjangoValidationError as exc:
            return _validation_error_response(exc)

        return Response(
            WardrobeItemSerializer(items, many=True, context={"request": request}).data,
            status=status.HTTP_201_CREATED,
        )


# ---------------------------------------------------------------------------
# GET /api/wardrobe/items/
# ---------------------------------------------------------------------------

class WardrobeItemListView(APIView):
    permission_classes = [IsOwner]

    def get(self, request):
        category = request.query_params.get("category")
        items = get_items_for_user(user=request.user, category=category)
        return Response(
            WardrobeItemSerializer(items, many=True, context={"request": request}).data
        )


# ---------------------------------------------------------------------------
# PATCH /api/wardrobe/items/<id>/   — rename, toggle favourite
# DELETE /api/wardrobe/items/<id>/  — remove item
# ---------------------------------------------------------------------------

class WardrobeItemDetailView(APIView):
    permission_classes = [IsOwner]

    def _get_item(self, item_id: int, user):
        try:
            return WardrobeItem.objects.get(pk=item_id, user=user)
        except WardrobeItem.DoesNotExist:
            return None

    def patch(self, request, item_id: int):
        item = self._get_item(item_id, request.user)
        if item is None:
            return Response({"detail": "Not found."}, status=status.HTTP_404_NOT_FOUND)
        serializer = WardrobeItemSerializer(item, data=request.data, partial=True)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        serializer.save()
        return Response(serializer.data)

    def delete(self, request, item_id: int):
        item = self._get_item(item_id, request.user)
        if item is None:
            return Response({"detail": "Not found."}, status=status.HTTP_404_NOT_FOUND)
        item.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


# ---------------------------------------------------------------------------
# GET /api/wardrobe/categories/summary/
# ---------------------------------------------------------------------------

class WardrobeCategorySummaryView(APIView):
    permission_classes = [IsOwner]

    def get(self, request):
        summary = get_category_summary_for_user(user=request.user)
        return Response(summary)
