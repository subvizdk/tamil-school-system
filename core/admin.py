from django.contrib import admin
from .models import Branch

@admin.register(Branch)
class BranchAdmin(admin.ModelAdmin):
    list_display = ["city_name", "phone"]
    search_fields = ["city_name", "phone"]
