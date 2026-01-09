from django.urls import path
from . import views

urlpatterns = [
    path("me/", views.me),
    path("students/", views.students_list),

    path("attendance/batch/<int:batch_id>/date/<str:date_str>/", views.attendance_get_or_init),
    path("attendance/batch/<int:batch_id>/date/<str:date_str>/submit/", views.attendance_submit),

    path("exams/batch/<int:batch_id>/", views.exams_for_batch),
    path("exams/<int:exam_id>/results/", views.exam_results),
    path("exams/<int:exam_id>/results/submit/", views.exam_results_submit),
    path("batches/", views.batches_list),
    path("exams/batch/<int:batch_id>/", views.exams_for_batch),
    path("exams/<int:exam_id>/results/submit/", views.exam_results_submit),

]
