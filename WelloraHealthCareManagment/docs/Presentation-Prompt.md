# Presentation Prompt for Slide Generation

Use the following prompt to generate a professional presentation about the `WelloraHealthCareManagment` ASP.NET Core Web API project.

## Prompt

Create a 12-slide technical presentation about the `WelloraHealthCareManagment` ASP.NET Core Web API project. The presentation should be specific to this codebase, not generic. Use a clean professional design suitable for a graduation project defense or technical walkthrough.

For each slide, provide:

- slide title
- 4 to 6 bullet points
- speaker notes with a short explanation paragraph

Base the content on these project facts:

- the backend is a .NET 9 ASP.NET Core Web API
- the solution uses a layered Onion-style structure with API, Application, Domain, and Infrastructure projects
- persistence uses EF Core 9 with SQL Server and ASP.NET Core Identity
- the system supports patients, doctors, and admins
- authentication uses JWT with refresh tokens and OTP-based MFA during login
- doctors can complete profiles, submit verification documents, configure slot schedules, and manage appointments
- patients can onboard, search doctors, pay for bookings, manage medical profiles, receive reminders, and review doctors
- payments are integrated with Paymob
- files are stored through Cloudinary
- notifications use Firebase
- background jobs use Hangfire
- the codebase has strengths but also important security and authorization gaps

Generate the slides exactly in this structure:

### Slide 1: Introduction

Bullet points:

- project name: Wellora HealthCare Management API
- healthcare platform for patient, doctor, and admin workflows
- built as a backend-first Web API project
- focuses on appointments, records, payments, and reminders

Speaker notes:

Explain that this project is a healthcare platform backend designed to connect patients and doctors through authenticated booking, medical-profile sharing, prescriptions, reminders, and admin operations.

### Slide 2: Problem Statement

Bullet points:

- healthcare workflows are often fragmented across many tools
- patients need one place for appointments, reminders, and medical profile management
- doctors need schedule control, verification, and prescription workflows
- admins need moderation, audit, and support tools

Speaker notes:

Explain the business problem: fragmented healthcare coordination creates friction for patients and providers. This system tries to centralize those operations in one API platform.

### Slide 3: Solution Overview

Bullet points:

- unified API for patients, doctors, and admins
- secure login with JWT and MFA
- doctor discovery and booking with payment integration
- clinical follow-up through records, prescriptions, and reminders

Speaker notes:

Describe the platform at a high level and show how the modules work together from login through treatment follow-up.

### Slide 4: System Architecture

Bullet points:

- API layer for controllers and HTTP endpoints
- Application layer for DTOs, interfaces, and use-case handlers
- Domain layer for entities and business rules
- Infrastructure layer for EF Core, repositories, and external services
- hybrid Onion / layered monolith in practice

Speaker notes:

Explain that the project is organized according to Onion Architecture principles, but the actual implementation is a practical hybrid where infrastructure services hold much of the business logic.

### Slide 5: Authentication Flow

Bullet points:

- registration creates `ApplicationUser` plus role-specific patient or doctor records
- login validates password then sends OTP
- successful OTP verification creates session, JWT, and refresh token
- account status middleware blocks suspended or blocked users
- Google login is also supported

Speaker notes:

Walk through registration, login, MFA, token generation, refresh behavior, and authorization. Mention that refresh tokens are hashed in storage and sessions are device-aware.

### Slide 6: Patient Flow

Bullet points:

- patient registers and completes onboarding
- patient searches doctors by name, specialty, rating, or nearby location
- patient selects slot and pays through Paymob
- successful payment creates appointment and reminders
- patient manages medical profile, prescriptions, and reviews

Speaker notes:

Describe the full patient journey from account creation to consultation follow-up and ongoing medication reminders.

### Slide 7: Doctor Flow

Bullet points:

- doctor registers and completes professional profile
- doctor uploads verification documents for admin approval
- doctor configures weekly slot rules and exceptions
- doctor manages appointments, medical records, and prescriptions
- doctor can create follow-up appointments and receive notifications

Speaker notes:

Explain the doctor lifecycle and emphasize that the doctor side is not only profile management but also operational scheduling and clinical output.

### Slide 8: API Design

Bullet points:

- feature-based controllers for auth, profiles, scheduling, payments, reminders, and admin
- role-based routes for patient, doctor, and admin use cases
- Swagger enabled for exploration and testing
- DTO-driven request and response models
- some route and authorization consistency issues remain

Speaker notes:

Summarize the API structure and mention that the endpoint design is modular, but some authorization boundaries need strengthening.

### Slide 9: Database Design

Bullet points:

- SQL Server with EF Core 9 migrations
- Identity tables extended by `ApplicationUser` and `ApplicationRole`
- main entities: Patient, Doctor, TimeSlot, Appointment, Payment, Prescription, ReminderV2
- medical-history and access-grant tables support controlled sharing
- admin tables include notifications, tickets, and audit logs

Speaker notes:

Explain the main database entities and how the schema supports both transactional booking flows and longitudinal healthcare data.

### Slide 10: Security Implementation

Bullet points:

- JWT Bearer authentication and refresh-token rotation
- OTP-based MFA during standard login
- role-based authorization and account-status middleware
- medical-history access grants and logs
- important risks: plaintext secrets, auth gaps, and some exposed endpoints

Speaker notes:

Present both the implemented security controls and the major weaknesses discovered in the review. This slide should be honest and specific.

### Slide 11: Challenges and Solutions

Bullet points:

- challenge: managing complex reminder recurrence and caching
- challenge: generating and regenerating doctor slots safely
- challenge: integrating external payment callback flow
- challenge: keeping admin, doctor, and patient workflows in one monolith
- solution: use Hangfire, EF Core, service abstractions, and explicit domain rules

Speaker notes:

Discuss the most complex engineering areas and how the current design attempts to solve them.

### Slide 12: Future Improvements

Bullet points:

- fix authorization gaps and move all secrets out of configuration files
- centralize exception handling and structured logging
- add automated integration tests for auth, booking, and payments
- add API versioning and stronger ownership validation
- consider distributed caching and service decomposition if scale grows

Speaker notes:

End with a realistic roadmap focused on hardening the current system before introducing major new features.

## Output Style Requirements

- keep the tone professional and technical
- do not invent features not present in the codebase
- make the notes easy to speak during a live presentation
- keep each slide readable and not overloaded
