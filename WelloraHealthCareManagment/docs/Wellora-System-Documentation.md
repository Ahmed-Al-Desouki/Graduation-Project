# Wellora HealthCare Management System Documentation

Generated from repository analysis on 2026-04-20.

## 1. Project Overview

`WelloraHealthCareManagment` is an ASP.NET Core Web API for a healthcare platform that supports:

- account registration and login for patients and doctors
- multi-factor authentication with OTP during sign-in
- doctor profile completion and document verification
- doctor discovery, rating, and proximity-based search
- slot configuration and rolling time-slot generation
- appointment booking with Paymob payment integration
- patient medical profile management and doctor access grants
- prescriptions, reminder scheduling, and intake tracking
- admin moderation, notifications, audit logs, and support tickets

The codebase follows an Onion-style layered structure on paper, but the implementation is a practical hybrid of Onion Architecture, layered architecture, and direct EF Core usage.

## 2. Tech Stack

| Area | Observed Implementation |
| --- | --- |
| Runtime | .NET 9 (`net9.0`) |
| API Framework | ASP.NET Core Web API |
| ORM | Entity Framework Core 9 with SQL Server |
| Identity | ASP.NET Core Identity with custom `ApplicationUser` and `ApplicationRole` |
| Authentication | JWT Bearer, Cookie auth, Google login |
| Authorization | Role-based authorization and one explicit admin policy |
| API Docs | Swagger / Swashbuckle |
| Background Jobs | Hangfire with SQL Server storage |
| Email | MailKit |
| Push Notifications | Firebase Admin / FCM |
| File Storage | Cloudinary |
| Payments | Paymob |
| Search | In-memory trie index plus fuzzy matching |
| Reminder Recurrence | Ical.Net |
| Bulk Persistence | EFCore.BulkExtensions |

## 3. Solution Structure

| Project | Responsibility |
| --- | --- |
| `WelloraHealthCareManagment.API` | Controllers, middleware, program bootstrap, Swagger, auth pipeline |
| `WelloraHealthCareManagment.Application` | DTOs, interfaces, command/query handlers, use-case contracts |
| `WelloraHealthCareManagment.Domain` | entities, enums, value objects, domain exceptions, factories |
| `WelloraHealthCareManagment.Infrastructure` | EF Core context, repositories, services, background jobs, external integrations |

Important implementation note:

- The physical structure resembles Onion Architecture.
- The dependency flow is not perfectly pure because infrastructure details leak upward in several places.
- Namespace consistency is weak. The project mixes `HealthCare_`, `WelloraHealthCareManagement`, and `WelloraHealthCareManagment`.
- Some code is duplicated or partially commented out instead of fully removed.

## 4. Architecture Analysis

### 4.1 Pattern Used

The project is best described as a hybrid Onion / Layered Monolith:

- `Domain` contains the core business entities and domain rules.
- `Application` defines interfaces, DTOs, and use-case style handlers.
- `Infrastructure` provides EF Core persistence and most business services.
- `API` exposes HTTP endpoints and wires the pipeline together.

This is not a strict Clean Architecture implementation because:

- many business workflows are implemented directly in infrastructure services instead of application use cases
- some application handlers are registered manually rather than through a mediator
- EF Core context details and persistence behavior strongly shape service logic
- API and infrastructure concerns are coupled through controller assumptions and claim parsing conventions

### 4.2 Layer Responsibilities

#### Controller Layer

Main responsibility:

- define routes
- authorize incoming requests
- read claims
- accept DTOs
- delegate to services or handlers
- translate exceptions into HTTP responses

Observed controller groups:

- Authentication: `AuthController`, `GoogleSginInAuthController`, `MfaController`, `PasswordController`, `DeviceController`
- Patient and doctor experience: `PatientProfileController`, `DoctorProfileController`, `DoctorPublicController`, `DoctorSearchController`
- Scheduling and booking: `DoctorSlotConfigController`, `TimeSlotsController`, `AppointmentsController`, `PaymentController`
- Clinical records: `MedicalRecordsController`, `PrescriptionsController`, `MedicalProfileController`, `FamilyHistoryController`, `SelfMedicationController`, `SocialHistoryController`, `SurgeryController`, `ShareMediclTokenController`
- Reminders and reviews: `ReminderV2Controller`, `ReviewsController`
- Files: `ProfileImageController`, `PatientFilesController`, `DoctorFilesController`
- Admin and support: dashboard, audit, user search, doctor verification, notifications, ticketing, review moderation

Design quality:

- routing is mostly explicit and understandable
- most controllers are thin
- error handling is inconsistent because many controllers use their own `try/catch` blocks
- authorization is inconsistent across modules

#### Service Layer

The service layer is mostly implemented in `Infrastructure\Services`.

Key services include:

- authentication and token lifecycle: `AuthCoreService`, `TokenService`, `GoogleAuthService`, `PasswordService`, `MfaService`, `DeviceService`
- patient and doctor profile management: `PatientProfileService`, `DoctorProfileService`
- discovery and scheduling: `DoctorSearchService`, `DoctorSlotConfigService`, `SlotGenerationService`, `TimeSlotService`
- booking and care delivery: `AppointmentService`, `MedicalRecordService`, `PrescriptionService`
- payment and reminders: `PaymentService`, `PaymobService`, `ReminderV2Service`, `AppointmentReminderService`, `PrescriptionReminderService`
- admin and operations: `AdminDashboardService`, `AdminAuditService`, `UserManagementService`, `UserSearchService`, `DoctorVerificationService`, `TicketService`, `NotificationService`, `ReviewModerationService`

Service design observations:

- business workflows are concentrated in services rather than controllers
- services are async-first and mostly use repository abstractions
- some services still access `HealthCarePlusContext` directly
- transaction boundaries are inconsistent across workflows
- some repositories save changes internally, weakening unit-of-work consistency

#### Repository Layer

Repositories exist mainly inside `Infrastructure\Repositories`.

Examples:

- auth/session/token repositories
- appointment, slot, prescription, payment repositories
- medical-history repositories
- admin repositories
- reminder repositories

Strengths:

- repository names are domain-oriented
- repositories hide many EF queries from controllers

Weaknesses:

- repository style is inconsistent across modules
- some repositories call `SaveChangesAsync` internally while others rely on higher layers
- duplicate registrations exist in DI
- a few repository and interface files are duplicated or commented and left behind

#### Data Layer

The persistence layer is based on:

- `HealthCarePlusContext`
- SQL Server
- ASP.NET Core Identity
- EF Core configurations and migrations

Observed behavior:

- the context inherits from `IdentityDbContext<ApplicationUser, ApplicationRole, int>`
- custom entity configurations are applied in `OnModelCreating`
- timestamp updates are enforced in `SaveChanges` and `SaveChangesAsync`
- migrations live in `WelloraHealthCareManagment.Infrastructure\Migrations`

### 4.3 Dependency Injection Design

`Program.cs` and project-level DI extensions wire the application.

Highlights:

- `AddInfrastructure(builder.Configuration)` registers repositories, services, external integrations, search index, background jobs, and admin services
- `AddApplication()` registers application handlers and application-level services
- `AddDbContext<HealthCarePlusContext>()` uses SQL Server and an update timestamp interceptor
- ASP.NET Core Identity is configured with custom user and role classes
- JWT Bearer, Cookie auth, CORS, Swagger, Hangfire, and HttpContext accessors are configured centrally

Strengths:

- startup composition is centralized
- service registration is broad and feature-complete
- external systems are abstracted behind interfaces in many cases

Weaknesses:

- duplicate registrations exist, for example `IUserDeviceRepository` and `IDoctorVerificationRepository`
- application and infrastructure both contain an `MfaService`
- some middleware classes exist but are not actually used

### 4.4 Separation of Concerns Assessment

What works well:

- profile, booking, payment, reminder, and admin workflows are separated into modules
- controllers usually delegate rather than implement business rules directly
- the domain contains meaningful invariants for appointments, slots, grants, and payments

Where the boundaries blur:

- claim parsing logic is repeated in controllers
- persistence concerns influence service behavior heavily
- some security checks live only in controllers, some only in services, and some are missing entirely
- error handling is split across controllers, middleware, and inline `UseExceptionHandler`

## 5. Program Configuration and Middleware Pipeline

### 5.1 Program.cs Summary

`Program.cs` currently performs the following:

- loads configuration from `appsettings.json` and environment variables
- configures console and debug logging
- registers EF Core SQL Server context
- configures Hangfire with SQL Server storage and starts the Hangfire server
- registers application and infrastructure services
- configures ASP.NET Core Identity
- configures JWT Bearer as the default authentication scheme
- adds cookie authentication as a secondary scheme
- configures Swagger with Bearer token support
- adds one CORS policy named `AllowFrontend`
- registers forwarded headers
- schedules recurring Hangfire jobs for reminders and slots

### 5.2 Middleware Order

Observed request pipeline order:

1. Swagger / Swagger UI
2. HTTPS redirection
3. Routing
4. CORS
5. Forwarded headers
6. Authentication
7. `AccountStatusMiddleware`
8. Authorization
9. Hangfire dashboard
10. inline exception handler
11. request buffering middleware
12. controller mapping

### 5.3 Middleware Analysis

Implemented and active:

- built-in authentication and authorization middleware
- custom `AccountStatusMiddleware`
- built-in exception handler lambda

Implemented but not used:

- `GlobalExceptionMiddleware`
- `UpdateLastActivityMiddleware`

Implication:

- the project already has a more complete custom exception middleware, but the active pipeline uses a simpler inline handler instead
- session last-activity tracking middleware exists but does not currently run

## 6. API Design Explanation

### 6.1 Endpoint Groups

| Area | Main Routes |
| --- | --- |
| Auth | `/api/Auth/register`, `/api/Auth/login`, `/api/Auth/logout`, `/api/Auth/refresh-token`, `/api/Auth/token-status-v2` |
| MFA | `/api/mfa/*` |
| Password | `/api/password/forgot-password`, `/api/password/reset-password` |
| Devices | `/api/devices/*`, `/api/Auth/devices` |
| Patient Profile | `/api/patient/profile` |
| Doctor Profile | `/api/doctor/profile/*` |
| Doctor Discovery | `/api/doctors/search/*`, `/api/doctor/profile/{doctorId}/public` |
| Slot Config | `/api/doctors/{doctorId}/slot-config/*` |
| Time Slots | `/api/timeslots/*` |
| Appointments | `/api/appointments/*` |
| Payments | `/api/payment/*` |
| Medical Profile | `/api/medical-profile`, `/api/medical-history/*`, `/api/share/*` |
| Prescriptions | `/api/prescriptions/*` |
| Medical Records | `/api/appointments/{appointmentId}/medical-record` |
| Reminders | `/api/reminders-v2/*` |
| Reviews | `/api/reviews/*` |
| Files | `/api/profile-image`, `/api/patient/files/*`, `/api/doctor/files/*` |
| Admin | `/api/admin/*`, `/api/notifications`, `/api/tickets/*` |

### 6.2 API Style

Positive design choices:

- routes are feature-oriented
- most actions use HTTP verbs appropriately
- DTOs exist for many request and response shapes
- Swagger support is configured

Issues:

- route naming is inconsistent in places
- controller names and folder names contain typos
- some endpoints expose internal IDs too directly
- some access rules are too broad or missing

## 7. Database Design

### 7.1 Core Identity and Security Tables

Key entities:

- `ApplicationUser`
- `ApplicationRole`
- `RefreshToken`
- `RevokedToken`
- `UserSession`
- `EmailOtp`
- `PatientDevice`
- `UserStatus`

Behavior:

- users are stored in a renamed `Users` table
- roles are stored in a renamed `Roles` table
- `ApplicationUser` contains profile basics, role, profile image link, passkey columns, and timestamps
- `UserStatus` tracks block and suspension state independently from Identity
- refresh tokens are hashed with HMAC before persistence
- active sessions store encrypted refresh-token material and device metadata

### 7.2 Patient and Doctor Profile Tables

Patient-related:

- `Patient`
- `MedicalHistory`
- `FamilyHistoryEntry`
- `SocialHistory`
- `Surgery`
- `PatientSelfMedication`
- `ExternalFile`

Doctor-related:

- `Doctor`
- `DoctorVerification`
- `DoctorAchievement`
- `DoctorSlotConfig`
- `ScheduleException`

Relationships:

- one `ApplicationUser` to one `Patient` or one `Doctor`
- one `Patient` to one `MedicalHistory`
- doctor verification links to uploaded `ExternalFile`
- both patients and doctors can own external files

### 7.3 Scheduling and Appointment Tables

Entities:

- `TimeSlot`
- `Appointment`
- `AppointmentMedicalRecord`
- `MedicalHistoryAccessGrant`
- `MedicalHistoryAccessLog`

Relationship summary:

- one doctor has many slots
- one slot can have one appointment
- one appointment belongs to one doctor and one patient
- one appointment can have one medical record
- one appointment can create one or more medical-history grants

### 7.4 Payment and Prescription Tables

Entities:

- `Payment`
- `Prescription`
- `PrescriptionItem`

Important details:

- payments can exist before an appointment is finalized
- a payment can reference `TimeSlotId` first and later be linked to `AppointmentId`
- prescriptions belong to appointment, doctor, and patient
- prescription items can also drive reminder creation

### 7.5 Reminder, Notification, and Support Tables

Entities:

- `ReminderV2`
- `ReminderOccurrenceLog`
- `ReminderOccurrencesCache`
- `Notification`
- `Ticket`
- `TicketMessage`
- `AdminActionLog`

Purpose:

- support recurring medication and appointment reminders
- cache upcoming occurrences for faster reads
- store in-app notification history
- support patient and admin support conversations
- keep an admin audit trail

### 7.6 Important Relationship Notes

- Patient and doctor use the same integer key as `ApplicationUser`
- `MedicalHistory` is uniquely constrained by `PatientID`
- `DoctorSlotConfig` has a unique index on `(DoctorId, DayOfWeek)`
- reminder cache has unique filtered indexes to avoid duplicate cached occurrences
- review soft-delete metadata exists for moderation use

## 8. Full System Flow Understanding

## 8.1 Authentication Flow

### Registration Process

Entry point:

- `POST /api/Auth/register`

Request model:

- `FullName`
- `Email`
- `Password`
- `Role` limited to `Patient` or `Doctor`
- optional `ProfileImageFile`

Flow:

1. `AuthController` receives a multipart form request.
2. `AuthCoreService.RegisterAsync` checks whether the email already exists.
3. A transaction begins.
4. A new `ApplicationUser` is created with:
   - `EmailConfirmed = true`
   - `TwoFactorEnabled = true`
   - `Role = Patient` or `Doctor`
5. ASP.NET Core Identity creates the user and assigns the selected role.
6. The platform creates either:
   - a `Patient` record with an initial `MedicalHistory`, or
   - a `Doctor` record with default specialization and inactive-complete profile state
7. A `UserStatus` record is created if missing.
8. The transaction commits.
9. A profile image is uploaded, or an avatar is generated, after the main transaction.

System response:

- success response if identity creation and profile creation succeed
- validation errors if email, password, or role are invalid

Important observation:

- MFA is effectively enabled for all newly registered users because `TwoFactorEnabled` defaults to `true`

### Login Process

Entry point:

- `POST /api/Auth/login`

Request model:

- `Email`
- `Password`
- optional `OtpCode`
- optional `UsePasskey`

Flow:

1. `AuthCoreService.LoginAsync` loads the user by email.
2. Password is validated.
3. `UserStatus` is checked for block or suspension.
4. If no OTP is provided:
   - an MFA token is generated
   - an OTP is generated and sent by email
   - the response indicates `RequiresMfa = true`
5. If an OTP is provided:
   - the OTP is verified through `MfaService`
6. A login session is created.
7. Access token and refresh token are generated.
8. Old sessions may be revoked if the configured device limit is exceeded.
9. Refresh token is set in a cookie and also returned in the response body.

System response:

- either an MFA challenge or a full login token response

Edge cases:

- blocked or suspended accounts are denied
- expired or invalid OTP returns failure
- users exceeding device count lose the oldest active session

### Token Generation

JWT content includes:

- `UserID`
- `ClaimTypes.NameIdentifier`
- `Name`
- `Email`
- custom `Role`
- `ClaimTypes.Role`
- `sub`
- `jti`

Configured token behavior:

- issuer and audience validation enabled
- signing key validation enabled
- `ClockSkew = TimeSpan.Zero`
- default expiration configured as 1440 minutes in `appsettings.json`

Refresh token behavior:

- raw refresh token is returned to the client
- HMAC hash is stored in the database
- session record stores encrypted token material
- refresh rotates the old refresh token and revokes the old access-token `jti`

### Authorization Flow

Mechanisms in use:

- `[Authorize]`
- `[Authorize(Roles = "...")]`
- one named policy: `RequireAdmin`
- `AccountStatusMiddleware`

Runtime sequence:

1. JWT is validated.
2. user claims are built
3. `AccountStatusMiddleware` checks whether the user is still active
4. controller-level role authorization runs

Weak point:

- authorization enforcement is not consistent across all controllers and service methods

## 8.2 Patient Flow

### Account Creation to Full Usage Journey

1. Patient registers through `/api/Auth/register` with role `Patient`.
2. System creates:
   - `ApplicationUser`
   - `Patient`
   - initial `MedicalHistory`
   - `UserStatus`
3. Patient logs in using email, password, and OTP.
4. Patient completes onboarding through `PATCH /api/patient/profile/onboarding`.
5. System stores:
   - full name
   - phone number
   - address or reverse-geocoded address
   - date of birth
   - gender
   - blood type
   - height and weight
   - profile completion flag
6. Patient can upload profile images and personal files.
7. Patient can search for doctors by:
   - text query
   - specialization
   - top rating
   - nearby location
8. Patient can inspect doctor public profile and available time slots.
9. Patient books an appointment using the paid booking path.
10. Payment is created and redirected to Paymob.
11. Paymob callback marks the payment as paid and finalizes the appointment.
12. System creates appointment reminders and optional medical-history access grants.
13. Patient can:
   - view appointments
   - cancel allowed appointments
   - manage reminder schedules
   - manage medical profile data
   - grant or extend medical-history access
   - view prescriptions
   - leave reviews after completed visits
   - create support tickets

### Actions a Patient Can Perform

- register and log in
- complete onboarding
- upload files and profile image
- search doctors
- view doctor profile and slots
- pay for and book appointments
- cancel appointments
- manage longitudinal medical profile
- manage reminders and medication adherence
- view prescriptions
- review doctors
- receive notifications
- submit support tickets

### Data Interactions in the Patient Flow

- `ApplicationUser`, `Patient`, `MedicalHistory`
- `TimeSlot`, `Payment`, `Appointment`
- `MedicalHistoryAccessGrant`, `MedicalHistoryAccessLog`
- `Prescription`, `PrescriptionItem`
- `ReminderV2`, occurrence log and cache
- `Review`, `Notification`, `Ticket`, `TicketMessage`

## 8.3 Doctor Flow

### Full Lifecycle of Doctor Usage

1. Doctor registers through `/api/Auth/register` with role `Doctor`.
2. System creates:
   - `ApplicationUser`
   - `Doctor`
   - `UserStatus`
3. Doctor logs in and completes doctor profile:
   - full name
   - phone
   - date of birth
   - specialization
   - years of experience
   - consultation fee
   - national ID
   - bio
4. Doctor can update basic info and location later.
5. Doctor uploads verification documents.
6. A `DoctorVerification` record is created or reset to `Pending`.
7. Admin reviews verification and approves or rejects it.
8. Doctor creates or updates weekly slot configuration.
9. `DoctorSlotConfigService` generates rolling time slots using rules and exceptions.
10. Doctor receives booked appointments after successful patient payments.
11. Doctor can:
   - view appointment lists
   - confirm appointments
   - start appointments
   - complete appointments
   - create medical records
   - create prescriptions and prescription items
   - create follow-up appointments
   - cancel and block slots when needed
   - manage achievements
   - receive notifications and respond to support workflows

### Doctor Permissions and Features

- authenticated access to doctor-only profile features
- schedule and exception management
- appointment lifecycle transitions
- medical record creation and updates
- prescription creation and item-level updates
- uploaded documents and achievements
- notifications

Important practical note:

- the schedule management controller currently exposes mutating slot-config actions without active authorization attributes, which weakens the intended doctor-only boundary

## 8.4 Shared Flow Between Doctor and Patient

The shared care loop currently works like this:

1. patient searches doctor and selects a slot
2. patient pays through Paymob
3. successful callback creates appointment
4. optional medical-history access grant is created for the doctor
5. reminder jobs prepare notifications for both patient and doctor
6. doctor reviews appointment queue
7. doctor may confirm and start the appointment
8. doctor creates medical record and prescription
9. prescription items can create medication reminders for the patient
10. patient later views prescriptions and reminder schedules
11. patient can review the doctor after completion

Medical-history access is one of the most important cross-role features:

- appointment booking can create a grant automatically
- patient can later extend or change grant permissions
- doctor view is supposed to require an active grant
- access is logged in `MedicalHistoryAccessLog`

## 9. User Stories

## 9.1 Patient User Stories

### Story 1: Register and Access the Platform

Goal:

- As a patient, I want to create a secure account so I can use healthcare features.

Actions:

1. open the registration form
2. enter name, email, password, and choose `Patient`
3. optionally upload a profile image
4. submit the registration form
5. log in with email and password
6. enter the OTP sent to email

System responses:

- validates required fields
- rejects duplicate email
- creates identity account, patient record, medical history record, and user status
- sends OTP at login
- issues JWT and refresh token after successful OTP verification

Edge cases:

- duplicate email
- invalid password length
- OTP expired after a short window
- blocked or suspended account cannot log in

### Story 2: Complete Profile and Health Basics

Goal:

- As a patient, I want to complete my onboarding so the platform can use my medical basics in later care flows.

Actions:

1. open patient profile onboarding
2. enter phone number, address, current location, date of birth, gender, blood type, height, and weight
3. save changes

System responses:

- updates profile and linked medical history
- reverse-geocodes address when coordinates are provided
- sets `IsProfileCompleted = true`

Edge cases:

- invalid latitude or longitude
- invalid height or weight range
- partial updates leaving some fields null

### Story 3: Find a Doctor and Book an Appointment

Goal:

- As a patient, I want to discover doctors, choose a slot, and book an appointment.

Actions:

1. search doctors by name, specialty, or nearby location
2. inspect doctor public profile
3. view available slots
4. choose a slot
5. optionally request medical-history sharing
6. proceed to payment

System responses:

- returns active doctor search results
- exposes available slot times
- creates a pending payment linked to the slot
- redirects to Paymob
- after callback, creates appointment and books the slot
- creates reminders and optional access grants

Edge cases:

- slot becomes unavailable before callback
- payment fails
- appointment creation after payment partially fails
- callback is duplicated

### Story 4: Manage Longitudinal Health Data

Goal:

- As a patient, I want to maintain my medical profile so future doctors can review reliable information.

Actions:

1. open medical profile
2. update blood type, allergies, chronic conditions, height, and weight
3. manage surgery history
4. manage family history
5. manage social history
6. manage self-medication entries

System responses:

- updates or inserts the related record sets
- stores core medical profile in the linked medical history
- can generate a share token for profile sharing

Edge cases:

- malformed list data
- unauthorized access to another patient's records
- anonymous share endpoints using raw IDs instead of secure share tokens

### Story 5: Continue Care After the Visit

Goal:

- As a patient, I want to receive prescriptions and reminders after a consultation.

Actions:

1. attend completed appointment
2. check prescriptions
3. receive reminder schedules
4. confirm, snooze, or skip reminder occurrences
5. review the doctor
6. contact support if needed

System responses:

- doctor-issued prescriptions become visible
- reminder engine generates future occurrences
- intake confirmation updates logs and cache
- review is allowed only after a completed appointment
- support ticket is stored and visible to admins

Edge cases:

- reminder cache miss
- duplicate review attempt
- prescription access without correct ownership validation

## 9.2 Doctor User Stories

### Story 1: Register and Become an Active Provider

Goal:

- As a doctor, I want to register and complete my professional profile so patients can book with me.

Actions:

1. register with role `Doctor`
2. log in with OTP
3. complete doctor profile
4. upload verification documents

System responses:

- creates identity and doctor records
- stores profile completion data
- creates pending verification records linked to uploaded files
- allows admin review later

Edge cases:

- missing required professional fields
- rejected verification requires document replacement

### Story 2: Publish Availability

Goal:

- As a doctor, I want to define my weekly schedule and exceptions so patients can book accurate times.

Actions:

1. configure day-based slot rules
2. generate slots from configuration
3. add day-off or custom-hours exceptions
4. manually create or block slots when needed

System responses:

- stores weekly slot config
- generates rolling future slots
- blocks or regenerates slots when exceptions are added or removed
- can cancel affected appointments and related reminders

Edge cases:

- overlapping slots
- invalid time ranges
- booked appointments inside removed schedule windows
- controller currently lacks proper authorization on mutating config endpoints

### Story 3: Manage Appointments

Goal:

- As a doctor, I want to work through my appointment queue from confirmation to completion.

Actions:

1. view booked appointments
2. confirm appointment
3. start consultation
4. complete consultation
5. create a follow-up appointment if needed
6. cancel and block when necessary

System responses:

- transitions appointment states
- updates timestamps
- can refund patient depending on cancellation initiator and policy
- can create follow-up bookings using existing or new slots

Edge cases:

- invalid state transition
- attempting to cancel a completed appointment
- refund failure during doctor cancellation

### Story 4: Deliver Care and Continue Treatment

Goal:

- As a doctor, I want to record the consultation and prescribe treatment.

Actions:

1. open appointment
2. access patient medical profile if a grant exists
3. create medical record
4. create prescription
5. add medication items with reminder settings

System responses:

- checks appointment ownership for create and update operations
- stores consultation notes and follow-up metadata
- creates prescriptions and reminder schedules
- logs medical-history access

Edge cases:

- no active medical-history access grant
- unauthorized access to another doctor's appointment
- prescription read endpoints without adequate ownership checks

## 10. Security Implementation and Security Review

### 10.1 Security Controls Currently Present

- ASP.NET Core Identity for user management
- JWT Bearer token validation
- refresh tokens stored as HMAC hashes
- session tracking with device metadata
- block and suspension enforcement through middleware
- role-based authorization on many endpoints
- OTP-based MFA flow
- Google sign-in support
- medical-history access grants and access logs

### 10.2 Security Findings

#### Critical: Secrets Stored in Source-Controlled `appsettings.json`

Observed sensitive configuration includes:

- SQL Server credentials
- JWT signing keys
- refresh-token cryptographic keys
- Cloudinary credentials
- SMTP credentials
- Google client secret
- Paymob API and HMAC secrets
- Firebase service-account path

Risk:

- compromise of source control or a copied config file compromises the full environment

Recommendation:

- move all secrets to environment variables, user secrets, Azure Key Vault, or another secret manager
- rotate all exposed secrets immediately

#### Critical: `PaymentController` Has No Authorization Guard

Risk:

- payment creation, refund, appointment payment lookup, and patient payment history are callable without `[Authorize]`
- `CreatePaymentRequest` contains `PatientId`, which is trusted from the request body instead of derived from claims

Impact:

- an attacker may create or inspect payment flows for other users
- refunds or payment history may be exposed if service-level checks are insufficient

Recommendation:

- add `[Authorize]`
- derive patient identity from JWT claims only
- verify appointment and slot ownership inside the service

#### Critical: `DoctorSlotConfigController` Mutating Endpoints Are Exposed

Risk:

- the class-level `[Authorize]` is commented out
- only the read endpoint is explicitly `[AllowAnonymous]`
- write endpoints currently lack any explicit authorization

Impact:

- schedule manipulation may be callable by anonymous or untrusted users

Recommendation:

- restore class-level role-based authorization immediately
- validate `doctorId` against the current doctor claim unless caller is admin

#### High: Sensitive Read Endpoints Lack Ownership Checks

Examples:

- appointment details retrieval
- medical-record retrieval
- prescription retrieval by ID
- prescription retrieval by appointment

Risk:

- any authenticated user may read clinical or booking data that should be limited to the patient, doctor, or admin involved

Recommendation:

- enforce ownership checks in services, not only in controllers

#### High: Anonymous Share Endpoints Use Raw IDs

Observed pattern:

- several medical-history share endpoints are anonymous and accept `patientId` or `medicalHistoryId` directly

Risk:

- predictable IDs can expose health data without a secure share token or active grant

Recommendation:

- require secure share tokens or doctor grant validation for all anonymous sharing

#### Medium: Refresh Token Is Returned in Both Cookie and JSON

Risk:

- increases exposure surface for the refresh token

Recommendation:

- choose one transport strategy, preferably secure `HttpOnly` cookie for browser clients

#### Medium: Logout Revocation Lifetime Does Not Match Token Lifetime

Observed behavior:

- JWT expiration is configured as 1440 minutes
- logout revocation writes a revoked-token expiry around 15 minutes

Risk:

- a logged-out access token may remain valid after the revocation record expires

Recommendation:

- align revocation retention with actual JWT lifetime

#### Medium: HTTPS Metadata Validation Disabled

Observed setting:

- `RequireHttpsMetadata = false`

Recommendation:

- enable HTTPS metadata outside development

#### Medium: Relaxed Password Policy

Observed configuration:

- no required digit
- no required uppercase
- no required non-alphanumeric
- minimum length 6

Recommendation:

- strengthen password rules or rely on passkeys / external identity for higher assurance

## 11. Error Handling Strategy

### Current Behavior

The project uses several overlapping patterns:

- controller-level `try/catch` blocks
- built-in `UseExceptionHandler` lambda
- domain exceptions in entities
- custom `GlobalExceptionMiddleware` file that is not currently in the active pipeline

### Strengths

- many controllers prevent raw exception leakage
- domain entities enforce invalid-state transitions
- service-level exceptions are often translated into user-facing HTTP responses

### Weaknesses

- no single global, structured error envelope is enforced
- active exception middleware is less capable than the custom unused one
- controllers duplicate error translation logic
- some responses return `500` where `400`, `403`, or `404` would be more correct

### Recommendation

- activate one global exception middleware
- standardize response shape with fields like `traceId`, `code`, `message`, and `details`
- let controllers stay thin and avoid repeated `try/catch` unless needed for custom behavior

## 12. Logging Strategy

### What Exists

- console logging
- debug logging
- service-level `ILogger<T>` usage
- Paymob integration logging
- reminder scheduling logs
- admin audit logs persisted in the database
- notification and medical-history access logging

### Strengths

- important operational flows already emit logs
- admin actions have durable audit persistence
- payment callback and reminder flows are instrumented

### Gaps

- no consistent correlation ID strategy
- no centralized structured logging sink
- no clear PII redaction policy
- duplicate or verbose logs may appear in some long-running flows

### Recommendation

- add structured logging with Serilog or OpenTelemetry
- enrich logs with request ID, user ID, appointment ID, payment ID, and job ID
- avoid logging secrets, OTPs, and medical payloads

## 13. Performance Optimization Review

### Existing Positive Choices

- EF indexes added through migrations
- bulk slot generation with `EFCore.BulkExtensions`
- cached reminder occurrences
- in-memory doctor search index
- async methods used widely across repositories and services

### Improvement Opportunities

#### Database Query Optimization

- add `AsNoTracking()` to read-only queries where entity tracking is not needed
- review heavy include chains for profile, booking, and admin dashboard endpoints
- centralize pagination for list endpoints with potentially large result sets
- use projections earlier to avoid loading full aggregates when only DTO fields are needed

#### Caching

- move search and reminder cache state to a distributed cache if multiple instances will run
- cache low-volatility doctor public profiles and specialization lists
- cache admin dashboard aggregates with short TTLs

#### Async and Persistence Discipline

- remove unnecessary internal `SaveChangesAsync()` calls from repositories
- group writes into explicit transaction boundaries
- ensure callback and reminder flows are idempotent

## 14. Scalability Review

### Current Scalability Profile

The system is a feature-rich monolith. That is appropriate for an academic or early-stage product because:

- deployment is simpler
- transaction boundaries stay local
- shared relational data is easy to reason about

### Scaling Concerns

- Hangfire, reminder generation, callback handling, and notification sending will compete with core API traffic under load
- in-memory search index is local to a single node
- reminder occurrence cache and background jobs assume a shared SQL-centric deployment model

### Microservices Possibility

If the platform grows, the most likely future service boundaries are:

- Identity and authentication service
- Doctor search and discovery service
- Booking and scheduling service
- Payments service
- Reminder and notification service
- Admin operations service

This split should happen only after stabilizing authorization, event boundaries, and transaction patterns in the current monolith.

### API Versioning

Current state:

- no visible API versioning strategy

Recommendation:

- add URI or header versioning before major contract changes
- especially important for auth, reminders, booking, and payment endpoints

## 15. Strengths, Weaknesses, and Suggested Improvements

### Strengths

- broad product scope with real healthcare workflows
- clear separation into API, Application, Domain, and Infrastructure projects
- meaningful domain rules for slots, appointments, grants, and payments
- reminder engine is relatively advanced
- background-job support is already integrated
- admin tooling is richer than in many student projects

### Weaknesses

- security boundaries are inconsistent
- secret management is unsafe
- namespace and naming consistency is weak
- duplicate code and commented legacy code increase maintenance cost
- error handling strategy is fragmented
- local build verification is currently blocked by SDK environment issues

### Suggested Improvements

1. Fix authorization holes first.
2. Remove secrets from committed configuration and rotate all exposed credentials.
3. Centralize exception handling and response formatting.
4. Move identity extraction and ownership checks into reusable policies or service guards.
5. Standardize repository save behavior and transaction ownership.
6. Remove commented dead code and duplicate service registrations.
7. Add API versioning and consistent pagination.
8. Introduce structured logging and request correlation.
9. Add automated tests around auth, booking, payment callback idempotency, and grant enforcement.

## 16. Limitations and Assumptions

- This documentation is based on the repository snapshot available on 2026-04-20.
- Some controllers and services contain commented legacy implementations that are not part of the active runtime.
- The architecture is described based on actual code behavior, not only on project names.
- Build verification in this environment did not complete successfully because `dotnet build` failed during restore with local SDK resolver errors (`MSB4276` around missing workload resolver SDK folders), so runtime behavior was validated through code inspection rather than a successful clean build.

## 17. Final Architectural Assessment

This project is a strong feature-rich healthcare API monolith with a recognizable Onion Architecture intent and a substantial amount of real-world workflow logic. The most impressive areas are the end-to-end booking lifecycle, the reminder engine, the doctor verification/admin subsystem, and the fact that the domain model contains genuine business rules instead of only passive data classes.

The most urgent work is not adding more features. It is hardening what already exists:

- enforce ownership and role checks everywhere
- externalize secrets
- simplify exception handling
- clean duplicated code and registrations
- stabilize build and deployment setup

Once those foundations are fixed, the system can become a much stronger production-ready base.
