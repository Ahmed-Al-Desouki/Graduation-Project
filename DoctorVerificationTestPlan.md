# Doctor Verification Status Change Test Plan

## Scenario: Rejected Doctor Updates Information

### Expected Behavior
When a doctor with rejected verification documents replaces their documents, the system should:
1. Change the specific document status from `Rejected` to `Pending`
2. Clear rejection reasons and admin notes for that document
3. Update the overall doctor verification request status to `Pending`
4. Make the doctor appear in the pending verification queue for admin review

### Test Steps

#### Step 1: Verify Current System Logic
✅ **VERIFIED**: The code correctly implements the required logic:
- `ReplaceVerificationDocumentAsync()` sets status to `Pending`
- `DoctorVerificationPolicy.DetermineRequestStatus()` returns `Pending` when any required document is pending
- System prevents duplicate uploads and forces replacement

#### Step 2: Manual Test Procedure
1. **Find a rejected doctor** in the admin dashboard
2. **Have the doctor replace a rejected document** via the doctor profile
3. **Verify the status changes**:
   - Document status: `Rejected` → `Pending`
   - Overall request status: `Rejected` → `Pending`
   - Doctor appears in pending queue

#### Step 3: Database Verification
Run the SQL script `VerifyDoctorStatusChange.sql` to:
- Find doctors with rejected documents
- Check individual document statuses
- Verify status calculation logic

#### Step 4: API Endpoint Test
Test the `PUT /api/doctor/profile/verification-documents/{verificationId}` endpoint:
```bash
# Replace a rejected document
curl -X PUT "http://localhost:5000/api/doctor/profile/verification-documents/{rejectedVerificationId}" \
  -H "Authorization: Bearer {doctorToken}" \
  -F "newFile=@new-document.pdf"
```

### Potential Issues & Solutions

#### Issue 1: Frontend Not Reflecting Status Change
**Symptoms**: Backend status changes but admin dashboard shows old status
**Solution**: Check real-time updates and cache invalidation

#### Issue 2: Cache Issues
**Symptoms**: Status changes but cached data persists
**Solution**: Clear cache or implement proper cache invalidation

#### Issue 3: Timing Issues
**Symptoms**: Status changes but admin notification delayed
**Solution**: Verify notification service and real-time broadcasting

### Debugging Checklist

1. **Check Document Status**
   ```sql
   SELECT Status, DocumentType FROM DoctorVerifications WHERE DoctorId = {id}
   ```

2. **Check Overall Status Calculation**
   ```sql
   -- Use the status calculation query from VerifyDoctorStatusChange.sql
   ```

3. **Check Admin Dashboard Query**
   - Verify `GetPendingDoctorsWithVerificationsAsync()` includes the updated doctor
   - Check filtering logic in the repository

4. **Check Real-time Updates**
   - Verify `BroadcastVerificationUpdatedAsync()` is called
   - Check SignalR/real-time connection

### Expected Results

After a rejected doctor replaces a document:
- ✅ Individual document status: `Pending`
- ✅ Overall request status: `Pending`  
- ✅ Doctor appears in admin pending queue
- ✅ Doctor receives notification about re-submission
- ✅ Admin receives notification about new pending document

### If Issue Persists

1. **Check the exact endpoint used**: Was `ReplaceVerificationDocumentAsync` called or `AddVerificationDocumentAsync`?
2. **Verify document replacement**: Check if the rejected document was actually replaced or if a new document was added
3. **Check database directly**: Verify the actual status values in the database
4. **Review logs**: Check for any errors during the replacement process

### System Confirmation

The code analysis confirms the system is **correctly designed** to handle this scenario. The `DoctorVerificationPolicy.DetermineRequestStatus()` method will return `Pending` as soon as any required document has `Pending` status, which is exactly what happens when `ReplaceVerificationDocumentAsync` sets the status to `Pending`.
