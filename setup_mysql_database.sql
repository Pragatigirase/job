-- Job Board MySQL Setup Script
-- This script will create and set up the database structure for the Job Board application
-- Run this in phpMyAdmin or MySQL console to set up your database

-- Create database (if it doesn't exist)
CREATE DATABASE IF NOT EXISTS job_board CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Use the created database
USE job_board;

-- Drop tables if they exist to avoid conflicts (in reverse order of dependencies)
DROP TABLE IF EXISTS saved_jobs;
DROP TABLE IF EXISTS job_applications;
DROP TABLE IF EXISTS jobs;
DROP TABLE IF EXISTS job_categories;
DROP TABLE IF EXISTS employer_profiles;
DROP TABLE IF EXISTS candidate_profiles;
DROP TABLE IF EXISTS accounts_user_groups;
DROP TABLE IF EXISTS accounts_user_user_permissions;
DROP TABLE IF EXISTS accounts_user;
DROP TABLE IF EXISTS django_admin_log;
DROP TABLE IF EXISTS django_content_type;
DROP TABLE IF EXISTS auth_permission;
DROP TABLE IF EXISTS auth_group_permissions;
DROP TABLE IF EXISTS auth_group;
DROP TABLE IF EXISTS django_session;
DROP TABLE IF EXISTS django_migrations;

-- Create Django migrations table
CREATE TABLE django_migrations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    app VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    applied DATETIME NOT NULL
);

-- Create Django session table
CREATE TABLE django_session (
    session_key VARCHAR(40) NOT NULL PRIMARY KEY,
    session_data LONGTEXT NOT NULL,
    expire_date DATETIME NOT NULL,
    INDEX expire_date_idx (expire_date)
);

-- Create auth_group table
CREATE TABLE auth_group (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL UNIQUE
);

-- Create auth_permission table
CREATE TABLE auth_permission (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    content_type_id INT NOT NULL,
    codename VARCHAR(100) NOT NULL,
    UNIQUE KEY content_type_id_codename (content_type_id, codename)
);

-- Create auth_group_permissions table
CREATE TABLE auth_group_permissions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    group_id INT NOT NULL,
    permission_id INT NOT NULL,
    UNIQUE KEY auth_group_permissions_group_id_permission_id (group_id, permission_id),
    CONSTRAINT auth_group_permissions_group_id_fk FOREIGN KEY (group_id) REFERENCES auth_group (id) ON DELETE CASCADE,
    CONSTRAINT auth_group_permissions_permission_id_fk FOREIGN KEY (permission_id) REFERENCES auth_permission (id) ON DELETE CASCADE
);

-- Create django_content_type table
CREATE TABLE django_content_type (
    id INT AUTO_INCREMENT PRIMARY KEY,
    app_label VARCHAR(100) NOT NULL,
    model VARCHAR(100) NOT NULL,
    UNIQUE KEY app_label_model (app_label, model)
);

-- Create django_admin_log table
CREATE TABLE django_admin_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    action_time DATETIME NOT NULL,
    object_id LONGTEXT,
    object_repr VARCHAR(200) NOT NULL,
    action_flag SMALLINT UNSIGNED NOT NULL,
    change_message LONGTEXT NOT NULL,
    content_type_id INT NULL,
    user_id INT NOT NULL,
    CONSTRAINT django_admin_log_content_type_id_fk FOREIGN KEY (content_type_id) REFERENCES django_content_type (id),
    INDEX django_admin_log_content_type_id_idx (content_type_id),
    INDEX django_admin_log_user_id_idx (user_id)
);

-- Create User table
CREATE TABLE accounts_user (
    id INT AUTO_INCREMENT PRIMARY KEY,
    password VARCHAR(128) NOT NULL,
    last_login DATETIME NULL,
    is_superuser TINYINT(1) NOT NULL,
    username VARCHAR(150) NOT NULL UNIQUE,
    first_name VARCHAR(150) NOT NULL,
    last_name VARCHAR(150) NOT NULL,
    email VARCHAR(254) NOT NULL UNIQUE,
    is_staff TINYINT(1) NOT NULL,
    is_active TINYINT(1) NOT NULL,
    date_joined DATETIME NOT NULL,
    user_type VARCHAR(10) NOT NULL
);

-- Create accounts_user_groups table
CREATE TABLE accounts_user_groups (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    group_id INT NOT NULL,
    UNIQUE KEY accounts_user_groups_user_id_group_id (user_id, group_id),
    CONSTRAINT accounts_user_groups_user_id_fk FOREIGN KEY (user_id) REFERENCES accounts_user (id) ON DELETE CASCADE,
    CONSTRAINT accounts_user_groups_group_id_fk FOREIGN KEY (group_id) REFERENCES auth_group (id) ON DELETE CASCADE
);

-- Create accounts_user_user_permissions table
CREATE TABLE accounts_user_user_permissions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    permission_id INT NOT NULL,
    UNIQUE KEY accounts_user_user_permissions_user_id_permission_id (user_id, permission_id),
    CONSTRAINT accounts_user_user_permissions_user_id_fk FOREIGN KEY (user_id) REFERENCES accounts_user (id) ON DELETE CASCADE,
    CONSTRAINT accounts_user_user_permissions_permission_id_fk FOREIGN KEY (permission_id) REFERENCES auth_permission (id) ON DELETE CASCADE
);

-- Create CandidateProfile table
CREATE TABLE candidate_profiles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NULL,
    profile_picture VARCHAR(100) NULL,
    resume VARCHAR(100) NULL,
    phone_number VARCHAR(15) NULL,
    skills LONGTEXT NULL,
    experience LONGTEXT NULL,
    education LONGTEXT NULL,
    about LONGTEXT NULL,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL,
    user_id INT NOT NULL UNIQUE,
    CONSTRAINT candidate_profiles_user_id_fk FOREIGN KEY (user_id) REFERENCES accounts_user (id) ON DELETE CASCADE
);

-- Create EmployerProfile table
CREATE TABLE employer_profiles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    company_name VARCHAR(100) NOT NULL,
    company_logo VARCHAR(100) NULL,
    company_website VARCHAR(200) NULL,
    company_location VARCHAR(100) NULL,
    company_description LONGTEXT NULL,
    phone_number VARCHAR(15) NULL,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL,
    user_id INT NOT NULL UNIQUE,
    CONSTRAINT employer_profiles_user_id_fk FOREIGN KEY (user_id) REFERENCES accounts_user (id) ON DELETE CASCADE
);

-- Create JobCategory table
CREATE TABLE job_categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    created_at DATETIME NOT NULL
);

-- Create Job table
CREATE TABLE jobs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    location VARCHAR(100) NOT NULL,
    description LONGTEXT NOT NULL,
    requirements LONGTEXT NOT NULL,
    salary_min DECIMAL(10, 2) NULL,
    salary_max DECIMAL(10, 2) NULL,
    job_type VARCHAR(20) NOT NULL,
    experience_level VARCHAR(20) NOT NULL,
    application_deadline DATE NULL,
    status VARCHAR(10) NOT NULL,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL,
    category_id INT NULL,
    company_id INT NOT NULL,
    CONSTRAINT jobs_category_id_fk FOREIGN KEY (category_id) REFERENCES job_categories (id) ON DELETE SET NULL,
    CONSTRAINT jobs_company_id_fk FOREIGN KEY (company_id) REFERENCES employer_profiles (id) ON DELETE CASCADE
);

-- Create JobApplication table
CREATE TABLE job_applications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cover_letter LONGTEXT NULL,
    resume VARCHAR(100) NULL,
    status VARCHAR(20) NOT NULL,
    created_at DATETIME NOT NULL,
    candidate_id INT NOT NULL,
    job_id INT NOT NULL,
    UNIQUE KEY job_applications_job_id_candidate_id (job_id, candidate_id),
    CONSTRAINT job_applications_candidate_id_fk FOREIGN KEY (candidate_id) REFERENCES candidate_profiles (id) ON DELETE CASCADE,
    CONSTRAINT job_applications_job_id_fk FOREIGN KEY (job_id) REFERENCES jobs (id) ON DELETE CASCADE
);

-- Create SavedJob table
CREATE TABLE saved_jobs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    created_at DATETIME NOT NULL,
    job_id INT NOT NULL,
    user_id INT NOT NULL,
    UNIQUE KEY saved_jobs_job_id_user_id (job_id, user_id),
    CONSTRAINT saved_jobs_job_id_fk FOREIGN KEY (job_id) REFERENCES jobs (id) ON DELETE CASCADE,
    CONSTRAINT saved_jobs_user_id_fk FOREIGN KEY (user_id) REFERENCES accounts_user (id) ON DELETE CASCADE
);

-- Insert default job categories
INSERT INTO job_categories (name, created_at) VALUES
('Technology', NOW()),
('Healthcare', NOW()),
('Education', NOW()),
('Finance', NOW()),
('Marketing', NOW()),
('Sales', NOW()),
('Customer Service', NOW()),
('Administration', NOW()),
('Engineering', NOW()),
('Design', NOW());

-- Insert admin user (username: admin, password: adminpass)
-- Note: This is a pre-hashed password for "adminpass"
INSERT INTO accounts_user (
    password, 
    is_superuser, 
    username, 
    first_name, 
    last_name, 
    email, 
    is_staff, 
    is_active, 
    date_joined, 
    user_type
) VALUES (
    'pbkdf2_sha256$600000$5YCR6fDlvvbKY5r6FMbcK5$UVq5u2S798SIDkIPRJ2rD1XQjx5ORNZPqAPYW/tH0DI=', -- hashed "adminpass"
    1,
    'admin',
    'Admin',
    'User',
    'admin@example.com',
    1,
    1,
    NOW(),
    'admin'
);

-- Insert necessary content types for Django admin
INSERT INTO django_content_type (app_label, model) VALUES
('admin', 'logentry'),
('auth', 'permission'),
('auth', 'group'),
('contenttypes', 'contenttype'),
('sessions', 'session'),
('accounts', 'user'),
('accounts', 'candidateprofile'),
('accounts', 'employerprofile'),
('jobs', 'jobcategory'),
('jobs', 'job'),
('jobs', 'jobapplication'),
('jobs', 'savedjob');

-- Add necessary permissions
INSERT INTO auth_permission (name, content_type_id, codename) VALUES
('Can add log entry', 1, 'add_logentry'),
('Can change log entry', 1, 'change_logentry'),
('Can delete log entry', 1, 'delete_logentry'),
('Can view log entry', 1, 'view_logentry'),
('Can add permission', 2, 'add_permission'),
('Can change permission', 2, 'change_permission'),
('Can delete permission', 2, 'delete_permission'),
('Can view permission', 2, 'view_permission'),
('Can add group', 3, 'add_group'),
('Can change group', 3, 'change_group'),
('Can delete group', 3, 'delete_group'),
('Can view group', 3, 'view_group'),
('Can add content type', 4, 'add_contenttype'),
('Can change content type', 4, 'change_contenttype'),
('Can delete content type', 4, 'delete_contenttype'),
('Can view content type', 4, 'view_contenttype'),
('Can add session', 5, 'add_session'),
('Can change session', 5, 'change_session'),
('Can delete session', 5, 'delete_session'),
('Can view session', 5, 'view_session'),
('Can add user', 6, 'add_user'),
('Can change user', 6, 'change_user'),
('Can delete user', 6, 'delete_user'),
('Can view user', 6, 'view_user');

-- Record migrations (basic set)
INSERT INTO django_migrations (app, name, applied) VALUES
('contenttypes', '0001_initial', NOW()),
('contenttypes', '0002_remove_content_type_name', NOW()),
('auth', '0001_initial', NOW()),
('auth', '0002_alter_permission_name_max_length', NOW()),
('auth', '0003_alter_user_email_max_length', NOW()),
('accounts', '0001_initial', NOW()),
('admin', '0001_initial', NOW()),
('admin', '0002_logentry_remove_auto_add', NOW()),
('admin', '0003_logentry_add_action_flag_choices', NOW()),
('sessions', '0001_initial', NOW()),
('jobs', '0001_initial', NOW());

COMMIT;

-- Output success message
SELECT 'Job Board MySQL database setup completed successfully!' AS 'Setup Complete';