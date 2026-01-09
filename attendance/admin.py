from django.contrib import admin
from .models import Attendance

@admin.register(Attendance)
class AttendanceAdmin(admin.ModelAdmin):
    list_display = ["date", "batch", "student", "status"]
    list_filter = ["date", "batch", "status"]
    search_fields = ["student__full_name", "student__admission_no"]
