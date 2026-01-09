from django.contrib import admin
from .models import Course, Batch, Student

@admin.register(Course)
class CourseAdmin(admin.ModelAdmin):
    search_fields = ["name"]

@admin.register(Batch)
class BatchAdmin(admin.ModelAdmin):
    list_display = ["name", "branch", "course", "year"]
    list_filter = ["branch", "course", "year"]
    search_fields = ["name"]

@admin.register(Student)
class StudentAdmin(admin.ModelAdmin):
    list_display = ["full_name", "admission_no", "branch", "current_batch", "active"]
    list_filter = ["branch", "current_batch", "active"]
    search_fields = ["full_name", "admission_no", "guardian_phone"]
