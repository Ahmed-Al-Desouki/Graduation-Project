# Wellora Healthcare Management System

## Graduation Project Repository

Wellora Healthcare Management System is a healthcare service platform designed to connect patients, doctors, and administrators through one integrated digital ecosystem. The project focuses on improving access to care, simplifying medical coordination, and digitizing important healthcare workflows such as onboarding, appointment scheduling, payment handling, prescription management, reminders, notifications, and administrative review processes.

The system is implemented as a layered backend solution using ASP.NET Core Web API and is designed to integrate with a Flutter mobile application. In its intended full form, the project serves three main actors: patients who need accessible and organized healthcare services, doctors who need a reliable way to manage their professional workflow, and administrators who supervise quality, verification, moderation, and operational control.

## Team Members

- Ahmed Al-Desouki
- Ibrahim Ashraf
- Mahmoud Ashraf

## Repository Status

This repository currently contains the full backend source code, deployment-related files, and backend-to-Flutter integration documentation.

Important note:

- The current repository snapshot clearly includes the ASP.NET Core backend source code.
- It also includes multiple documents prepared for Flutter integration.
- A standalone Flutter source project is not present in this snapshot.
- If your final academic submission requires the complete mobile source code as well, the Flutter project should be added under `src/` before the final hand-in.

## Required Repository Structure

This repository has been organized to match the required submission format:

```text
/src   -> Source code
/exe   -> Executable / published files
README.md
```

Current structure:

```text
.
|-- src
|   `-- WelloraHealthCareManagment
|       |-- WelloraHealthCareManagment.API
|       |-- WelloraHealthCareManagment.Application
|       |-- WelloraHealthCareManagment.Domain
|       |-- WelloraHealthCareManagment.Infrastructure
|       `-- docs
|-- exe
|   `-- README.md
`-- README.md
```

## Project Overview

Wellora is a multi-role healthcare management platform built to support real-world medical service workflows. The backend exposes REST APIs for authentication, patient management, doctor onboarding and verification, doctor search, scheduling, slot generation, appointment booking, payments, reminders, prescriptions, notifications, reviews, support workflows, and administrative operations.

The architecture follows an Onion Architecture style with separated layers for API, application logic, domain logic, and infrastructure. The project is structured for maintainability, modularity, and future mobile integration through Flutter.

## Core Features

- Patient registration, login, and onboarding
- Doctor registration, onboarding, and verification workflow
- Role-based access for Patient, Doctor, and Admin
- JWT authentication with MFA and OTP-related flows
- Public doctor discovery, search, filtering, and ranking
- Doctor scheduling, slot configuration, and slot generation
- Appointment booking and cancellation workflows
- Payment integration using Paymob
- Prescription and medical record management
- Reminder creation, scheduling, and occurrence tracking
- Push notifications with Firebase integration
- Cloudinary-based file and image handling
- Admin dashboard, moderation, audit logging, and support ticket flows
- Swagger-based API exploration and testing

## Technology Stack

### Backend

- C#
- ASP.NET Core Web API
- .NET 9 SDK
- Entity Framework Core 9
- SQL Server
- ASP.NET Core Identity
- JWT Bearer Authentication
- Hangfire
- Swagger / Swashbuckle

### External Integrations

- Firebase Cloud Messaging
- Cloudinary
- SMTP Email Provider
- Google Authentication
- Paymob Payment Gateway
- OpenStreetMap / Nominatim location lookup

### Frontend Integration Target

- Flutter mobile application
