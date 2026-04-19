/*
Reminder System Diagnostics
Run these queries after create/update/cancel/job scenarios.
Replace placeholder ids before execution where needed.
*/

/* 1. Duplicate cache rows */
SELECT
    ReminderId,
    PatientId,
    DoctorId,
    DueDateTimeUtc,
    COUNT(*) AS DuplicateCount
FROM ReminderOccurrencesCache
GROUP BY ReminderId, PatientId, DoctorId, DueDateTimeUtc
HAVING COUNT(*) > 1
ORDER BY DuplicateCount DESC, ReminderId;

/* 2. Duplicate occurrence logs */
SELECT
    ReminderId,
    PatientId,
    DueDateTimeUtc,
    COUNT(*) AS DuplicateCount
FROM ReminderOccurrenceLogs
GROUP BY ReminderId, PatientId, DueDateTimeUtc
HAVING COUNT(*) > 1
ORDER BY DuplicateCount DESC, ReminderId;

/* 3. Active reminders without future cache */
SELECT
    r.Id AS ReminderId,
    r.PatientId,
    r.DoctorId,
    r.Type,
    r.Title,
    r.PrescriptionItemId,
    r.AppointmentId,
    r.StartDateUtc,
    r.EndDateUtc
FROM ReminderV2s r
WHERE r.IsActive = 1
  AND NOT EXISTS
  (
      SELECT 1
      FROM ReminderOccurrencesCache c
      WHERE c.ReminderId = r.Id
        AND c.DueDateTimeUtc >= GETUTCDATE()
  )
ORDER BY r.Id;

/* 4. Orphan cache rows */
SELECT
    c.Id,
    c.ReminderId,
    c.PatientId,
    c.DoctorId,
    c.DueDateTimeUtc
FROM ReminderOccurrencesCache c
LEFT JOIN ReminderV2s r ON r.Id = c.ReminderId
WHERE r.Id IS NULL
ORDER BY c.Id DESC;

/* 5. Appointments without reminders */
SELECT
    a.Id AS AppointmentId,
    a.PatientId,
    a.DoctorId,
    a.Status,
    a.TimeSlotId,
    COUNT(r.Id) AS ReminderCount
FROM Appointments a
LEFT JOIN ReminderV2s r ON r.AppointmentId = a.Id AND r.IsActive = 1
WHERE a.Status NOT IN (2, 3)
GROUP BY a.Id, a.PatientId, a.DoctorId, a.Status, a.TimeSlotId
HAVING COUNT(r.Id) = 0
ORDER BY a.Id DESC;

/* 6. Prescription reminders with missing cache */
SELECT
    r.Id AS ReminderId,
    r.PatientId,
    r.PrescriptionId,
    r.PrescriptionItemId,
    r.Title,
    r.IsActive
FROM ReminderV2s r
WHERE r.PrescriptionItemId IS NOT NULL
  AND r.IsActive = 1
  AND NOT EXISTS
  (
      SELECT 1
      FROM ReminderOccurrencesCache c
      WHERE c.ReminderId = r.Id
        AND c.DueDateTimeUtc >= GETUTCDATE()
  )
ORDER BY r.Id DESC;

/* 7. Inspect appointment reminders */
DECLARE @AppointmentId UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000';

SELECT
    r.Id AS ReminderId,
    r.PatientId,
    r.DoctorId,
    r.Title,
    r.Message,
    r.IsActive,
    r.StartDateUtc,
    r.EndDateUtc,
    r.AppointmentId
FROM ReminderV2s r
WHERE r.AppointmentId = @AppointmentId
ORDER BY r.Id;

SELECT
    c.Id,
    c.ReminderId,
    c.PatientId,
    c.DoctorId,
    c.DueDateTimeUtc,
    c.DueDateTime,
    c.Status
FROM ReminderOccurrencesCache c
WHERE c.ReminderId IN
(
    SELECT r.Id
    FROM ReminderV2s r
    WHERE r.AppointmentId = @AppointmentId
)
ORDER BY c.DueDateTimeUtc;

/* 8. Inspect prescription reminder links */
DECLARE @PrescriptionId UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000';

SELECT
    p.Id AS PrescriptionItemId,
    p.MedicationName,
    p.ReminderFrequencyType,
    p.ReminderStartDate,
    p.ReminderEndDate,
    r.Id AS ReminderId,
    r.IsActive,
    r.Title,
    r.StartDateUtc,
    r.EndDateUtc
FROM PrescriptionItems p
LEFT JOIN ReminderV2s r ON r.PrescriptionItemId = p.Id
WHERE p.PrescriptionId = @PrescriptionId
ORDER BY p.Id;

/* 9. Inspect one reminder by reminder id */
DECLARE @ReminderId INT = 0;

SELECT *
FROM ReminderV2s
WHERE Id = @ReminderId;

SELECT *
FROM ReminderOccurrencesCache
WHERE ReminderId = @ReminderId
ORDER BY DueDateTimeUtc;

SELECT *
FROM ReminderOccurrenceLogs
WHERE ReminderId = @ReminderId
ORDER BY DueDateTimeUtc;

/* 10. Cache volume by reminder type */
SELECT
    c.Type,
    COUNT(*) AS CacheRowCount
FROM ReminderOccurrencesCache c
GROUP BY c.Type
ORDER BY c.Type;

/* 11. Active reminder counts by owner type */
SELECT
    CASE
        WHEN PatientId IS NOT NULL THEN 'Patient'
        WHEN DoctorId IS NOT NULL THEN 'Doctor'
        ELSE 'Unknown'
    END AS OwnerType,
    COUNT(*) AS ReminderCount
FROM ReminderV2s
WHERE IsActive = 1
GROUP BY
    CASE
        WHEN PatientId IS NOT NULL THEN 'Patient'
        WHEN DoctorId IS NOT NULL THEN 'Doctor'
        ELSE 'Unknown'
    END;

/* 12. Near-future cache preview */
SELECT TOP 200
    c.Id,
    c.ReminderId,
    c.PatientId,
    c.DoctorId,
    c.Title,
    c.DueDateTimeUtc,
    c.DueDateTime,
    c.Status
FROM ReminderOccurrencesCache c
WHERE c.DueDateTimeUtc >= GETUTCDATE()
ORDER BY c.DueDateTimeUtc;
