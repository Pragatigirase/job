from django.urls import path
from . import views

urlpatterns = [
    # Job listing and details
    path('', views.job_list, name='job_list'),
    path('<int:pk>/', views.job_detail, name='job_detail'),
    
    # Job actions
    path('<int:pk>/apply/', views.apply_for_job, name='apply_for_job'),
    path('<int:pk>/save/', views.save_job, name='save_job'),
    path('<int:pk>/unsave/', views.unsave_job, name='unsave_job'),
]
