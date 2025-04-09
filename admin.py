from django.contrib import admin
from .models import Job, JobCategory, JobApplication, SavedJob

@admin.register(JobCategory)
class JobCategoryAdmin(admin.ModelAdmin):
    list_display = ('name', 'created_at')
    search_fields = ('name',)

@admin.register(Job)
class JobAdmin(admin.ModelAdmin):
    list_display = ('title', 'company', 'location', 'job_type', 'status', 'created_at')
    list_filter = ('job_type', 'status', 'category', 'experience_level', 'created_at')
    search_fields = ('title', 'company__company_name', 'location')
    readonly_fields = ('created_at', 'updated_at')
    date_hierarchy = 'created_at'

@admin.register(JobApplication)
class JobApplicationAdmin(admin.ModelAdmin):
    list_display = ('job', 'candidate', 'status', 'created_at')
    list_filter = ('status', 'created_at')
    search_fields = ('job__title', 'candidate__user__email', 'candidate__user__first_name')
    readonly_fields = ('created_at',)
    date_hierarchy = 'created_at'

@admin.register(SavedJob)
class SavedJobAdmin(admin.ModelAdmin):
    list_display = ('job', 'user', 'created_at')
    list_filter = ('created_at',)
    search_fields = ('job__title', 'user__email')
    readonly_fields = ('created_at',)
