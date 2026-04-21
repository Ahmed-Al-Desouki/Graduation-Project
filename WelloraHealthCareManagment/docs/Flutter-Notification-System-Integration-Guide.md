# Wellora Notification System Integration Guide

Prepared for the Flutter Team

Version: 1.0
Prepared on: 2026-04-21
Prepared by: Ahmed Al-Desouki

## 1. Purpose

This document explains how the Wellora notification system works after the latest backend integration work. It is written for the Flutter team so the mobile app can consume notifications safely, display them correctly, and navigate the user to the right screen without conflicts.

This guide covers:

- What has been implemented on the backend
- Which business events now generate notifications
- Which REST endpoints Flutter must use
- The difference between in-app notifications and push payload data
- How to register FCM tokens and keep them updated
- How to handle review-request notifications after appointment completion
- How to map payload keys like `doctorId`, `appointmentId`, `patientId`, and `reviewId`

## 2. System Architecture

The notification system now has two output channels:

1. In-app notifications
   - Stored in the backend database
   - Retrieved through `GET /api/notifications`
   - Used for notification center / inbox UI

2. Push notifications via Firebase Cloud Messaging (FCM)
   - Sent to registered device tokens
   - Used for foreground, background, and terminated-app delivery
   - Carry extra routing data inside the push payload

Important:

- The backend stores standard notification fields in the database:
  - `id`
  - `userId`
  - `title`
  - `message`
  - `type`
  - `isRead`
  - `readAt`
  - `createdAt`
  - `relatedEntityType`
  - `relatedEntityId`

- Extra routing fields such as `doctorId`, `appointmentId`, `reviewId`, and `patientId` are currently sent inside the FCM push payload, not inside the stored `NotificationDto`.

Flutter should therefore treat:

- `GET /api/notifications` as the source for notification center history
- FCM payload data as the source for deep-link routing metadata

## 3. Implemented Notification Events

The backend currently emits notifications for the following business events:

### Authentication and onboarding

- `Welcome`
  - Sent to a newly registered patient or doctor

- `DoctorRegistrationSubmitted`
  - Sent to admins when a doctor registers

### Doctor profile and verification

- `DoctorProfileCompleted`
  - Sent to doctor after profile completion

- `DoctorVerificationSubmitted`
  - Sent to doctor when a verification document is submitted or re-submitted
  - Sent to admins when a doctor uploads or replaces a verification document

- `DoctorApproved`
  - Sent to doctor after admin approval

- `DoctorRejected`
  - Sent to doctor after admin rejection

### Account management by admin

- `AccountBlocked`
- `AccountSuspended`
- `AccountUnsuspended`
- `AccountUnblocked`

### Appointment lifecycle

- `AppointmentBooked`
  - Sent to patient and doctor

- `AppointmentCancelledByPatient`
  - Sent to patient and doctor

- `AppointmentCancelledByDoctor`
  - Sent to patient and doctor

- `ReviewRequested`
  - Sent to patient immediately after doctor completes the appointment
  - This notification is critical for review flow
  - Push payload includes `doctorId` and `appointmentId`

### Payments

- `PaymentPending`
- `PaymentSucceeded`
- `PaymentFailed`
- `RefundProcessed`

### Prescriptions

- `PrescriptionCreated`
- `PrescriptionUpdated`

### Reviews

- `ReviewCreated`
- `ReviewUpdated`
- `ReviewDeletedByPatient`
- `ReviewDeleted`
  - Admin moderation deletion event

### Tickets and support

- `TicketCreated`
  - Sent to admins when user opens a ticket or updates it

- `TicketResponse`
  - Sent to the end user when admin responds

- `TicketClosed`
  - Sent to the end user when admin closes the ticket

### Reserved

- `SystemAlert`

## 4. Review Flow After Appointment Completion

This is the most important business flow added in the latest update.

### What happens now

When a doctor calls the appointment completion action:

- Backend marks the appointment as completed
- Backend sends a `ReviewRequested` notification to the patient
- The push payload contains:
  - `appointmentId`
  - `doctorId`

### Why `doctorId` matters

Flutter needs `doctorId` so the patient can be routed directly to the review form for that doctor without needing extra lookup logic.

### What happens when the patient submits the review

When patient calls `POST /api/reviews`:

- Backend validates that the patient has a completed appointment with the doctor
- Backend creates the review
- Backend sends a push/in-app notification to the doctor
- Push payload includes:
  - `reviewId`
  - `doctorId`
  - `patientId`

## 5. Required Endpoints for Flutter

### 5.1 Register device token

Endpoint:

`POST /api/auth/register-device`

Authorization:

- Bearer token required

Request body:

```json
{
  "fcmToken": "your-fcm-token"
}
```

Response:

```json
{
  "success": true
}
```

Use this:

- Immediately after login
- Whenever FCM token changes
- After reinstall if token changes

### 5.2 Unregister device token

Endpoint:

`DELETE /api/auth/unregister-device`

Authorization:

- Bearer token required

Request body:

```json
{
  "fcmToken": "your-fcm-token"
}
```

### 5.3 Fetch notifications list

Endpoint:

`GET /api/notifications?unreadOnly=false&page=1&pageSize=20`

Authorization:

- Bearer token required

Sample response:

```json
{
  "notifications": [
    {
      "id": "2d7ad9e2-1d72-4f70-96ab-7fb8ca7a8a25",
      "userId": 15,
      "title": "Appointment Completed",
      "message": "Your appointment is completed. Share your feedback and review your doctor.",
      "type": "ReviewRequested",
      "isRead": false,
      "readAt": null,
      "createdAt": "2026-04-21T12:10:00Z",
      "relatedEntityType": "Appointment",
      "relatedEntityId": null
    }
  ],
  "totalCount": 1,
  "unreadCount": 1,
  "page": 1,
  "pageSize": 20,
  "hasNextPage": false
}
```

Important:

- `relatedEntityId` may be null even when push payload contains more routing data
- Flutter must not assume all deep-link identifiers exist in this response

### 5.4 Get unread count

Endpoint:

`GET /api/notifications/unread-count`

Response:

```json
{
  "count": 5
}
```

### 5.5 Mark single notification as read

Endpoint:

`POST /api/notifications/{notificationId}/mark-as-read`

### 5.6 Mark all notifications as read

Endpoint:

`POST /api/notifications/mark-all-as-read`

### 5.7 Complete appointment

Endpoint:

`PATCH /api/appointments/{appointmentId}/complete`

Authorization:

- Approved doctor only

Effect:

- Completes the appointment
- Triggers `ReviewRequested` notification for the patient

### 5.8 Submit review

Endpoint:

`POST /api/reviews`

Authorization:

- Patient only

Request body:

```json
{
  "doctorId": 42,
  "rating": 5,
  "comment": "Excellent consultation and clear explanation."
}
```

Success behavior:

- Review is stored
- Doctor receives `ReviewCreated` notification

### 5.9 Update review

Endpoint:

`PATCH /api/reviews/{reviewId}`

Request body:

```json
{
  "rating": 4,
  "comment": "Updated feedback after follow-up."
}
```

### 5.10 Delete review

Endpoint:

`DELETE /api/reviews/{reviewId}`

## 6. FCM Payload Contract for Flutter

Flutter should support notification routing using the `data` payload.

### 6.1 Review request payload

Notification type:

- `ReviewRequested`

Expected data keys:

```json
{
  "type": "ReviewRequested",
  "relatedEntityType": "Appointment",
  "appointmentId": "GUID_VALUE",
  "doctorId": "42"
}
```

Recommended app action:

- Open appointment details or review screen
- Pre-fill the target doctor with `doctorId`

### 6.2 Review created payload for doctor

Notification type:

- `ReviewCreated`

Expected data keys:

```json
{
  "type": "ReviewCreated",
  "relatedEntityType": "Review",
  "relatedEntityId": "123",
  "reviewId": "123",
  "doctorId": "42",
  "patientId": "15"
}
```

Recommended app action:

- Open doctor review list or review details screen

### 6.3 Appointment booked payload

Expected keys:

```json
{
  "type": "AppointmentBooked",
  "relatedEntityType": "Appointment",
  "appointmentId": "GUID_VALUE"
}
```

### 6.4 Appointment cancelled payload

Expected keys:

```json
{
  "type": "AppointmentCancelledByPatient",
  "relatedEntityType": "Appointment",
  "appointmentId": "GUID_VALUE",
  "cancelledBy": "patient"
}
```

Or:

```json
{
  "type": "AppointmentCancelledByDoctor",
  "relatedEntityType": "Appointment",
  "appointmentId": "GUID_VALUE",
  "cancelledBy": "doctor"
}
```

### 6.5 Payment payloads

Possible keys:

```json
{
  "type": "PaymentSucceeded",
  "relatedEntityType": "Payment",
  "paymentId": "GUID_VALUE"
}
```

```json
{
  "type": "PaymentFailed",
  "relatedEntityType": "Payment",
  "paymentId": "GUID_VALUE",
  "reason": "Payment declined by gateway"
}
```

### 6.6 Prescription payloads

Possible keys:

```json
{
  "type": "PrescriptionCreated",
  "relatedEntityType": "Prescription",
  "prescriptionId": "GUID_VALUE"
}
```

## 7. Flutter Integration Rules

### Rule 1: Register FCM token after authentication

After user login succeeds:

- Get current FCM token
- Call `POST /api/auth/register-device`
- Repeat registration whenever token refresh happens

### Rule 2: Keep push routing independent from notification center history

Use:

- FCM payload for immediate navigation
- `GET /api/notifications` for UI history and unread badge support

Do not assume:

- `GET /api/notifications` contains all deep-link routing fields

### Rule 3: Always support safe fallback navigation

If payload is missing some expected key:

- Open notifications screen
- Or open a safe detail page
- Do not crash

### Rule 4: De-duplicate by notification type and entity where needed

Foreground push and manual refresh may produce repeated UI updates.

Recommended strategy:

- Store last opened notification id or message id locally
- Avoid opening the same route twice automatically

### Rule 5: Handle app states separately

Flutter should handle:

- Foreground notifications
- Background notifications
- Terminated app launch from notification tap

## 8. Recommended Flutter Routing Map

Suggested mapping:

- `ReviewRequested`
  - Route to review creation screen
  - Read `doctorId`
  - Optionally read `appointmentId`

- `ReviewCreated`
  - Route doctor to reviews screen

- `AppointmentBooked`
  - Route to appointment details

- `AppointmentCancelledByPatient`
  - Route to appointment details or history

- `AppointmentCancelledByDoctor`
  - Route to appointment details or history

- `PaymentSucceeded`
  - Route to payment summary or appointment details

- `PaymentFailed`
  - Route to payment retry or payment details

- `PrescriptionCreated`
  - Route to prescriptions screen

- `PrescriptionUpdated`
  - Route to prescription details

- `TicketResponse`
  - Route to support ticket chat

- `TicketClosed`
  - Route to support ticket details

## 9. Recommended Implementation Sequence for Flutter Team

1. Integrate Firebase Messaging and local notification display
2. Register device token after login
3. Build notification center using `GET /api/notifications`
4. Add unread badge using `GET /api/notifications/unread-count`
5. Add read actions using mark-as-read endpoints
6. Implement push routing by `type`
7. Implement review-request flow using `doctorId`
8. Test doctor-side review-created notification using `doctorId`, `patientId`, and `reviewId`

## 10. End-to-End Test Scenarios

### Scenario A: Review request after appointment completion

1. Patient books appointment
2. Doctor completes appointment using:
   - `PATCH /api/appointments/{appointmentId}/complete`
3. Patient should receive:
   - In-app notification with type `ReviewRequested`
   - Push payload containing `doctorId` and `appointmentId`
4. Flutter should open or prepare review screen correctly

### Scenario B: Doctor notified after patient submits review

1. Patient submits:
   - `POST /api/reviews`
2. Doctor should receive:
   - In-app notification with type `ReviewCreated`
   - Push payload containing `doctorId`, `patientId`, and `reviewId`

### Scenario C: Notification center synchronization

1. Receive push while app is closed
2. Open app
3. Call `GET /api/notifications`
4. Ensure notification center shows matching item
5. Mark item as read

## 11. Known Implementation Note

At the time of writing:

- Routing metadata is sent through FCM payload
- Stored notification list does not yet persist the extra custom payload dictionary

This is not a blocker for Flutter integration if the app uses push payload for navigation and notifications endpoint for inbox history.

## 12. Backend Files Updated for This Integration

Main backend files touched in this notification work include:

- `WelloraHealthCareManagment.Domain/Enums/NotificationType.cs`
- `WelloraHealthCareManagment.Application/Interfaces/Services/INotificationService.cs`
- `WelloraHealthCareManagment.Application/DTOs/Admin/NotificationDto.cs`
- `WelloraHealthCareManagment.Infrastructure/Services/Admin/NotificationService.cs`
- `WelloraHealthCareManagment.Infrastructure/Services/AuthCoreService.cs`
- `WelloraHealthCareManagment.Infrastructure/Services/DoctorProfileService.cs`
- `WelloraHealthCareManagment.Infrastructure/Services/AppointmentService.cs`
- `WelloraHealthCareManagment.Infrastructure/Services/PaymentService.cs`
- `WelloraHealthCareManagment.Infrastructure/Services/PrescriptionService.cs`
- `WelloraHealthCareManagment.Infrastructure/Services/ReviewService.cs`
- `WelloraHealthCareManagment.Infrastructure/Services/Admin/TicketService.cs`
- `WelloraHealthCareManagment.Infrastructure/Services/Admin/UserManagementService.cs`
- `WelloraHealthCareManagment.API/Controller/Admin/NotificationController.cs`
- `WelloraHealthCareManagment.API/Controller/Authintecation/AuthController.cs`
- `WelloraHealthCareManagment.API/Controller/AppointmentsController.cs`
- `WelloraHealthCareManagment.API/Controller/ReviewsController.cs`

## 13. Final Handover Notes

If the Flutter team follows this document, they can integrate:

- FCM registration
- notification center
- unread counters
- deep linking from push payload
- review request after completed appointment
- doctor review alerts

with minimal ambiguity and without routing conflicts.

Prepared and signed by:

Ahmed Al-Desouki
