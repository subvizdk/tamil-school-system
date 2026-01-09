from django.contrib import admin
from .models import Exam, ExamResult

@admin.register(Exam)
class ExamAdmin(admin.ModelAdmin):
    list_display = ["title", "batch", "exam_date", "max_marks"]
    list_filter = ["batch", "exam_date"]
    search_fields = ["title"]

@admin.register(ExamResult)
class ExamResultAdmin(admin.ModelAdmin):
    list_display = ["exam", "student", "marks"]
    list_filter = ["exam"]
    search_fields = ["student__full_name", "student__admission_no"]
