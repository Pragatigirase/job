from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.http import HttpResponseForbidden
from django.db.models import Q
from django.core.paginator import Paginator

from .models import Job, JobApplication, SavedJob
from .forms import JobSearchForm, JobApplicationForm
from accounts.models import CandidateProfile

def job_list(request):
    jobs = Job.objects.filter(status='open')
    form = JobSearchForm(request.GET or None)
    
    if form.is_valid():
        keyword = form.cleaned_data.get('keyword')
        location = form.cleaned_data.get('location')
        category = form.cleaned_data.get('category')
        job_type = form.cleaned_data.get('job_type')
        experience_level = form.cleaned_data.get('experience_level')
        
        if keyword:
            jobs = jobs.filter(
                Q(title__icontains=keyword) | 
                Q(description__icontains=keyword) |
                Q(requirements__icontains=keyword)
            )
        
        if location:
            jobs = jobs.filter(location__icontains=location)
        
        if category:
            jobs = jobs.filter(category=category)
        
        if job_type:
            jobs = jobs.filter(job_type=job_type)
        
        if experience_level:
            jobs = jobs.filter(experience_level=experience_level)
    
    paginator = Paginator(jobs, 10)  # Show 10 jobs per page
    page_number = request.GET.get('page')
    page_obj = paginator.get_page(page_number)
    
    # For logged-in users, get their saved jobs to display save/unsave options
    saved_job_ids = []
    if request.user.is_authenticated:
        saved_job_ids = SavedJob.objects.filter(user=request.user).values_list('job_id', flat=True)
    
    context = {
        'page_obj': page_obj,
        'form': form,
        'saved_job_ids': saved_job_ids,
    }
    
    return render(request, 'jobs/job_list.html', context)

def job_detail(request, pk):
    job = get_object_or_404(Job, pk=pk)
    has_applied = False
    is_saved = False
    
    if request.user.is_authenticated:
        if hasattr(request.user, 'candidate_profile'):
            has_applied = JobApplication.objects.filter(
                job=job, 
                candidate=request.user.candidate_profile
            ).exists()
        
        is_saved = SavedJob.objects.filter(job=job, user=request.user).exists()
    
    context = {
        'job': job,
        'has_applied': has_applied,
        'is_saved': is_saved,
        'application_form': JobApplicationForm(),
    }
    
    return render(request, 'jobs/job_detail.html', context)

@login_required
def apply_for_job(request, pk):
    job = get_object_or_404(Job, pk=pk)
    
    # Check if job is still open
    if job.status != 'open':
        messages.error(request, "This job is no longer accepting applications.")
        return redirect('job_detail', pk=job.pk)
    
    # Ensure user is a candidate
    if request.user.user_type != 'candidate':
        messages.error(request, "Only candidates can apply for jobs.")
        return redirect('job_detail', pk=job.pk)
    
    # Get or create candidate profile
    candidate_profile = getattr(request.user, 'candidate_profile', None)
    if not candidate_profile:
        messages.error(request, "Please complete your candidate profile before applying.")
        return redirect('edit_profile')
    
    # Check if already applied
    if JobApplication.objects.filter(job=job, candidate=candidate_profile).exists():
        messages.info(request, "You have already applied for this job.")
        return redirect('job_detail', pk=job.pk)
    
    if request.method == 'POST':
        form = JobApplicationForm(request.POST, request.FILES)
        if form.is_valid():
            application = form.save(commit=False)
            application.job = job
            application.candidate = candidate_profile
            
            # Use candidate's resume if none provided
            if not application.resume and candidate_profile.resume:
                application.resume = candidate_profile.resume
                
            application.save()
            messages.success(request, "Your application has been submitted successfully!")
            return redirect('job_detail', pk=job.pk)
    else:
        form = JobApplicationForm()
    
    context = {
        'job': job,
        'form': form,
    }
    
    return render(request, 'jobs/job_apply.html', context)

@login_required
def save_job(request, pk):
    job = get_object_or_404(Job, pk=pk)
    
    # Check if already saved
    if SavedJob.objects.filter(job=job, user=request.user).exists():
        messages.info(request, "You've already saved this job.")
    else:
        SavedJob.objects.create(job=job, user=request.user)
        messages.success(request, "Job saved successfully!")
    
    return redirect('job_detail', pk=job.pk)

@login_required
def unsave_job(request, pk):
    job = get_object_or_404(Job, pk=pk)
    saved_job = SavedJob.objects.filter(job=job, user=request.user)
    
    if saved_job.exists():
        saved_job.delete()
        messages.success(request, "Job removed from saved jobs.")
    
    return redirect('job_detail', pk=job.pk)
