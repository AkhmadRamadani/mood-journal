# Moodie Laravel Backend Development Tasks

This document outlines the tasks required to build a robust Laravel backend with a Filament Admin panel and RESTful API for the Moodie Flutter application.

## 1. Project Setup
- [ ] Initialize a new Laravel project.
- [ ] Configure the database connection (`.env`).
- [ ] Set up basic environment configurations (Mail, Queue, etc.).

## 2. Authentication & Security
- [ ] Install and configure Laravel Sanctum for API token-based authentication.
- [ ] Create API endpoints for user registration, login, logout, and profile management.
- [ ] Ensure secure password hashing and token management.

## 3. Database Design & Migrations
- [ ] Design the database schema for the Moodie app.
- [ ] Create migrations for the `users` table (extending the default table as needed, e.g., adding profile fields).
- [ ] Create migrations for the `moods` table (e.g., `user_id`, `mood_type`, `emotion`, `title`, `description`, `date`).
- [ ] Set up foreign key constraints and indexes.

## 4. Eloquent Models
- [ ] Create the `User` model with relationships to moods.
- [ ] Create the `Mood` model with relationships to the user.
- [ ] Implement model factories and seeders for testing and development.

## 5. API Endpoints Development
- [ ] Develop robust RESTful API endpoints for the Flutter app.
- [ ] **Auth API**: `/api/login`, `/api/register`, `/api/logout`, `/api/user`.
- [ ] **Mood API**:
  - `GET /api/moods` (List user's moods)
  - `POST /api/moods` (Record a new mood)
  - `GET /api/moods/{id}` (Get specific mood details)
  - `PUT /api/moods/{id}` (Update a mood)
  - `DELETE /api/moods/{id}` (Delete a mood)
- [ ] Implement API Resource classes for formatting JSON responses.
- [ ] Implement request validation (FormRequests) for all incoming API data.

## 6. Filament Admin Panel Setup
- [ ] Install the Filament package (`filament/filament`).
- [ ] Configure the Filament panel (Theme, Branding).
- [ ] Create Filament Resources:
  - **UserResource**: For managing application users (View, Edit, Delete).
  - **MoodResource**: For viewing and managing user mood entries.
- [ ] Implement filters and search functionality within the Filament resources for easy data management.

## 7. Testing & Quality Assurance
- [ ] Write Feature tests for all API endpoints to ensure correct behavior.
- [ ] Write Unit tests for complex business logic.
- [ ] Ensure all tests pass and handle edge cases gracefully.

## 8. Deployment Preparation
- [ ] Optimize the application for production (`php artisan optimize`).
- [ ] Set up CORS configuration for the API.
- [ ] Document the API endpoints (e.g., using Scribe or Swagger) for the Flutter development team.
