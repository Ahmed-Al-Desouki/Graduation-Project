-- SQL Script to Test Doctor Verification Status Change Scenario
-- Run this script to verify the current behavior in your database

-- Step 1: Find doctors with rejected verification documents
SELECT 
    d.DoctorId,
    u.FullName,
    u.Email,
    COUNT(*) as TotalDocuments,
    SUM(CASE WHEN dv.Status = 'Rejected' THEN 1 ELSE 0 END) as RejectedCount,
    SUM(CASE WHEN dv.Status = 'Pending' THEN 1 ELSE 0 END) as PendingCount,
    SUM(CASE WHEN dv.Status = 'Approved' THEN 1 ELSE 0 END) as ApprovedCount
FROM Doctors d
JOIN Users u ON d.UserId = u.UserId
JOIN DoctorVerifications dv ON d.DoctorId = dv.DoctorId
WHERE EXISTS (
    SELECT 1 FROM DoctorVerifications dv2 
    WHERE dv2.DoctorId = d.DoctorId AND dv2.Status = 'Rejected'
)
GROUP BY d.DoctorId, u.FullName, u.Email
ORDER BY d.DoctorId;

-- Step 2: Show detailed verification status for a specific rejected doctor
-- Replace {DoctorId} with an actual doctor ID from the query above
SELECT 
    dv.VerificationId,
    dv.DocumentType,
    dv.Status,
    dv.SubmittedAt,
    dv.ReviewedAt,
    dv.AdminNotes,
    dv.RejectionReason,
    dv.UpdatedAt
FROM DoctorVerifications dv
WHERE dv.DoctorId = {DoctorId}
ORDER BY dv.VerificationId;

-- Step 3: Simulate what happens when a doctor replaces a rejected document
-- This shows the SQL that would be executed by ReplaceVerificationDocumentAsync
UPDATE DoctorVerifications
SET 
    Status = 'Pending',
    ReviewedAt = NULL,
    AdminNotes = NULL,
    RejectionReason = NULL,
    UpdatedAt = GETUTCDATE()
WHERE DoctorId = {DoctorId} 
    AND VerificationId = {VerificationId}; -- Replace with actual verification ID

-- Step 4: Check the status after the update
-- Run this after executing the UPDATE above to verify the change
SELECT 
    dv.VerificationId,
    dv.DocumentType,
    dv.Status,
    dv.SubmittedAt,
    dv.ReviewedAt,
    dv.AdminNotes,
    dv.RejectionReason,
    dv.UpdatedAt
FROM DoctorVerifications dv
WHERE dv.DoctorId = {DoctorId}
ORDER BY dv.VerificationId;

-- Step 5: Verify the overall doctor request status logic
-- This simulates what DoctorVerificationPolicy.DetermineRequestStatus() does
WITH DoctorStatus AS (
    SELECT 
        d.DoctorId,
        u.FullName,
        -- Count required documents by status
        SUM(CASE WHEN dv.DocumentType IN ('License', 'GraduationCertificate', 'NationalId') AND dv.Status = 'Rejected' THEN 1 ELSE 0 END) as RejectedRequired,
        SUM(CASE WHEN dv.DocumentType IN ('License', 'GraduationCertificate', 'NationalId') AND dv.Status = 'Pending' THEN 1 ELSE 0 END) as PendingRequired,
        SUM(CASE WHEN dv.DocumentType IN ('License', 'GraduationCertificate', 'NationalId') AND dv.Status = 'Approved' THEN 1 ELSE 0 END) as ApprovedRequired,
        -- Check if all required documents are submitted
        COUNT(DISTINCT CASE WHEN dv.DocumentType IN ('License', 'GraduationCertificate', 'NationalId') THEN dv.DocumentType END) as SubmittedRequiredCount
    FROM Doctors d
    JOIN Users u ON d.UserId = u.UserId
    JOIN DoctorVerifications dv ON d.DoctorId = dv.DoctorId
    WHERE d.DoctorId = {DoctorId}
    GROUP BY d.DoctorId, u.FullName
)
SELECT 
    DoctorId,
    FullName,
    SubmittedRequiredCount,
    RejectedRequired,
    PendingRequired,
    ApprovedRequired,
    CASE 
        WHEN SubmittedRequiredCount < 3 THEN 'Incomplete'
        WHEN RejectedRequired > 0 THEN 'Rejected'
        WHEN PendingRequired > 0 THEN 'Pending'
        WHEN ApprovedRequired = 3 THEN 'Approved'
        ELSE 'Incomplete'
    END as CalculatedStatus
FROM DoctorStatus;
