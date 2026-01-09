from django.db import models
from django.utils.translation import gettext_lazy as _
from academics.models import Student, Batch

class AttendanceStatus(models.TextChoices):
    PRESENT = "P", _("Present")
    ABSENT = "A", _("Absent")
    LATE = "L", _("Late")

class Attendance(models.Model):
    batch = models.ForeignKey(Batch, on_delete=models.CASCADE)
    date = models.DateField(_("Date"))
    student = models.ForeignKey(Student, on_delete=models.CASCADE)
    status = models.CharField(max_length=1, choices=AttendanceStatus.choices)
    note = models.CharField(_("Note"), max_length=255, blank=True)

    class Meta:
        unique_together = [("student", "date")]  # one record per day per student

    def __str__(self) -> str:
        return f"{self.student} {self.date} {self.status}"
