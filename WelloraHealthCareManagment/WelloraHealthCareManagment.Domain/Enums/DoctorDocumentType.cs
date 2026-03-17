using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Domain.Enums
{
    public enum DoctorDocumentType
    {
        License,               // شهادة المزاولة - مطلوبة
        GraduationCertificate, // شهادة التخرج - مطلوبة
        NationalId,            // بطاقة هوية - مطلوبة
        Other                  // أي وثيقة تانية - اختيارية
    }

    public enum VerificationStatus
    {
        Pending,   // لسه الأدمن ماراجعش
        Approved,  // الأدمن وافق
        Rejected   // الأدمن رفض
    }
}
