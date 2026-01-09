from django.db import models
from django.utils.translation import gettext_lazy as _

class Branch(models.Model):
    city_name = models.CharField(_("City name"), max_length=100)
    address = models.TextField(_("Address"), blank=True)
    phone = models.CharField(_("Phone"), max_length=30, blank=True)

    def __str__(self) -> str:
        return self.city_name
