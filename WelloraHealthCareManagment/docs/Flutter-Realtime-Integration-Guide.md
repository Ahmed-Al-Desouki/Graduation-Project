# Flutter Realtime Integration Guide

## Purpose

This document is the handoff for the Flutter team after the backend support-system refactor and the full-system realtime upgrade.

It explains:

- what changed in the backend
- which REST endpoints to keep using
- which SignalR events to subscribe to
- how support messages were unified
- what the Flutter app must do
- what the Flutter app must avoid

## Big Picture

The backend now follows this model:

- REST APIs remain the source for initial load, paging, filters, and user actions
- SignalR is now the source for live updates after the first load
- no business logic lives in the hub
- events are emitted only after successful persistence

Primary SignalR hub:

- `/hubs/app`

Compatibility alias still available:

- `/hubs/support`

## What Changed

### 1. Support System

Implemented:

- paged ticket message history
- unified ticket status update through `PATCH /api/tickets/{ticketId}`
- realtime support events through SignalR

Important schema update:

Support message payloads are now unified across:

- `GET /api/tickets/{ticketId}/messages`
- `POST /api/tickets/{ticketId}/messages`
- `POST /api/admin/tickets/respond`
- SignalR event `ReceiveMessage`

Unified message shape:

```json
{
  "id": "guid",
  "ticketId": "guid",
  "senderId": 123,
  "senderName": "Ahmed Ali",
  "content": "Message body",
  "isFromAdmin": true,
  "createdAt": "2026-04-23T15:30:00Z"
}
```

Notes:

- `content` is the unified field name for the message body
- `createdAt` is the unified timestamp field
- `senderName` and `isFromAdmin` are included in history and realtime
- you can now use **one Flutter model** for support messages

### 2. Realtime Across the System

Realtime broadcasting was added for these areas:

- appointments
- booking lifecycle
- time slots
- slot configuration / doctor schedule exceptions
- payments
- notifications
- support tickets and chat
- doctor verification
- prescriptions
- medical records
- medical access changes

## SignalR Connection Rules

### Connect

Use SignalR client against:

- `/hubs/app`

Pass the JWT as `access_token` in the query string if your client package uses that pattern.

### Auto Groups

On connect, the backend automatically adds the connection to:

- `UserGroup(userId)` internally
- `AdminGroup` internally if role is Admin

### Manual Groups

Call these hub methods when opening detail screens:

- `JoinTicket(ticketId)`
- `LeaveTicket(ticketId)`
- `JoinEntityGroup(entityType, entityId)`
- `LeaveEntityGroup(entityType, entityId)`

Use `JoinEntityGroup` for screens like:

- appointment details
- payment details
- prescription details
- medical record details
- ticket details

Suggested entity names:

- `ticket`
- `appointment`
- `booking`
- `timeslot`
- `payment`
- `schedule`
- `prescription`
- `medicalrecord`
- `doctorverification`

## Realtime Events

Current backend events:

- `ReceiveMessage`
- `TicketCreated`
- `TicketUpdated`
- `NotificationReceived`
- `AppointmentCreated`
- `AppointmentUpdated`
- `AppointmentCancelled`
- `BookingCreated`
- `BookingUpdated`
- `SlotUpdated`
- `PaymentUpdated`
- `ScheduleUpdated`
- `MedicalAccessUpdated`
- `DoctorVerificationUpdated`
- `PrescriptionCreated`
- `PrescriptionUpdated`
- `MedicalRecordCreated`
- `MedicalRecordUpdated`

Important:

- some screens should listen to more than one event
- for example booking UI may care about `AppointmentCreated`, `BookingCreated`, and `SlotUpdated`

## REST Endpoints To Use

## Support

### User Ticket APIs

- `POST /api/tickets`
- `POST /api/tickets/messages`
- `POST /api/tickets/{ticketId}/messages`
- `GET /api/tickets/my-tickets`
- `GET /api/tickets/{ticketId}`
- `GET /api/tickets/{ticketId}/messages?page=1&pageSize=20&sort=asc`
- `PATCH /api/tickets/{ticketId}`

### Admin Ticket APIs

- `GET /api/admin/tickets`
- `POST /api/admin/tickets/respond`
- `PUT /api/admin/tickets/priority`
- `GET /api/admin/tickets/statistics`

### Support Flow Recommendation

1. load ticket details with `GET /api/tickets/{ticketId}`
2. load paged history with `GET /api/tickets/{ticketId}/messages`
3. join `JoinTicket(ticketId)`
4. append `ReceiveMessage` directly to the local list
5. update ticket badge/status on `TicketUpdated`

## Appointments

Base route:

- `/api/appointments`

Main endpoints:

- `POST /api/appointments/book-with-payment`
- `GET /api/appointments/{appointmentId}`
- `GET /api/appointments/my-appointments`
- `GET /api/appointments/doctor-appointments`
- `POST /api/appointments/{originalAppointmentId}/follow-up/existing`
- `POST /api/appointments/{originalAppointmentId}/follow-up/new`
- `POST /api/appointments/{appointmentId}/cancel-patient`
- `POST /api/appointments/{appointmentId}/doctor-cancel-block`
- `POST /api/appointments/{appointmentId}/grant-medical-access`

Also existing confirm/start/complete appointment endpoints remain in the same controller and should continue to be used from REST, while live state updates now arrive through SignalR.

## Time Slots

Base route:

- `/api/doctors/{doctorId}/time-slots`

Main endpoints:

- `GET /api/doctors/{doctorId}/time-slots/available`
- `GET /api/doctors/{doctorId}/time-slots/range`
- `POST /api/doctors/{doctorId}/time-slots/manual`
- `PATCH /api/doctors/{doctorId}/time-slots/{slotId}/block`
- `DELETE /api/doctors/{doctorId}/time-slots/{slotId}`

## Slot Configuration / Schedule

Base route:

- `/api/doctors/{doctorId}/slot-config`

Main endpoints:

- `GET /api/doctors/{doctorId}/slot-config`
- `PUT /api/doctors/{doctorId}/slot-config/days/{day}`
- `DELETE /api/doctors/{doctorId}/slot-config/days/{day}`
- `POST /api/doctors/{doctorId}/slot-config/generate`
- `POST /api/doctors/{doctorId}/slot-config/exceptions/day-off`
- `POST /api/doctors/{doctorId}/slot-config/exceptions/custom-hours`
- `DELETE /api/doctors/{doctorId}/slot-config/exceptions/{date}`

## Payments

Base route:

- `/api/Payment`

Main endpoints:

- `POST /api/Payment/create`
- `POST /api/Payment/refund`
- `POST /api/Payment/paymob-callback`
- `GET /api/Payment/payment-result`
- `GET /api/Payment/appointment/{appointmentId}`
- `GET /api/Payment/patient/{patientId}/history`

## Notifications

Base route:

- `/api/notifications`

Main endpoints:

- `GET /api/notifications`
- `GET /api/notifications/unread-count`
- `POST /api/notifications/{notificationId}/mark-as-read`
- `POST /api/notifications/mark-all-as-read`

## Doctor Verification

Base route:

- `/api/admin/doctor-verifications`

Use the existing list/details/approve/reject endpoints in that controller. Realtime updates now arrive through `DoctorVerificationUpdated`.

## Prescriptions

Base route:

- `/api/prescriptions`

Use the existing create/get/update item/add items endpoints. Realtime updates now arrive through:

- `PrescriptionCreated`
- `PrescriptionUpdated`

## Medical Records

Base route:

- `/api/appointments/{appointmentId}/medical-record`

Main endpoints:

- `POST /api/appointments/{appointmentId}/medical-record`
- `PUT /api/appointments/{appointmentId}/medical-record`
- `GET /api/appointments/{appointmentId}/medical-record`

## Payload Notes For Flutter

## Support Message Model

Use one model for:

- support message history
- send-message response
- admin-respond response
- `ReceiveMessage` realtime event

Suggested Dart model:

```dart
class SupportMessage {
  final String id;
  final String ticketId;
  final int senderId;
  final String senderName;
  final String content;
  final bool isFromAdmin;
  final DateTime createdAt;

  SupportMessage({
    required this.id,
    required this.ticketId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.isFromAdmin,
    required this.createdAt,
  });

  factory SupportMessage.fromJson(Map<String, dynamic> json) {
    return SupportMessage(
      id: json['id'] as String,
      ticketId: json['ticketId'] as String,
      senderId: json['senderId'] as int,
      senderName: json['senderName'] as String,
      content: json['content'] as String,
      isFromAdmin: json['isFromAdmin'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
```

## Ticket History Response

```json
{
  "ticketId": "guid",
  "messages": [SupportMessage],
  "totalCount": 50,
  "page": 1,
  "pageSize": 20,
  "sortDirection": "asc",
  "hasNextPage": true
}
```

## Recommended Client Strategy

### General Rule

For every realtime-enabled screen:

1. initial load from REST
2. subscribe/join SignalR group
3. merge realtime events into local state
4. only re-fetch from REST when:
   - pagination changes
   - the user manually refreshes
   - a reconnect happened and local state may be stale

### Support Screen

1. fetch ticket
2. fetch messages page 1
3. join ticket group
4. append `ReceiveMessage`
5. deduplicate by `id`

### Slots Screen

1. fetch available/range slots
2. join doctor schedule entity group if needed
3. update slot list on `SlotUpdated` and `ScheduleUpdated`

### Payment Screen

1. create payment with REST
2. if redirect/webview returns before webhook finishes, wait for `PaymentUpdated`
3. when `PaymentUpdated.status == Paid`, update UI immediately

### Notifications Screen

1. fetch notifications and unread count
2. listen to `NotificationReceived`
3. prepend new notification locally
4. increment unread count locally

## Important Things Flutter Must Do

- stop polling for support chat
- stop polling for notification refresh
- stop polling for payment confirmation where SignalR is available
- use realtime events to update in-memory state immediately
- deduplicate events by entity id
- handle reconnects
- rejoin ticket/entity groups after reconnect
- keep REST for pagination and first load
- use UTC-safe parsing for all timestamps

## What Flutter Should Avoid

- do not keep old support message models with `message` and `timestamp`
- do not assume ticket messages only need role text like `User` or `Admin`
- do not append realtime payloads without deduplication
- do not rebuild screens by full refetch after every event
- do not continue background polling for the same feature after connecting to SignalR
- do not assume event order is perfect across reconnects; always be able to reconcile

## Important Notes

- `ReceiveMessage` payload already matches the history API message item shape
- ticket history now includes `senderName` and `isFromAdmin`
- `PATCH /api/tickets/{ticketId}` is the correct status update endpoint
- `POST /api/admin/tickets/close` is no longer the model to build around
- hub methods are transport helpers only; all domain actions still happen through REST APIs

## Recommended Testing Checklist For Flutter

1. open same ticket on two devices
2. send message from one side
3. verify other side receives `ReceiveMessage` instantly
4. change ticket status from admin
5. verify user screen updates without refresh
6. open slot screen on two clients
7. book or block a slot
8. verify `SlotUpdated` updates the second client immediately
9. complete payment and verify `PaymentUpdated`
10. create notification-triggering action and verify `NotificationReceived`

## Final Recommendation

The correct frontend architecture now is:

- REST for commands and initial queries
- SignalR for live synchronization
- one unified support message model
- no polling for features already covered by events

