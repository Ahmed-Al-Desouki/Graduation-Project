using System.Globalization;
using System.Text.RegularExpressions;
using WelloraHealthCareManagment.Application.Common.Localization;
using WelloraHealthCareManagment.Application.Interfaces.Services;

namespace WelloraHealthCareManagment.Infrastructure.Services
{
    public class AppLocalizationService : IAppLocalizationService
    {
        private static readonly CultureInfo EnglishCulture = CultureInfo.GetCultureInfo("en-US");
        private static readonly CultureInfo ArabicCulture = CultureInfo.GetCultureInfo("ar-EG");

        private static readonly Dictionary<string, string> EnglishTexts = new(StringComparer.OrdinalIgnoreCase)
        {
            ["Common.AnUnexpectedErrorOccurred"] = "An unexpected error occurred. Please try again later.",
            ["Common.AuthenticationRequired"] = "Authentication required.",
            ["Common.ValidationFailed"] = "Validation failed. Please check your input.",
            ["Common.DatabaseError"] = "Database error occurred. Please try again later.",
            ["Common.ExternalServiceFailed"] = "Failed to connect to an external service.",
            ["Common.Timeout"] = "The operation timed out.",
            ["Common.RecordModified"] = "The record was modified by another user. Please refresh and try again.",
            ["Common.ReasonPrefix"] = "Reason: {reason}.",
            ["Common.NoReasonProvided"] = "No reason was provided.",
            ["Common.Unknown"] = "Unknown",
            ["Common.UserNotFound"] = "User not found.",
            ["Common.OperationFailed"] = "The operation could not be completed.",
            ["Common.Forbidden"] = "Forbidden",
            ["Common.Unauthorized"] = "Unauthorized",
            ["Common.FileNotFound"] = "File not found",
            ["Common.FileDeleted"] = "File deleted successfully",
            ["Common.ActionLogged"] = "Action logged successfully",
            ["Common.TargetEntityTargetIdRequired"] = "TargetEntity and TargetId are required",
            ["Common.DeviceRegistered"] = "Device registered successfully",
            ["Common.DeviceRegisterFailed"] = "Failed to register device",
            ["Common.FcmTokenRequired"] = "FCM Token is required",
            ["Common.InvalidToken"] = "Invalid token",
            ["Common.InvalidOrExpiredMfaToken"] = "Invalid or expired MFA token",
            ["Common.OtpSentAgain"] = "OTP sent again",
            ["Common.SearchIndexRebuilt"] = "Search index rebuilt successfully",
            ["Common.CacheRebuilt"] = "All cache rebuilt successfully",
            ["Common.ManualSlotCreated"] = "Manual slot created successfully",
            ["Common.SlotDeleted"] = "Slot deleted successfully",
            ["Common.SlotBlocked"] = "Slot blocked successfully",
            ["Common.DayOffAdded"] = "Day off added successfully",
            ["Common.CustomHoursAdded"] = "Custom hours added successfully",
            ["Common.MedicalRecordUpdated"] = "Medical record updated successfully",
            ["Common.MedicalRecordNotFound"] = "Medical record not found",
            ["Common.MedicalAccessExtended"] = "Medical access expiry extended successfully",
            ["Common.AppointmentConfirmed"] = "Appointment confirmed",
            ["Common.AppointmentStarted"] = "Appointment started",
            ["Common.AppointmentCompleted"] = "Appointment completed",
            ["Common.ShareTokenExpired"] = "Share token has expired.",
            ["Common.InvalidShareToken"] = "Invalid share token.",
            ["Common.ShareTokenPatientMismatch"] = "Share token does not match this patient.",
            ["Common.ShareTokenMedicalHistoryMismatch"] = "Share token does not match this medical history.",
            ["Common.UpdatableFieldRequired"] = "At least one updatable field is required.",
            ["Validation.DeviceIdTooLong"] = "DeviceId too long",
            ["Validation.EmailRequired"] = "Email is required",
            ["Validation.InvalidEmailFormat"] = "Invalid email format",
            ["Validation.EmailTooLong"] = "Email cannot be longer than 100 characters",
            ["Validation.PasswordRequired"] = "Password is required",
            ["Validation.PasswordMinLength"] = "Password must be at least 6 characters",
            ["Validation.NameRequired"] = "Name is required",
            ["Validation.RoleRequired"] = "Role is required",
            ["Validation.RoleInvalid"] = "Role must be either 'Patient' or 'Doctor'",
            ["Validation.RatingRange"] = "Rating must be between 1 and 5",
            ["Validation.DescriptionTooLong"] = "Description cannot exceed 100 characters.",
            ["Validation.FullNameRequired"] = "Full name is required",
            ["Validation.FullNameTooLong"] = "Full name cannot exceed 100 characters",
            ["Language.PreferenceUpdated"] = "Language preference updated successfully.",
            ["Language.SupportedOnly"] = "Supported languages are 'en' and 'ar' only.",
            ["Notification.VerificationApprovedTitle"] = "Verification Approved",
            ["Notification.VerificationRejectedTitle"] = "Verification Rejected",
            ["Notification.AccountBlockedTitle"] = "Account Blocked",
            ["Notification.AccountUnblockedTitle"] = "Account Unblocked",
            ["Notification.AccountSuspendedTitle"] = "Account Suspended",
            ["Notification.AccountUnsuspendedTitle"] = "Account Active Again",
            ["Notification.SupportReplyTitle"] = "Support Reply",
            ["Notification.TicketClosedTitle"] = "Ticket Closed",
            ["Notification.AppointmentBookedTitle"] = "Appointment Booked",
            ["Notification.NewAppointmentTitle"] = "New Appointment",
            ["Notification.AppointmentCancelledTitle"] = "Appointment Cancelled",
            ["Notification.ReviewAddedTitle"] = "Review Added",
            ["Notification.ReviewUpdatedTitle"] = "Review Updated",
            ["Notification.ReviewDeletedTitle"] = "Review Deleted",
            ["Notification.ReminderTitle"] = "Reminder",
            ["Notification.DoctorProfileCompletedTitle"] = "Doctor Profile Completed",
            ["Notification.PatientProfileCompletedTitle"] = "Patient Profile Completed",
            ["Notification.DoctorDocumentsSubmittedTitle"] = "Doctor Verification Submitted",
            ["Notification.DoctorAchievementAddedTitle"] = "Doctor Achievement Added",
            ["Notification.MfaEnabledTitle"] = "Two-Factor Authentication Enabled",
            ["Notification.MfaDisabledTitle"] = "Two-Factor Authentication Disabled",
            ["Notification.PaymentCompletedTitle"] = "Payment Completed",
            ["Notification.WelcomeTitle"] = "Welcome to Wellora",
            ["Notification.NewDoctorRegisteredTitle"] = "New Doctor Registered",
            ["Notification.NewDoctorRegistrationTitle"] = "New Doctor Registration",
            ["Email.Brand"] = "Wellora HealthCare",
            ["Email.Greeting"] = "Hello, {userName}",
            ["Email.OtpSubject"] = "Your OTP Code - Wellora",
            ["Email.OtpHeadline"] = "Your verification code",
            ["Email.OtpBody"] = "Use the following one-time password to verify your identity.",
            ["Email.OtpExpires"] = "This code expires in 15 minutes.",
            ["Email.OtpWarning"] = "Never share this code with anyone.",
            ["Email.ResetSubject"] = "Reset Your Wellora Password",
            ["Email.ResetHeadline"] = "Reset your password",
            ["Email.ResetBody"] = "We received a request to reset your password. Use the button below to continue.",
            ["Email.ResetAction"] = "Reset Password",
            ["Email.WelcomeSubject"] = "Welcome to Wellora",
            ["Email.WelcomeHeadline"] = "Welcome to Wellora",
            ["Email.WelcomeBody"] = "Your account is ready. You can now sign in and continue setting up your healthcare experience.",
            ["Email.VerifySubject"] = "Verify Your Email - Wellora",
            ["Email.VerifyHeadline"] = "Verify your email",
            ["Email.VerifyBody"] = "Complete your email verification using the secure token below.",
            ["Email.DoctorApprovedSubject"] = "Your Doctor Verification Has Been Approved",
            ["Email.DoctorApprovedHeadline"] = "Doctor verification approved",
            ["Email.DoctorApprovedBody"] = "Your doctor account is now approved and you can access doctor features.",
            ["Email.DoctorRejectedSubject"] = "Update About Your Doctor Verification",
            ["Email.DoctorRejectedHeadline"] = "Doctor verification update",
            ["Email.DoctorRejectedBody"] = "Your doctor verification needs updates before it can be approved.",
            ["Email.BlockedSubject"] = "Important Notice About Your Account",
            ["Email.BlockedHeadline"] = "Your account has been blocked",
            ["Email.BlockedBody"] = "Your account has been blocked. Review the details below.",
            ["Email.UnblockedSubject"] = "Your Account Access Has Been Restored",
            ["Email.UnblockedHeadline"] = "Access restored",
            ["Email.UnblockedBody"] = "Your account access has been restored and you can use the platform again.",
            ["Email.SuspendedSubject"] = "Your Account Has Been Temporarily Suspended",
            ["Email.SuspendedHeadline"] = "Account temporarily suspended",
            ["Email.SuspendedBody"] = "Your account has been suspended temporarily.",
            ["Email.UnsuspendedSubject"] = "Your Account Is Active Again",
            ["Email.UnsuspendedHeadline"] = "Account active again",
            ["Email.UnsuspendedBody"] = "Your account is active again and all available features have been restored.",
            ["Email.AdminNotes"] = "Admin notes",
            ["Email.RejectionReason"] = "Rejection reason",
            ["Email.SuspensionUntil"] = "Suspended until",
            ["Email.Footer"] = "This message was sent by Wellora HealthCare.",
        };

        private static readonly Dictionary<string, string> ArabicTexts = new(StringComparer.OrdinalIgnoreCase)
        {
            ["Common.AnUnexpectedErrorOccurred"] = "حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى لاحقاً.",
            ["Common.AuthenticationRequired"] = "يجب تسجيل الدخول أولاً.",
            ["Common.ValidationFailed"] = "فشل التحقق من صحة البيانات. يرجى مراجعة المدخلات.",
            ["Common.DatabaseError"] = "حدث خطأ في قاعدة البيانات. يرجى المحاولة مرة أخرى لاحقاً.",
            ["Common.ExternalServiceFailed"] = "تعذر الاتصال بخدمة خارجية.",
            ["Common.Timeout"] = "انتهت مهلة العملية.",
            ["Common.RecordModified"] = "تم تعديل السجل بواسطة مستخدم آخر. يرجى التحديث والمحاولة مرة أخرى.",
            ["Common.ReasonPrefix"] = "السبب: {reason}.",
            ["Common.NoReasonProvided"] = "لم يتم تقديم سبب.",
            ["Common.Unknown"] = "غير معروف",
            ["Common.UserNotFound"] = "المستخدم غير موجود.",
            ["Common.OperationFailed"] = "تعذر إكمال العملية.",
            ["Common.Forbidden"] = "ممنوع",
            ["Common.Unauthorized"] = "غير مصرح",
            ["Common.FileNotFound"] = "الملف غير موجود",
            ["Common.FileDeleted"] = "تم حذف الملف بنجاح",
            ["Common.ActionLogged"] = "تم تسجيل الإجراء بنجاح",
            ["Common.TargetEntityTargetIdRequired"] = "يجب توفير TargetEntity و TargetId",
            ["Common.DeviceRegistered"] = "تم تسجيل الجهاز بنجاح",
            ["Common.DeviceRegisterFailed"] = "فشل تسجيل الجهاز",
            ["Common.FcmTokenRequired"] = "مطلوب FCM Token",
            ["Common.InvalidToken"] = "الرمز غير صالح",
            ["Common.InvalidOrExpiredMfaToken"] = "رمز التحقق الثنائي غير صالح أو منتهي الصلاحية",
            ["Common.OtpSentAgain"] = "تم إرسال OTP مرة أخرى",
            ["Common.SearchIndexRebuilt"] = "تم إعادة بناء فهرس البحث بنجاح",
            ["Common.CacheRebuilt"] = "تم إعادة بناء الذاكرة المؤقتة بالكامل بنجاح",
            ["Common.ManualSlotCreated"] = "تم إنشاء الموعد اليدوي بنجاح",
            ["Common.SlotDeleted"] = "تم حذف الموعد بنجاح",
            ["Common.SlotBlocked"] = "تم حظر الموعد بنجاح",
            ["Common.DayOffAdded"] = "تم إضافة يوم الإجازة بنجاح",
            ["Common.CustomHoursAdded"] = "تم إضافة الساعات المخصصة بنجاح",
            ["Common.MedicalRecordUpdated"] = "تم تحديث السجل الطبي بنجاح",
            ["Common.MedicalRecordNotFound"] = "السجل الطبي غير موجود",
            ["Common.MedicalAccessExtended"] = "تم تمديد انتهاء صلاحية الوصول الطبي بنجاح",
            ["Common.AppointmentConfirmed"] = "تم تأكيد الموعد",
            ["Common.AppointmentStarted"] = "بدأ الموعد",
            ["Common.AppointmentCompleted"] = "اكتمل الموعد",
            ["Common.ShareTokenExpired"] = "انتهت صلاحية رمز المشاركة.",
            ["Common.InvalidShareToken"] = "رمز المشاركة غير صالح.",
            ["Common.ShareTokenPatientMismatch"] = "رمز المشاركة لا يطابق هذا المريض.",
            ["Common.ShareTokenMedicalHistoryMismatch"] = "رمز المشاركة لا يطابق هذا السجل الطبي.",
            ["Common.UpdatableFieldRequired"] = "يجب توفير حقل واحد قابل للتحديث على الأقل.",
            ["Validation.DeviceIdTooLong"] = "معرف الجهاز طويل جداً",
            ["Validation.EmailRequired"] = "البريد الإلكتروني مطلوب",
            ["Validation.InvalidEmailFormat"] = "تنسيق البريد الإلكتروني غير صحيح",
            ["Validation.EmailTooLong"] = "لا يمكن أن يزيد طول البريد الإلكتروني عن 100 حرف",
            ["Validation.PasswordRequired"] = "كلمة المرور مطلوبة",
            ["Validation.PasswordMinLength"] = "يجب ألا تقل كلمة المرور عن 6 أحرف",
            ["Validation.NameRequired"] = "الاسم مطلوب",
            ["Validation.RoleRequired"] = "الدور مطلوب",
            ["Validation.RoleInvalid"] = "يجب أن يكون الدور 'Patient' أو 'Doctor'",
            ["Validation.RatingRange"] = "يجب أن يكون التقييم بين 1 و 5",
            ["Validation.DescriptionTooLong"] = "لا يمكن أن يتجاوز الوصف 100 حرف.",
            ["Validation.FullNameRequired"] = "الاسم الكامل مطلوب",
            ["Validation.FullNameTooLong"] = "لا يمكن أن يتجاوز الاسم الكامل 100 حرف",
            ["Language.PreferenceUpdated"] = "تم تحديث تفضيل اللغة بنجاح.",
            ["Language.SupportedOnly"] = "اللغات المدعومة فقط هي العربية والإنجليزية.",
            ["Notification.VerificationApprovedTitle"] = "تمت الموافقة على التحقق",
            ["Notification.VerificationRejectedTitle"] = "تم رفض التحقق",
            ["Notification.AccountBlockedTitle"] = "تم حظر الحساب",
            ["Notification.AccountUnblockedTitle"] = "تم إلغاء حظر الحساب",
            ["Notification.AccountSuspendedTitle"] = "تم تعليق الحساب",
            ["Notification.AccountUnsuspendedTitle"] = "تم تفعيل الحساب مجدداً",
            ["Notification.SupportReplyTitle"] = "رد من الدعم",
            ["Notification.TicketClosedTitle"] = "تم إغلاق التذكرة",
            ["Notification.AppointmentBookedTitle"] = "تم حجز الموعد",
            ["Notification.NewAppointmentTitle"] = "موعد جديد",
            ["Notification.AppointmentCancelledTitle"] = "تم إلغاء الموعد",
            ["Notification.ReviewAddedTitle"] = "تمت إضافة مراجعة",
            ["Notification.ReviewUpdatedTitle"] = "تم تحديث المراجعة",
            ["Notification.ReviewDeletedTitle"] = "تم حذف المراجعة",
            ["Notification.ReminderTitle"] = "تذكير",
            ["Notification.DoctorProfileCompletedTitle"] = "تم إكمال ملف الطبيب",
            ["Notification.PatientProfileCompletedTitle"] = "تم إكمال ملف المريض",
            ["Notification.DoctorDocumentsSubmittedTitle"] = "تم إرسال مستندات التحقق",
            ["Notification.DoctorAchievementAddedTitle"] = "تمت إضافة إنجاز للطبيب",
            ["Notification.MfaEnabledTitle"] = "تم تفعيل التحقق الثنائي",
            ["Notification.MfaDisabledTitle"] = "تم إيقاف التحقق الثنائي",
            ["Notification.PaymentCompletedTitle"] = "تم إتمام الدفع",
            ["Notification.WelcomeTitle"] = "مرحباً بك في ويلورا",
            ["Notification.NewDoctorRegisteredTitle"] = "تسجيل طبيب جديد",
            ["Notification.NewDoctorRegistrationTitle"] = "طلب تسجيل طبيب جديد",
            ["Email.Brand"] = "ويلورا للرعاية الصحية",
            ["Email.Greeting"] = "مرحباً، {userName}",
            ["Email.OtpSubject"] = "رمز التحقق الخاص بك - ويلورا",
            ["Email.OtpHeadline"] = "رمز التحقق الخاص بك",
            ["Email.OtpBody"] = "استخدم رمز المرور لمرة واحدة التالي لتأكيد هويتك.",
            ["Email.OtpExpires"] = "تنتهي صلاحية هذا الرمز خلال 15 دقيقة.",
            ["Email.OtpWarning"] = "لا تشارك هذا الرمز مع أي شخص.",
            ["Email.ResetSubject"] = "إعادة تعيين كلمة مرور ويلورا",
            ["Email.ResetHeadline"] = "إعادة تعيين كلمة المرور",
            ["Email.ResetBody"] = "تلقينا طلباً لإعادة تعيين كلمة المرور. استخدم الزر التالي للمتابعة.",
            ["Email.ResetAction"] = "إعادة تعيين كلمة المرور",
            ["Email.WelcomeSubject"] = "مرحباً بك في ويلورا",
            ["Email.WelcomeHeadline"] = "مرحباً بك في ويلورا",
            ["Email.WelcomeBody"] = "أصبح حسابك جاهزاً. يمكنك الآن تسجيل الدخول وإكمال إعداد تجربة الرعاية الصحية الخاصة بك.",
            ["Email.VerifySubject"] = "تأكيد البريد الإلكتروني - ويلورا",
            ["Email.VerifyHeadline"] = "تأكيد البريد الإلكتروني",
            ["Email.VerifyBody"] = "أكمل تأكيد بريدك الإلكتروني باستخدام الرمز الآمن التالي.",
            ["Email.DoctorApprovedSubject"] = "تمت الموافقة على تحقق الطبيب الخاص بك",
            ["Email.DoctorApprovedHeadline"] = "تمت الموافقة على تحقق الطبيب",
            ["Email.DoctorApprovedBody"] = "تمت الموافقة على حساب الطبيب الخاص بك ويمكنك الآن الوصول إلى ميزات الأطباء.",
            ["Email.DoctorRejectedSubject"] = "تحديث بخصوص تحقق الطبيب الخاص بك",
            ["Email.DoctorRejectedHeadline"] = "تحديث تحقق الطبيب",
            ["Email.DoctorRejectedBody"] = "يحتاج طلب تحقق الطبيب إلى تحديثات قبل اعتماده.",
            ["Email.BlockedSubject"] = "إشعار مهم بخصوص حسابك",
            ["Email.BlockedHeadline"] = "تم حظر حسابك",
            ["Email.BlockedBody"] = "تم حظر حسابك. راجع التفاصيل التالية.",
            ["Email.UnblockedSubject"] = "تمت استعادة الوصول إلى حسابك",
            ["Email.UnblockedHeadline"] = "تمت استعادة الوصول",
            ["Email.UnblockedBody"] = "تمت استعادة الوصول إلى حسابك ويمكنك استخدام المنصة مرة أخرى.",
            ["Email.SuspendedSubject"] = "تم تعليق حسابك مؤقتاً",
            ["Email.SuspendedHeadline"] = "تم تعليق الحساب مؤقتاً",
            ["Email.SuspendedBody"] = "تم تعليق حسابك بشكل مؤقت.",
            ["Email.UnsuspendedSubject"] = "أصبح حسابك نشطاً مرة أخرى",
            ["Email.UnsuspendedHeadline"] = "تم تفعيل الحساب مجدداً",
            ["Email.UnsuspendedBody"] = "أصبح حسابك نشطاً مرة أخرى وتمت استعادة جميع الميزات المتاحة.",
            ["Email.AdminNotes"] = "ملاحظات الإدارة",
            ["Email.RejectionReason"] = "سبب الرفض",
            ["Email.SuspensionUntil"] = "التعليق حتى",
            ["Email.Footer"] = "تم إرسال هذه الرسالة من ويلورا للرعاية الصحية.",
        };

        private static readonly Dictionary<string, string> LiteralEnglishToKey = new(StringComparer.Ordinal)
        {
            ["An unexpected error occurred. Please try again later."] = "Common.AnUnexpectedErrorOccurred",
            ["Authentication required."] = "Common.AuthenticationRequired",
            ["Validation failed. Please check your input."] = "Common.ValidationFailed",
            ["Database error occurred. Please try again later."] = "Common.DatabaseError",
            ["Failed to connect to an external service."] = "Common.ExternalServiceFailed",
            ["The operation timed out."] = "Common.Timeout",
            ["The record was modified by another user. Please refresh and try again."] = "Common.RecordModified",
            ["User not found."] = "Common.UserNotFound",
            ["Forbidden"] = "Common.Forbidden",
            ["Unauthorized"] = "Common.Unauthorized",
            ["File not found"] = "Common.FileNotFound",
            ["File deleted successfully"] = "Common.FileDeleted",
            ["Action logged successfully"] = "Common.ActionLogged",
            ["TargetEntity and TargetId are required"] = "Common.TargetEntityTargetIdRequired",
            ["Device registered successfully"] = "Common.DeviceRegistered",
            ["Failed to register device"] = "Common.DeviceRegisterFailed",
            ["FCM Token is required"] = "Common.FcmTokenRequired",
            ["Invalid token"] = "Common.InvalidToken",
            ["Invalid or expired MFA token"] = "Common.InvalidOrExpiredMfaToken",
            ["OTP sent again"] = "Common.OtpSentAgain",
            ["Search index rebuilt successfully"] = "Common.SearchIndexRebuilt",
            ["All cache rebuilt successfully"] = "Common.CacheRebuilt",
            ["Manual slot created successfully"] = "Common.ManualSlotCreated",
            ["Slot deleted successfully"] = "Common.SlotDeleted",
            ["Slot blocked successfully"] = "Common.SlotBlocked",
            ["Day off added successfully"] = "Common.DayOffAdded",
            ["Custom hours added successfully"] = "Common.CustomHoursAdded",
            ["Medical record updated successfully"] = "Common.MedicalRecordUpdated",
            ["Medical record not found"] = "Common.MedicalRecordNotFound",
            ["Medical access expiry extended successfully"] = "Common.MedicalAccessExtended",
            ["Appointment confirmed"] = "Common.AppointmentConfirmed",
            ["Appointment started"] = "Common.AppointmentStarted",
            ["Appointment completed"] = "Common.AppointmentCompleted",
            ["Share token has expired."] = "Common.ShareTokenExpired",
            ["Invalid share token."] = "Common.InvalidShareToken",
            ["Share token does not match this patient."] = "Common.ShareTokenPatientMismatch",
            ["Share token does not match this medical history."] = "Common.ShareTokenMedicalHistoryMismatch",
            ["At least one updatable field is required."] = "Common.UpdatableFieldRequired",
            ["DeviceId too long"] = "Validation.DeviceIdTooLong",
            ["Email is required"] = "Validation.EmailRequired",
            ["Invalid email format"] = "Validation.InvalidEmailFormat",
            ["Email cannot be longer than 100 characters"] = "Validation.EmailTooLong",
            ["Password is required"] = "Validation.PasswordRequired",
            ["Password must be at least 6 characters"] = "Validation.PasswordMinLength",
            ["Name is required"] = "Validation.NameRequired",
            ["Role is required"] = "Validation.RoleRequired",
            ["Role must be either 'Patient' or 'Doctor'"] = "Validation.RoleInvalid",
            ["Rating must be between 1 and 5"] = "Validation.RatingRange",
            ["Description cannot exceed 100 characters."] = "Validation.DescriptionTooLong",
            ["Full name is required"] = "Validation.FullNameRequired",
            ["Full name cannot exceed 100 characters"] = "Validation.FullNameTooLong",
            ["Supported languages are 'en' and 'ar' only."] = "Language.SupportedOnly",
            ["Language preference updated successfully."] = "Language.PreferenceUpdated",
            ["Verification Approved"] = "Notification.VerificationApprovedTitle",
            ["Verification Rejected"] = "Notification.VerificationRejectedTitle",
            ["Account Blocked"] = "Notification.AccountBlockedTitle",
            ["Account Unblocked"] = "Notification.AccountUnblockedTitle",
            ["Account Suspended"] = "Notification.AccountSuspendedTitle",
            ["Account Active Again"] = "Notification.AccountUnsuspendedTitle",
            ["Support Reply"] = "Notification.SupportReplyTitle",
            ["Ticket Closed"] = "Notification.TicketClosedTitle",
            ["Appointment Booked"] = "Notification.AppointmentBookedTitle",
            ["Review Added"] = "Notification.ReviewAddedTitle",
            ["Review Updated"] = "Notification.ReviewUpdatedTitle",
            ["Review Deleted"] = "Notification.ReviewDeletedTitle",
            ["Reminder"] = "Notification.ReminderTitle",
            ["Doctor Profile Completed"] = "Notification.DoctorProfileCompletedTitle",
            ["Patient Profile Completed"] = "Notification.PatientProfileCompletedTitle",
            ["Doctor Verification Submitted"] = "Notification.DoctorDocumentsSubmittedTitle",
            ["Doctor Achievement Added"] = "Notification.DoctorAchievementAddedTitle",
            ["Two-Factor Authentication Enabled"] = "Notification.MfaEnabledTitle",
            ["Two-Factor Authentication Disabled"] = "Notification.MfaDisabledTitle",
            ["Payment Completed"] = "Notification.PaymentCompletedTitle",
            ["New Appointment"] = "Notification.NewAppointmentTitle",
            ["Appointment Cancelled"] = "Notification.AppointmentCancelledTitle",
            ["Welcome to Wellora"] = "Notification.WelcomeTitle",
            ["New Doctor Registered"] = "Notification.NewDoctorRegisteredTitle",
            ["New Doctor Registration"] = "Notification.NewDoctorRegistrationTitle"
        };

        public string GetCurrentLanguage() => AppLanguageContext.Language;

        public string NormalizeLanguage(string? language) => AppLanguages.Normalize(language);

        public bool IsRightToLeft(string? language = null) => AppLanguages.IsRtl(language ?? GetCurrentLanguage());

        public CultureInfo GetCulture(string? language = null)
            => NormalizeLanguage(language) == AppLanguages.Arabic ? ArabicCulture : EnglishCulture;

        public string Localize(string key, IDictionary<string, string>? arguments = null, string? language = null)
        {
            var normalizedLanguage = NormalizeLanguage(language ?? GetCurrentLanguage());
            var dictionary = normalizedLanguage == AppLanguages.Arabic ? ArabicTexts : EnglishTexts;
            var template = dictionary.TryGetValue(key, out var value)
                ? value
                : EnglishTexts.TryGetValue(key, out var englishValue)
                    ? englishValue
                    : key;

            if (arguments is null || arguments.Count == 0)
            {
                return template;
            }

            foreach (var pair in arguments)
            {
                template = template.Replace($"{{{pair.Key}}}", pair.Value, StringComparison.Ordinal);
            }

            return template;
        }

        public string TranslateText(string? text, string? language = null)
        {
            if (string.IsNullOrWhiteSpace(text))
            {
                return text ?? string.Empty;
            }

            var normalizedLanguage = NormalizeLanguage(language ?? GetCurrentLanguage());
            if (normalizedLanguage == AppLanguages.English)
            {
                return text;
            }

            if (LiteralEnglishToKey.TryGetValue(text, out var key))
            {
                return Localize(key, language: normalizedLanguage);
            }

            var trimmed = text.Trim();

            var patterns = new List<(Regex Regex, Func<Match, string> Translate)>
            {
                (new Regex("^Reason: (?<reason>.+)\\.$", RegexOptions.Compiled), match =>
                    Localize("Common.ReasonPrefix", new Dictionary<string, string>
                    {
                        ["reason"] = match.Groups["reason"].Value
                    }, normalizedLanguage)),
                (new Regex("^(?<entity>[A-Za-z]+) with key '(?<key>.+)' was not found\\.$", RegexOptions.Compiled), match =>
                    $"{TranslateEntityName(match.Groups["entity"].Value, normalizedLanguage)} بالمعرف '{match.Groups["key"].Value}' غير موجود."),
                (new Regex("^Doctor #(?<id>\\d+)$", RegexOptions.Compiled), match => $"الطبيب رقم {match.Groups["id"].Value}"),
                (new Regex("^Patient #(?<id>\\d+)$", RegexOptions.Compiled), match => $"المريض رقم {match.Groups["id"].Value}"),
                (new Regex("^User #(?<id>\\d+)$", RegexOptions.Compiled), match => $"المستخدم رقم {match.Groups["id"].Value}"),
                (new Regex("^Cannot book slot with status: (?<status>.+)$", RegexOptions.Compiled), match =>
                    $"لا يمكن حجز الموعد بحالة: {match.Groups["status"].Value}"),
                (new Regex("^Cannot start appointment with status: (?<status>.+)$", RegexOptions.Compiled), match =>
                    $"لا يمكن بدء الموعد بحالة: {match.Groups["status"].Value}"),
                (new Regex("^Dose skipped$", RegexOptions.Compiled), _ =>
                    "تم تخطي الجرعة"),
                (new Regex("^An error occurred while confirming the dose$", RegexOptions.Compiled), _ =>
                    "حدث خطأ أثناء تأكيد الجرعة"),
                (new Regex("^An error occurred while snoozing the dose$", RegexOptions.Compiled), _ =>
                    "حدث خطأ أثناء تأجيل الجرعة"),
                (new Regex("^Your appointment with (?<doctor>.+) has been booked for (?<date>.+)\\.$", RegexOptions.Compiled), match =>
                    $"تم حجز موعدك مع {match.Groups["doctor"].Value} بتاريخ {match.Groups["date"].Value}."),
                (new Regex("^(?<patient>.+) booked an appointment with you for (?<date>.+)\\.$", RegexOptions.Compiled), match =>
                    $"قام {match.Groups["patient"].Value} بحجز موعد معك بتاريخ {match.Groups["date"].Value}."),
                (new Regex("^(?<patient>.+) added a new (?<rating>\\d+)-star review to your profile\\.$", RegexOptions.Compiled), match =>
                    $"أضاف {match.Groups["patient"].Value} مراجعة جديدة بتقييم {match.Groups["rating"].Value} نجوم إلى ملفك الشخصي."),
                (new Regex("^(?<patient>.+) updated a review on your profile\\.$", RegexOptions.Compiled), match =>
                    $"قام {match.Groups["patient"].Value} بتحديث مراجعة على ملفك الشخصي."),
                (new Regex("^(?<patient>.+) deleted a review from your profile\\.$", RegexOptions.Compiled), match =>
                    $"قام {match.Groups["patient"].Value} بحذف مراجعة من ملفك الشخصي."),
                (new Regex("^Your appointment starts in 1 hour at (?<time>.+)$", RegexOptions.Compiled), match =>
                    $"سيبدأ موعدك خلال ساعة واحدة في {match.Groups["time"].Value}"),
                (new Regex("^Your appointment is starting now$", RegexOptions.Compiled), _ =>
                    "موعدك يبدأ الآن"),
                (new Regex("^Your doctor verification for (?<doctor>.+) has been approved\\. You can now access doctor features and start receiving patients\\.$", RegexOptions.Compiled), match =>
                    $"تمت الموافقة على تحقق الطبيب الخاص بك لـ {match.Groups["doctor"].Value}. يمكنك الآن استخدام ميزات الطبيب والبدء في استقبال المرضى."),
                (new Regex("^Your doctor verification for (?<doctor>.+) was rejected\\. (?<reason>.+)$", RegexOptions.Compiled), match =>
                    $"تم رفض تحقق الطبيب الخاص بك لـ {match.Groups["doctor"].Value}. {TranslateText(match.Groups["reason"].Value, normalizedLanguage)}"),
                (new Regex("^Your account \\(User #(?<id>\\d+)\\) has been blocked\\. (?<reason>.+) Please contact support for more information\\.$", RegexOptions.Compiled), match =>
                    $"تم حظر حسابك (المستخدم رقم {match.Groups["id"].Value}). {TranslateText(match.Groups["reason"].Value, normalizedLanguage)} يرجى التواصل مع الدعم لمزيد من المعلومات."),
                (new Regex("^Your account suspension for User #(?<id>\\d+) has ended and your access has been restored\\.$", RegexOptions.Compiled), match =>
                    $"انتهى تعليق حسابك للمستخدم رقم {match.Groups["id"].Value} وتمت استعادة الوصول."),
                (new Regex("^Your account \\(User #(?<id>\\d+)\\) has been unblocked\\. You can now access all available features again\\.$", RegexOptions.Compiled), match =>
                    $"تم إلغاء حظر حسابك (المستخدم رقم {match.Groups["id"].Value}). يمكنك الآن الوصول إلى جميع الميزات المتاحة مرة أخرى."),
                (new Regex("^An admin responded to your support ticket #(?<id>\\d+)\\. Open the ticket to review the latest reply\\.$", RegexOptions.Compiled), match =>
                    $"قام أحد المشرفين بالرد على تذكرة الدعم رقم {match.Groups["id"].Value}. افتح التذكرة للاطلاع على أحدث رد."),
                (new Regex("^Your support ticket #(?<id>\\d+) has been closed\\. If you still need help, you can create a new ticket at any time\\.$", RegexOptions.Compiled), match =>
                    $"تم إغلاق تذكرة الدعم رقم {match.Groups["id"].Value}. إذا كنت ما زلت بحاجة إلى المساعدة، يمكنك إنشاء تذكرة جديدة في أي وقت."),
                (new Regex("^Your doctor profile for Dr\\. (?<name>.+) is now complete\\. The next step is to submit your verification documents for admin review\\.$", RegexOptions.Compiled), match =>
                    $"أصبح ملف الطبيب الخاص بالدكتور {match.Groups["name"].Value} مكتملاً الآن. الخطوة التالية هي إرسال مستندات التحقق لمراجعتها من قبل الإدارة."),
                (new Regex("^Your patient profile for (?<name>.+) has been completed successfully\\. You can now continue using appointment and medical features\\.$", RegexOptions.Compiled), match =>
                    $"تم إكمال ملف المريض الخاص بـ {match.Groups["name"].Value} بنجاح. يمكنك الآن متابعة استخدام ميزات المواعيد والملف الطبي."),
                (new Regex("^A new doctor account was created for (?<name>.+) \\(Doctor #(?<id>\\d+)\\)\\. The doctor can now complete the profile and submit verification documents\\.$", RegexOptions.Compiled), match =>
                    $"تم إنشاء حساب طبيب جديد باسم {match.Groups["name"].Value} (الطبيب رقم {match.Groups["id"].Value}). يمكن للطبيب الآن إكمال الملف الشخصي وإرسال مستندات التحقق."),
                (new Regex("^A doctor account was registered for (?<name>.+) \\(Doctor #(?<id>\\d+)\\) through Google sign-in and is ready for profile completion and review\\.$", RegexOptions.Compiled), match =>
                    $"تم تسجيل حساب طبيب باسم {match.Groups["name"].Value} (الطبيب رقم {match.Groups["id"].Value}) عبر تسجيل الدخول بجوجل وهو جاهز لإكمال الملف والمراجعة."),
            };

            patterns.Add((new Regex("^New Appointment$", RegexOptions.Compiled), _ => "موعد جديد"));
            patterns.Add((new Regex("^Appointment Cancelled$", RegexOptions.Compiled), _ => "تم إلغاء الموعد"));
            patterns.Add((new Regex("^Welcome to Wellora$", RegexOptions.Compiled), _ => "مرحباً بك في ويلورا"));
            patterns.Add((new Regex("^New Doctor Registered$", RegexOptions.Compiled), _ => "تسجيل طبيب جديد"));
            patterns.Add((new Regex("^New Doctor Registration$", RegexOptions.Compiled), _ => "طلب تسجيل طبيب جديد"));
            patterns.Add((new Regex("^Welcome Dr\\. (?<name>.+)\\. Your doctor account has been created\\. Complete your profile and submit your verification documents to start receiving patients\\.$", RegexOptions.Compiled), match =>
                $"مرحباً د. {match.Groups["name"].Value}. تم إنشاء حساب الطبيب الخاص بك. أكمل ملفك الشخصي وأرسل مستندات التحقق للبدء في استقبال المرضى."));
            patterns.Add((new Regex("^Welcome (?<name>.+)\\. Your patient account is ready, and you can now book doctors, manage appointments, and receive updates\\.$", RegexOptions.Compiled), match =>
                $"مرحباً {match.Groups["name"].Value}. حساب المريض الخاص بك جاهز، ويمكنك الآن حجز الأطباء وإدارة المواعيد وتلقي التحديثات."));
            patterns.Add((new Regex("^Welcome Dr\\. (?<name>.+)\\. Your doctor account is ready\\. Complete your profile and upload verification documents to activate doctor workflows\\.$", RegexOptions.Compiled), match =>
                $"مرحباً د. {match.Groups["name"].Value}. حساب الطبيب الخاص بك جاهز. أكمل ملفك الشخصي وارفع مستندات التحقق لتفعيل سير عمل الطبيب."));
            patterns.Add((new Regex("^Welcome (?<name>.+)\\. Your patient account is ready to use, and you can now book doctors and manage your care\\.$", RegexOptions.Compiled), match =>
                $"مرحباً {match.Groups["name"].Value}. حساب المريض الخاص بك جاهز للاستخدام، ويمكنك الآن حجز الأطباء وإدارة رعايتك."));
            patterns.Add((new Regex("^Your account is suspended(?<tail>.*)$", RegexOptions.Compiled), match =>
                $"حسابك معلق{match.Groups["tail"].Value}"));

            foreach (var pattern in patterns)
            {
                var match = pattern.Regex.Match(trimmed);
                if (match.Success)
                {
                    return pattern.Translate(match);
                }
            }

            return text;
        }

        public string FormatDateTime(DateTime value, string? language = null, bool includeTime = true)
        {
            var culture = GetCulture(language);
            var format = includeTime
                ? "dddd, dd MMM yyyy 'at' hh:mm tt"
                : "dddd, dd MMM yyyy";

            if (culture.Name.StartsWith("ar", StringComparison.OrdinalIgnoreCase))
            {
                format = includeTime
                    ? "dddd، dd MMM yyyy 'الساعة' hh:mm tt"
                    : "dddd، dd MMM yyyy";
            }

            return value.ToString(format, culture);
        }

        public string FormatDate(DateTime value, string? language = null) => FormatDateTime(value, language, includeTime: false);

        public string FormatTime(DateTime value, string? language = null)
        {
            var culture = GetCulture(language);
            return value.ToString("hh:mm tt", culture);
        }

        public string FormatAmount(decimal amount, string currency = "EGP", string? language = null)
        {
            var culture = GetCulture(language);
            var formattedAmount = amount.ToString("N2", culture);
            return NormalizeLanguage(language) == AppLanguages.Arabic
                ? $"{formattedAmount} {TranslateCurrency(currency)}"
                : $"{formattedAmount} {currency}";
        }

        public string FormatEnumLabel(string value, string? language = null)
        {
            if (NormalizeLanguage(language) != AppLanguages.Arabic)
            {
                return value;
            }

            return value switch
            {
                "Blocked" => "محظور",
                "Suspended" => "معلق",
                "Approved" => "مقبول",
                "Rejected" => "مرفوض",
                "Pending" => "قيد الانتظار",
                "Open" => "مفتوحة",
                "Closed" => "مغلقة",
                "Resolved" => "تم الحل",
                "InProgress" => "قيد المعالجة",
                _ => value
            };
        }

        private static string TranslateCurrency(string currency)
            => currency.Equals("EGP", StringComparison.OrdinalIgnoreCase) ? "ج.م" : currency;

        private static string TranslateEntityName(string entityName, string language)
        {
            if (language != AppLanguages.Arabic)
            {
                return entityName;
            }

            return entityName switch
            {
                "Appointment" => "الموعد",
                "TimeSlot" => "الفترة الزمنية",
                "Payment" => "الدفع",
                "User" => "المستخدم",
                "Patient" => "المريض",
                "Doctor" => "الطبيب",
                "File" => "الملف",
                "MedicalHistory" => "السجل الطبي",
                "Prescription" => "الوصفة الطبية",
                "Review" => "المراجعة",
                "Ticket" => "التذكرة",
                _ => entityName
            };
        }
    }
}
