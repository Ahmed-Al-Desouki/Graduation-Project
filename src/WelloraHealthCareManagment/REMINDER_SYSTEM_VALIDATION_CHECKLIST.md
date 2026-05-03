# Reminder System Validation Checklist

This checklist is the operational verification plan for the reminder system after the recent stabilization work.

## Goal

Verify that reminders work correctly for:
- patients
- doctors
- appointments
- prescriptions
- cache rebuilds
- background jobs
- occurrence actions

Use this together with [REMINDER_SYSTEM_DIAGNOSTICS.sql](/C:/Users/pc/Desktop/Graduation%20Project/Onion%20Architecture/WelloraHealthCareManagment/REMINDER_SYSTEM_DIAGNOSTICS.sql).

## Before Testing

1. Apply the latest database migration.
2. Confirm the API starts successfully.
3. Confirm Hangfire dashboard opens.
4. Clear failed Hangfire jobs if they belong to old broken builds only.
5. Choose one patient test account and one doctor test account.

## Core Rules During Testing

1. After every scenario, run the matching SQL diagnostics.
2. Write down:
   - appointment id
   - reminder ids
   - prescription id
   - prescription item id
   - patient id
   - doctor id
3. Validate both:
   - database state
   - API/UI behavior

## Scenario 1: Manual Reminder Create

Steps:
1. Create a one-time custom reminder for a patient.
2. Create a daily reminder with RRULE.
3. Create an every-X-hours reminder.

Expected:
1. A row exists in `ReminderV2s`.
2. Future rows exist in `ReminderOccurrencesCache`.
3. No duplicate cache rows exist for the created reminder.
4. Reminder appears in upcoming reminders endpoint.

Run diagnostics:
- `Duplicate cache rows`
- `Active reminders without future cache`
- `Inspect one reminder by reminder id`

## Scenario 2: Manual Reminder Update

Steps:
1. Update title only.
2. Update time only.
3. Update RRULE.
4. Disable the reminder.

Expected:
1. Title-only change does not create duplicates.
2. Time change removes old cache for that reminder and creates new cache.
3. RRULE change rebuilds future cache.
4. Disabling clears future cache.

Run diagnostics:
- `Inspect one reminder by reminder id`
- `Duplicate cache rows`

## Scenario 3: Prescription Create

Steps:
1. Doctor creates a prescription with one medication and daily schedule.
2. Doctor creates a prescription with multiple dose times.
3. Doctor creates a prescription with `EveryXHours`.

Expected:
1. One `ReminderV2` row exists per prescription item that has reminder settings.
2. `PrescriptionItemId` is linked correctly on the reminder.
3. Cache is created for each active medication reminder.
4. No duplicates exist in cache.

Run diagnostics:
- `Prescription reminders with missing cache`
- `Inspect prescription reminder links`
- `Duplicate cache rows`

## Scenario 4: Add Item To Existing Prescription

Steps:
1. Add a new prescription item using the bulk add endpoint.
2. Record the new `PrescriptionItemId`.

Expected:
1. A reminder is created for the new item if reminder settings exist.
2. Cache is generated for that reminder.
3. Existing prescription items are not duplicated.

Run diagnostics:
- `Inspect prescription reminder links`
- `Inspect one reminder by reminder id`

## Scenario 5: Update Existing Prescription Item

Steps:
1. Update medication name only.
2. Update reminder time only.
3. Update frequency type.
4. Remove reminder settings completely.

Expected:
1. The same linked reminder is updated when it already exists.
2. Old cache is removed and new cache is rebuilt.
3. Removing reminder settings deactivates the reminder and clears cache.
4. No stale occurrences remain from the old schedule.

Run diagnostics:
- `Prescription reminders with missing cache`
- `Inspect one reminder by reminder id`
- `Duplicate cache rows`

## Scenario 6: Appointment Booking Without Payment

Steps:
1. Book an appointment in the future using the free flow.

Expected:
1. Patient reminders are created.
2. Doctor reminders are created.
3. Cache rows exist for both patient and doctor reminders.
4. Reminder times match the expected appointment offsets.

Run diagnostics:
- `Appointments without reminders`
- `Inspect appointment reminders`
- `Duplicate cache rows`

## Scenario 7: Appointment Booking With Payment

Steps:
1. Start booking with payment.
2. Complete Paymob payment successfully.
3. Wait until callback processing completes.

Expected:
1. Payment becomes paid.
2. Appointment is created.
3. Appointment reminders are created after callback.
4. Cache exists for patient and doctor reminders.

Run diagnostics:
- `Appointments without reminders`
- `Inspect appointment reminders`
- `Duplicate cache rows`

## Scenario 8: Appointment Cancellation By Patient

Steps:
1. Cancel a future appointment as patient.

Expected:
1. Appointment status becomes cancelled.
2. Related appointment reminders are deleted.
3. Their cache rows are deleted.
4. No orphan appointment reminder cache remains.

Run diagnostics:
- `Orphan cache rows`
- `Inspect appointment reminders`

## Scenario 9: Appointment Cancellation By Doctor

Steps:
1. Cancel a future appointment as doctor.

Expected:
1. Same as patient cancellation.
2. Refund flow does not leave reminder rows behind.

Run diagnostics:
- `Orphan cache rows`
- `Inspect appointment reminders`

## Scenario 10: Confirm / Skip / Snooze

Steps:
1. Confirm one occurrence.
2. Skip one occurrence.
3. Snooze one occurrence.
4. Repeat snooze request once more on purpose.

Expected:
1. `ReminderOccurrenceLogs` is updated without duplicate logical rows.
2. Cache status changes correctly.
3. Snoozed occurrence creates or reuses the correct future log entry.
4. No unique constraint conflict occurs after repeated snooze.

Run diagnostics:
- `Duplicate occurrence logs`
- `Inspect logs for one reminder`

## Scenario 11: Background Job Validation

Steps:
1. Open Hangfire dashboard.
2. Verify scheduled jobs exist.
3. Manually trigger:
   - patient cache generation
   - doctor cache generation
   - cleanup
   - cache health check

Expected:
1. Jobs complete successfully.
2. No repeated retries.
3. No explosion in inserted cache rows.
4. Cache health check only repairs missing data.

Run diagnostics:
- `Active reminders without future cache`
- `Duplicate cache rows`
- `Prescription reminders with missing cache`

## Scenario 12: Cleanup Validation

Steps:
1. Create a one-time reminder due in the near past or wait for an expired reminder.
2. Trigger cleanup job.

Expected:
1. Expired reminders are deleted or dismissed according to current design.
2. Cache rows for expired reminders are removed.
3. Active future reminders remain untouched.

Run diagnostics:
- `Orphan cache rows`
- `Active reminders without future cache`

## Pass Criteria

The reminder system is considered healthy if:

1. No duplicate rows are returned by the duplicate diagnostics.
2. No active reminder exists without future cache unless intentionally ended.
3. No appointment with active status is missing reminders after booking.
4. No prescription item with reminder settings is missing a linked reminder/cache.
5. Hangfire jobs complete without repeated failures.

## Daily Smoke Test

Run these every deployment:

1. Create one manual reminder.
2. Book one appointment.
3. Create one prescription item with reminder.
4. Cancel one appointment.
5. Run:
   - `Duplicate cache rows`
   - `Active reminders without future cache`
   - `Appointments without reminders`
   - `Prescription reminders with missing cache`

If all are clean, the system is in a good operational state.
