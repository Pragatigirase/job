// Custom JavaScript for Job Board Platform

document.addEventListener('DOMContentLoaded', function() {
    
    // Initialize tooltips
    var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
        return new bootstrap.Tooltip(tooltipTriggerEl);
    });
    
    // Initialize popovers
    var popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'));
    var popoverList = popoverTriggerList.map(function (popoverTriggerEl) {
        return new bootstrap.Popover(popoverTriggerEl);
    });
    
    // Auto-dismiss alerts after 5 seconds
    setTimeout(function() {
        var alerts = document.querySelectorAll('.alert:not(.alert-permanent)');
        alerts.forEach(function(alert) {
            var bsAlert = new bootstrap.Alert(alert);
            bsAlert.close();
        });
    }, 5000);
    
    // Job filters - update form when select changes
    const sortOrderSelect = document.getElementById('sortOrder');
    if (sortOrderSelect) {
        sortOrderSelect.addEventListener('change', function() {
            // Get current URL
            let url = new URL(window.location.href);
            
            // Add or update the 'sort' parameter
            url.searchParams.set('sort', this.value);
            
            // Navigate to the new URL
            window.location.href = url.toString();
        });
    }
    
    // File input custom display
    const fileInputs = document.querySelectorAll('input[type="file"]');
    fileInputs.forEach(function(input) {
        input.addEventListener('change', function(e) {
            // Get the file name
            const fileName = e.target.files[0]?.name || 'No file chosen';
            
            // Find the label or create a display element
            let fileDisplay = input.nextElementSibling;
            if (!fileDisplay || !fileDisplay.classList.contains('file-display')) {
                fileDisplay = document.createElement('small');
                fileDisplay.classList.add('file-display', 'form-text', 'mt-1');
                input.parentNode.insertBefore(fileDisplay, input.nextSibling);
            }
            
            // Update the display text
            fileDisplay.textContent = `Selected file: ${fileName}`;
        });
    });
    
    // Toggle password visibility
    const togglePasswordButtons = document.querySelectorAll('.toggle-password');
    togglePasswordButtons.forEach(function(button) {
        button.addEventListener('click', function() {
            const passwordField = document.querySelector(this.getAttribute('data-toggle'));
            const type = passwordField.getAttribute('type') === 'password' ? 'text' : 'password';
            passwordField.setAttribute('type', type);
            
            // Toggle icon
            this.querySelector('i').classList.toggle('fa-eye');
            this.querySelector('i').classList.toggle('fa-eye-slash');
        });
    });
    
    // Confirm before form submission for critical actions
    const confirmForms = document.querySelectorAll('form[data-confirm]');
    confirmForms.forEach(function(form) {
        form.addEventListener('submit', function(e) {
            const message = this.getAttribute('data-confirm');
            if (!confirm(message)) {
                e.preventDefault();
            }
        });
    });
    
    // Highlight active navigation links based on current URL
    const currentPath = window.location.pathname;
    document.querySelectorAll('.navbar-nav .nav-link').forEach(function(link) {
        const href = link.getAttribute('href');
        if (href && currentPath.startsWith(href) && href !== '/') {
            link.classList.add('active');
        }
    });
    
    // Character counter for textareas
    const textareas = document.querySelectorAll('textarea[maxlength]');
    textareas.forEach(function(textarea) {
        const maxLength = textarea.getAttribute('maxlength');
        
        // Create counter element
        const counter = document.createElement('small');
        counter.classList.add('char-counter', 'form-text', 'text-muted');
        counter.textContent = `${textarea.value.length}/${maxLength} characters`;
        
        // Insert after textarea
        textarea.parentNode.insertBefore(counter, textarea.nextSibling);
        
        // Update on input
        textarea.addEventListener('input', function() {
            counter.textContent = `${textarea.value.length}/${maxLength} characters`;
            
            // Add warning class when approaching limit
            if (textarea.value.length > maxLength * 0.9) {
                counter.classList.add('text-warning');
            } else {
                counter.classList.remove('text-warning');
            }
        });
    });
    
    // Date picker defaults for application deadline
    const deadlineInputs = document.querySelectorAll('input[type="date"][name="application_deadline"]');
    deadlineInputs.forEach(function(input) {
        // Set min date to today
        const today = new Date();
        const dd = String(today.getDate()).padStart(2, '0');
        const mm = String(today.getMonth() + 1).padStart(2, '0'); // January is 0!
        const yyyy = today.getFullYear();
        const todayStr = `${yyyy}-${mm}-${dd}`;
        
        if (!input.getAttribute('min')) {
            input.setAttribute('min', todayStr);
        }
    });
    
    // Salary range validation
    const salaryMinInput = document.querySelector('input[name="salary_min"]');
    const salaryMaxInput = document.querySelector('input[name="salary_max"]');
    
    if (salaryMinInput && salaryMaxInput) {
        function validateSalaryRange() {
            const minValue = parseFloat(salaryMinInput.value) || 0;
            const maxValue = parseFloat(salaryMaxInput.value) || 0;
            
            if (maxValue > 0 && minValue > maxValue) {
                salaryMaxInput.setCustomValidity('Maximum salary cannot be less than minimum salary');
            } else {
                salaryMaxInput.setCustomValidity('');
            }
        }
        
        salaryMinInput.addEventListener('input', validateSalaryRange);
        salaryMaxInput.addEventListener('input', validateSalaryRange);
    }
    
    // Job search form - prevent empty submission
    const jobSearchForm = document.querySelector('form[action*="job_list"]');
    if (jobSearchForm) {
        jobSearchForm.addEventListener('submit', function(e) {
            const inputs = this.querySelectorAll('input, select');
            let hasValue = false;
            
            inputs.forEach(function(input) {
                if (input.value.trim()) {
                    hasValue = true;
                }
            });
            
            if (!hasValue) {
                e.preventDefault();
                // Instead of stopping the submission, you could just ensure at least one field has a value
                // This allows users to reset filters by submitting with no values
            }
        });
    }
    
    // Print job details
    const printButtons = document.querySelectorAll('.btn-print');
    printButtons.forEach(function(button) {
        button.addEventListener('click', function(e) {
            e.preventDefault();
            window.print();
        });
    });
});
