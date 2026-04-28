from django.contrib import admin
from django.http import HttpResponse
from django.urls import path


def home(request):
    return HttpResponse("Django app is running in the final DevOps project.")


urlpatterns = [
    path("", home),
    path("admin/", admin.site.urls),
]
