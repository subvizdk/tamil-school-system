from django.conf import settings
from django.db import models
from django.utils.translation import gettext_lazy as _
from core.models import Branch

class UserRole(models.TextChoices):
    SUPER_ADMIN = "SUPER_ADMIN", _("Super Admin")
    BRANCH_ADMIN = "BRANCH_ADMIN", _("Branch Admin")
    TEACHER = "TEACHER", _("Teacher/Staff")

class Profile(models.Model):
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    role = models.CharField(max_length=20, choices=UserRole.choices)
    branch = models.ForeignKey(Branch, on_delete=models.SET_NULL, null=True, blank=True)

    def __str__(self) -> str:
        return f"{self.user.username} ({self.role})"
