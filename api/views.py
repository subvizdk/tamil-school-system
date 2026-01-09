from datetime import datetime

from django.contrib.auth import get_user_model
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status

from accounts.models import Profile, UserRole
from academics.models import Student, Batch
from attendance.models import Attendance, AttendanceStatus
from exams.models import Exam, ExamResult

User = get_user_model()


def _profile(user) -> Profile:
    # assumes Profile is created for each user (signals)
    return Profile.objects.select_related("branch").get(user=user)


def _allowed_branch(user):
    prof = _profile(user)
    if prof.role == UserRole.SUPER_ADMIN:
        return None
    return prof.branch


def _parse_date(date_str: str):
    # Expected format: YYYY-MM-DD
    return datetime.strptime(date_str, "%Y-%m-%d").date()


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def me(request):
    prof = _profile(request.user)
    return Response({
        "username": request.user.username,
        "role": prof.role,
        "branch_id": prof.branch.id if prof.branch else None,
        "branch_city": prof.branch.city_name if prof.branch else None,
    })


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def students_list(request):
    batch_id = request.GET.get("batch_id")

    students = Student.objects.all()
    if batch_id:
        students = students.filter(current_batch_id=batch_id)

    students = students.select_related("branch", "current_batch")

    data = []
    for s in students:
        data.append({
            "id": s.id,
            "full_name": s.full_name,
            "admission_no": s.admission_no,
            "batch_name": s.current_batch.name if s.current_batch else None,
            "branch_city": s.branch.city_name if s.branch else None,
            "active": bool(s.active),
        })

    return Response(data)

@api_view(["GET"])
@permission_classes([IsAuthenticated])
def attendance_get_or_init(request, batch_id: int, date_str: str):
    branch = _allowed_branch(request.user)
    date = _parse_date(date_str)

    batch = Batch.objects.select_related("branch").get(id=batch_id)
    if branch is not None and batch.branch_id != branch.id:
        return Response({"detail": "Forbidden"}, status=status.HTTP_403_FORBIDDEN)

    students = Student.objects.filter(current_batch=batch, active=True).order_by("full_name")
    existing = {a.student_id: a for a in Attendance.objects.filter(batch=batch, date=date)}

    rows = []
    for s in students:
        a = existing.get(s.id)
        rows.append({
            "student_id": s.id,
            "student_name": s.full_name,
            "status": a.status if a else None,
            "note": a.note if a else "",
        })

    return Response({
        "batch_id": batch.id,
        "date": date_str,
        "students": rows,
        "status_choices": [
            {"key": AttendanceStatus.PRESENT, "label": "Present"},
            {"key": AttendanceStatus.ABSENT, "label": "Absent"},
            {"key": AttendanceStatus.LATE, "label": "Late"},
        ],
    })


@api_view(["POST"])
@permission_classes([IsAuthenticated])
def attendance_submit(request, batch_id: int, date_str: str):
    """
    Payload:
    {
      "records": [
        {"student_id": 1, "status": "P", "note": ""},
        {"student_id": 2, "status": "A", "note": "Sick"}
      ]
    }
    """
    branch = _allowed_branch(request.user)
    date = _parse_date(date_str)

    batch = Batch.objects.select_related("branch").get(id=batch_id)
    if branch is not None and batch.branch_id != branch.id:
        return Response({"detail": "Forbidden"}, status=status.HTTP_403_FORBIDDEN)

    records = request.data.get("records", [])
    if not isinstance(records, list):
        return Response({"detail": "records must be a list"}, status=400)

    saved = 0
    for r in records:
        sid = r.get("student_id")
        st = r.get("status")
        note = r.get("note", "") or ""

        if st not in [AttendanceStatus.PRESENT, AttendanceStatus.ABSENT, AttendanceStatus.LATE]:
            continue

        if not Student.objects.filter(id=sid, current_batch=batch).exists():
            continue

        Attendance.objects.update_or_create(
            student_id=sid,
            date=date,
            defaults={"batch": batch, "status": st, "note": note},
        )
        saved += 1

    return Response({"saved": saved})


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def exams_for_batch(request, batch_id: int):
    branch = _allowed_branch(request.user)

    batch = Batch.objects.select_related("branch").get(id=batch_id)
    if branch is not None and batch.branch_id != branch.id:
        return Response({"detail": "Forbidden"}, status=403)

    exams = Exam.objects.filter(batch=batch).order_by("-exam_date")
    return Response([{
        "id": e.id,
        "title": e.title,
        "exam_date": e.exam_date.isoformat(),
        "max_marks": e.max_marks,
    } for e in exams])


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def exam_results(request, exam_id: int):
    branch = _allowed_branch(request.user)

    exam = Exam.objects.select_related("batch__branch").get(id=exam_id)
    if branch is not None and exam.batch.branch_id != branch.id:
        return Response({"detail": "Forbidden"}, status=403)

    students = Student.objects.filter(current_batch=exam.batch, active=True).order_by("full_name")
    existing = {r.student_id: r for r in ExamResult.objects.filter(exam=exam)}

    rows = []
    for s in students:
        r = existing.get(s.id)
        rows.append({
            "student_id": s.id,
            "student_name": s.full_name,
            "marks": str(r.marks) if r else None,
            "remarks": r.remarks if r else "",
        })

    return Response({
        "exam": {
            "id": exam.id,
            "title": exam.title,
            "exam_date": exam.exam_date.isoformat(),
            "max_marks": exam.max_marks,
            "batch_id": exam.batch_id,
        },
        "students": rows
    })


@api_view(["POST"])
@permission_classes([IsAuthenticated])
def exam_results_submit(request, exam_id: int):
    """
    Payload:
    { "results": [ {"student_id": 1, "marks": 88, "remarks": ""}, ... ] }
    """
    branch = _allowed_branch(request.user)

    exam = Exam.objects.select_related("batch__branch").get(id=exam_id)
    if branch is not None and exam.batch.branch_id != branch.id:
        return Response({"detail": "Forbidden"}, status=403)

    results = request.data.get("results", [])
    if not isinstance(results, list):
        return Response({"detail": "results must be a list"}, status=400)

    saved = 0
    for r in results:
        sid = r.get("student_id")
        marks = r.get("marks")
        remarks = r.get("remarks", "") or ""

        if marks is None:
            continue

        if not Student.objects.filter(id=sid, current_batch=exam.batch).exists():
            continue

        ExamResult.objects.update_or_create(
            exam=exam,
            student_id=sid,
            defaults={"marks": marks, "remarks": remarks},
        )
        saved += 1

    return Response({"saved": saved})

@api_view(["GET"])
@permission_classes([IsAuthenticated])
def batches_list(request):
    """
    Returns batches filtered by user's branch (unless SUPER_ADMIN).
    """
    branch = _allowed_branch(request.user)

    qs = Batch.objects.select_related("branch", "course").all()
    if branch is not None:
        qs = qs.filter(branch=branch)

    qs = qs.order_by("-year", "name")

    data = [{
        "id": b.id,
        "name": b.name,
        "year": b.year,
        "branch_id": b.branch_id,
        "branch_city": b.branch.city_name,
        "course_id": b.course_id,
        "course_name": b.course.name,
    } for b in qs[:500]]

    return Response(data)

@api_view(["GET"])
@permission_classes([IsAuthenticated])
def students_list(request):
    """
    GET /api/students/?batch_id=123
    Optional: q=search term
    """
    batch_id = request.query_params.get("batch_id")
    if not batch_id:
        return Response({"detail": "batch_id is required"}, status=status.HTTP_400_BAD_REQUEST)

    branch = _allowed_branch(request.user)

    batch = Batch.objects.select_related("branch").get(id=batch_id)
    if branch is not None and batch.branch_id != branch.id:
        return Response({"detail": "Forbidden"}, status=status.HTTP_403_FORBIDDEN)

    qs = (
        Student.objects
        .filter(current_batch=batch, active=True)
        .select_related("current_batch", "current_batch__branch")
        .order_by("full_name")
    )

    q = request.query_params.get("q")
    if q:
        qs = qs.filter(full_name__icontains=q)

    data = [{
        "id": s.id,
        "full_name": s.full_name,
        "admission_no": s.admission_no,

        "batch_id": s.current_batch_id,
        "batch_name": s.current_batch.name if s.current_batch else None,

        # ✅ THIS is what you wanted
        "branch_city": (
            s.current_batch.branch.city_name
            if s.current_batch and s.current_batch.branch
            else None
        ),

        "active": s.active,
    } for s in qs[:500]]

    return Response(data)