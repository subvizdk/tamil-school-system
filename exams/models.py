from django.db import models
from django.utils.translation import gettext_lazy as _
from academics.models import Batch, Student

class Exam(models.Model):
    batch = models.ForeignKey(Batch, on_delete=models.CASCADE)
    title = models.CharField(_("Title"), max_length=200)
    exam_date = models.DateField(_("Exam date"))
    max_marks = models.IntegerField(_("Max marks"), default=100)

    def __str__(self) -> str:
        return f"{self.batch} - {self.title}"

class ExamResult(models.Model):
    exam = models.ForeignKey(Exam, on_delete=models.CASCADE, related_name="results")
    student = models.ForeignKey(Student, on_delete=models.CASCADE)
    marks = models.DecimalField(_("Marks"), max_digits=6, decimal_places=2)
    remarks = models.CharField(_("Remarks"), max_length=255, blank=True)

    class Meta:
        unique_together = [("exam", "student")]

    def __str__(self) -> str:
        return f"{self.exam} - {self.student}"
