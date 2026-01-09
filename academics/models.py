from django.db import models
from django.utils.translation import gettext_lazy as _
from core.models import Branch

class Course(models.Model):
    name = models.CharField(_("Course name"), max_length=120)
    description = models.TextField(_("Description"), blank=True)

    def __str__(self) -> str:
        return self.name

class Batch(models.Model):
    branch = models.ForeignKey(Branch, on_delete=models.CASCADE)
    course = models.ForeignKey(Course, on_delete=models.PROTECT)
    name = models.CharField(_("Batch/Class name"), max_length=120)
    year = models.IntegerField(_("Year"))

    def __str__(self) -> str:
        return f"{self.branch.city_name} - {self.name} ({self.year})"

class Student(models.Model):
    branch = models.ForeignKey(Branch, on_delete=models.PROTECT)
    current_batch = models.ForeignKey(Batch, on_delete=models.PROTECT, related_name="students")

    admission_no = models.CharField(_("Admission No"), max_length=50)
    full_name = models.CharField(_("Full name"), max_length=200)
    tamil_name = models.CharField(_("Tamil name"), max_length=200, blank=True)

    guardian_name = models.CharField(_("Guardian name"), max_length=200, blank=True)
    guardian_phone = models.CharField(_("Guardian phone"), max_length=30, blank=True)

    active = models.BooleanField(_("Active"), default=True)

    class Meta:
        unique_together = [("branch", "admission_no")]

    def __str__(self) -> str:
        return f"{self.full_name} ({self.admission_no})"
