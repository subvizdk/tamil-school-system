from django.db.models import Count, Q
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status

from .models import Course
from api.views import _allowed_branch  # ✅ comes from api/views.py in your project


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def courses_list(request):
    """
    GET /api/courses/
    Optional: q=search term
    Filter by user's branch unless SUPER_ADMIN (via _allowed_branch)
    """
    q = request.query_params.get("q", "").strip()
    branch = _allowed_branch(request.user)

    qs = Course.objects.all()

    if q:
        qs = qs.filter(
            Q(name__icontains=q) |
            Q(description__icontains=q)
        )

    # Only show courses that have batches in the user's branch
    if branch is not None:
        qs = qs.filter(batch__branch=branch)

    qs = qs.annotate(batches_count=Count("batch", distinct=True)).order_by("name")

    data = [
        {
            "id": c.id,
            "name": c.name,
            "active": True,  # your Course model doesn't have active
            "batches_count": c.batches_count,
        }
        for c in qs[:500]
    ]

    return Response(data, status=status.HTTP_200_OK)
