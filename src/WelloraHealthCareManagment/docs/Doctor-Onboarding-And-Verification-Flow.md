# Doctor Onboarding And Verification Flow

## الهدف من آخر التعديلات

آخر التعديلات غيرت منطق التحقق الخاص بالدكتور من شكل `verification-based` إلى شكل `doctor-based`.

يعني بدل ما الأدمن يتعامل مع كل `verification` ككيان منفصل في القرار النهائي، القرار الآن يتم على مستوى الدكتور نفسه أو على مستوى `verification request` الخاصة به.

هذا التعديل كان هدفه:

- توحيد شكل الداتا الراجعة في الـ Admin APIs.
- منع التفعيل المبكر للدكتور بمجرد اعتماد ملف واحد فقط.
- جعل اعتماد الدكتور مرتبطًا باكتمال المستندات الأساسية المطلوبة.
- السماح للدكتور بتسجيل الدخول أول مرة لإكمال البيانات والرفع، لكن بدون منحه صلاحيات الطبيب الكاملة إلا بعد الاعتماد.

---

## الفكرة العامة الآن

الدكتور يمر بمراحل واضحة:

1. يسجل حساب جديد.
2. يتم إنشاء حساب الطبيب في قاعدة البيانات بقيمة `IsActive = false`.
3. يستطيع تسجيل الدخول للتطبيق.
4. يدخل على onboarding flow ويكمل بياناته ويرفع ملفات التحقق.
5. الأدمن يراجع طلب التحقق الخاص بالدكتور ككل.
6. إذا تم الاعتماد:
   - يصبح `doctor.IsActive = true`
   - يحصل على صلاحيات الطبيب الكاملة داخل التطبيق
7. إذا لم يتم الاعتماد:
   - يظل قادرًا على الدخول لاستكمال أو تعديل البيانات والملفات
   - لكنه لا يستطيع استخدام features الطبيب التشغيلية

---

## أنواع المستندات المطلوبة

### Required Documents

هذه المستندات الثلاثة إلزامية:

- `License`
- `GraduationCertificate`
- `NationalId`

لا يمكن اعتماد الدكتور إلا إذا كانت هذه الثلاثة موجودة.

### Optional Documents

المستندات من النوع:

- `Other`

هي مستندات اختيارية، ولا تمنع اعتماد الدكتور الأساسي.

لكن:

- لا يتم عرض `Other` في profile الدكتور إلا بعد اعتمادها
- ويمكن للأدمن اعتمادها لاحقًا من نفس منطق approve doctor-based

---

## حالات طلب التحقق للدكتور

النظام يحسب `requestStatus` على مستوى الدكتور كله، وليس على مستوى كل ملف منفردًا.

القيم الحالية:

- `Incomplete`
- `Pending`
- `Approved`
- `Rejected`

### معنى كل حالة

#### `Incomplete`

تعني أن الدكتور لم يرفع جميع المستندات الأساسية المطلوبة بعد.

#### `Pending`

تعني أن المستندات الأساسية المطلوبة موجودة، لكن ما زالت قيد المراجعة.

#### `Approved`

تعني أن كل المستندات الأساسية المطلوبة تم اعتمادها، وبالتالي يحق تفعيل الدكتور.

#### `Rejected`

تعني أن واحدًا أو أكثر من المستندات الأساسية المطلوبة تم رفضه، وبالتالي لا يمكن تفعيل الدكتور حتى يقوم بإعادة الرفع أو الاستبدال.

---

## ماذا يحدث عند تسجيل دكتور جديد

عند تسجيل دكتور جديد:

- يتم إنشاء `ApplicationUser`
- يتم إنشاء `Doctor`
- تكون قيمة `Doctor.IsActive = false`

هذا مقصود، لأن الحساب لم يعتمد بعد.

لكن التعديل المهم هنا:

- الدكتور لم يعد ممنوعًا من `login`
- بل أصبح يمكنه الدخول بشكل طبيعي
- لكن token الخاص به يحمل حالة وصول محددة

---

## منطق الـ Access بعد آخر تعديل

لم نستخدم token منفصل للـ onboarding.

بدلًا من ذلك:

- ما زلنا نستخدم نفس `access token` و`refresh token`
- لكننا أضفنا claims داخل الـ JWT لتحديد حالة حساب الدكتور

### claims المضافة للدكتور

- `doctor_access_level`
- `doctor_verification_request_status`
- `doctor_is_active`

### قيم `doctor_access_level`

- `Onboarding`
- `Full`

### معنى ذلك

#### `Onboarding`

الدكتور يستطيع:

- تسجيل الدخول
- فتح profile
- استكمال البيانات
- تحديث البيانات الأساسية
- تحديث الموقع
- رفع مستندات التحقق
- استبدال الملفات المرفوضة
- متابعة حالة طلبه

لكن لا يستطيع:

- إدارة الـ slots
- إدارة جدول العمل
- التعامل مع appointment actions كطبيب
- كتابة prescriptions
- إنشاء medical records
- الوصول لأي feature تشغيلية خاصة بالطبيب المعتمد

#### `Full`

تعني أن الدكتور أصبح معتمدًا ومفعلًا، وبالتالي له كل صلاحيات الطبيب التشغيلية.

---

## الـ Authorization Policies الحالية

تم تعريف سياسات واضحة داخل الـ API:

- `DoctorOnboardingAccess`
- `ApprovedDoctorOnly`
- `ApprovedDoctorOrAdmin`
- `PatientAdminOrApprovedDoctor`

### متى نستخدم كل واحدة

#### `DoctorOnboardingAccess`

تسمح لأي دكتور بالدخول حتى لو لم يُعتمد بعد.

تُستخدم في:

- `DoctorProfileController`

#### `ApprovedDoctorOnly`

تسمح فقط للدكتور الذي:

- role = `Doctor`
- و `doctor_access_level = Full`

تُستخدم في endpoints التشغيلية الخاصة بالطبيب فقط.

#### `ApprovedDoctorOrAdmin`

تسمح لـ:

- الأدمن
- أو الطبيب المعتمد فقط

تُستخدم في endpoints مثل إدارة الـ slots أو الـ config.

#### `PatientAdminOrApprovedDoctor`

تسمح لـ:

- المريض
- الأدمن
- الطبيب المعتمد

تُستخدم عندما يكون endpoint صالحًا لعدة أدوار، لكن لا نريد السماح للطبيب غير المعتمد باستخدامه كطبيب.

---

## الـ Admin Verification APIs الحالية

### أهم endpoints

#### Get all doctor verification requests

`GET /api/admin/doctor-verifications`

يرجع list doctor-based.

#### Get pending doctor verification requests

`GET /api/admin/doctor-verifications/pending`

يرجع فقط الطلبات الجاهزة للمراجعة.

#### Get doctor verification request details

`GET /api/admin/doctor-verifications/{doctorId}`

يرجع تفاصيل طلب التحقق الخاص بالدكتور.

#### Approve doctor request

`POST /api/admin/doctor-verifications/{doctorId}/approve`

الموافقة هنا doctor-based، وليست file-based.

#### Reject doctor request

`POST /api/admin/doctor-verifications/{doctorId}/reject`

الرفض أيضًا doctor-based.

#### Get statistics

`GET /api/admin/doctor-verifications/statistics`

الـ statistics أصبحت doctor-based أيضًا.

---

## شكل الداتا في Admin Verification Response

الـ response الآن مبني على doctor base.

كل doctor object يحتوي على:

- بيانات الدكتور الأساسية
- حالة الطلب العامة `requestStatus`
- هل الطلب جاهز للمراجعة `isReadyForReview`
- الملفات الناقصة `missingRequiredDocuments`
- بيانات المراجعة الموحّدة الخاصة بالطلب
- قائمة `verifications` نفسها، ولكن بدون تكرار البيانات العامة داخل كل item

### لماذا أزلنا التكرار

لأن هذه القيم كانت تتكرر بلا داعٍ في كل verification:

- `doctorId`
- `doctorName`
- `doctorEmail`
- `specialization`
- `status` العام للطلب
- `adminNotes`
- `rejectionReason`
- `reviewedByAdminName`
- `reviewedAt`
- `submittedAt`

والآن أصبحت في المكان الصحيح: على مستوى الدكتور نفسه.

---

## منطق الـ Approve والـ Reject الآن

### Approve

عندما يقوم الأدمن باستدعاء:

`POST /api/admin/doctor-verifications/{doctorId}/approve`

فالذي يحدث:

1. يتم جلب كل verifications الخاصة بالدكتور.
2. يتم التأكد أن المستندات الأساسية الثلاثة موجودة.
3. إذا كان الطلب غير مكتمل، يتم رفض العملية.
4. إذا كان الطلب صالحًا للمراجعة، يتم اعتماد كل المستندات `Pending` الحالية الخاصة بطلب الدكتور.
5. يتم إعادة تقييم أهلية التفعيل.
6. إذا أصبحت الحالة النهائية `Approved` يتم:
   - `doctor.IsActive = true`

### Reject

عند:

`POST /api/admin/doctor-verifications/{doctorId}/reject`

فالذي يحدث:

1. يتم جلب طلب التحقق الخاص بالدكتور.
2. يتم رفض كل المستندات `Pending` الحالية الخاصة بالطلب.
3. يتم ضبط:
   - `doctor.IsActive = false`

---

## ماذا يحدث إذا عدّل الدكتور ملفًا بعد الاعتماد

هذا جزء مهم جدًا لفريق Flutter.

إذا كان الدكتور معتمدًا بالفعل، ثم:

- استبدل مستندًا required
- أو رفع نسخة جديدة من required document

فالنظام يعيد تقييم حالة الحساب.

وغالبًا سيحدث:

- المستند الجديد يصبح `Pending`
- `requestStatus` يتغير من `Approved` إلى `Pending`
- `doctor.IsActive` تعود إلى `false`
- وبالتالي يعود `doctor_access_level` في التوكن الجديد إلى `Onboarding`

هذا مقصود أمنيًا.

يعني:

- تعديل المستندات الأساسية بعد الاعتماد قد يسحب صلاحيات الطبيب التشغيلية مؤقتًا
- إلى أن يراجع الأدمن الطلب مرة أخرى

---

## ماذا يحدث إذا رفع الدكتور ملف `Other` بعد الاعتماد

إذا رفع ملف `Other` بعد أن أصبح معتمدًا:

- لا يؤثر ذلك على اعتماد المستندات الأساسية
- يظل الدكتور active
- لكن ملف `Other` نفسه لا يظهر له في profile إلا إذا اعتمده الأدمن

يعني:

- required docs تتحكم في `doctor activation`
- optional docs لا تتحكم في التفعيل
- لكنها تحتاج approve إذا أردنا إظهارها في profile الدكتور

---

## ماذا يجب على Flutter Team فعله

هذا هو الجزء الأهم للفريق.

---

## Flutter Flow المطلوب بعد الـ login

بعد نجاح الـ login لا يجب افتراض أن الدكتور صار ready لكل التطبيق.

المنطق الصحيح:

1. سجّل الدخول وخزن الـ `accessToken` و`refreshToken`
2. اعمل request مباشر على:
   - `GET /api/doctor/profile`
3. اقرأ من الـ profile البيانات التالية:
   - `isActive`
   - `isProfileCompleted`
   - `verificationRequestStatus`
   - `missingRequiredVerificationDocuments`

بعدها قرر navigation بناءً على هذه القيم.

---

## Doctor App Navigation Rules

### الحالة 1: الدكتور جديد جدًا

إذا كان:

- `isProfileCompleted = false`

إذًا:

- افتح له شاشة استكمال البيانات الأساسية مباشرة
- امنعه من الوصول إلى Home الطبيب التشغيلية

### الحالة 2: البيانات الأساسية مكتملة لكن المستندات ناقصة

إذا كان:

- `isProfileCompleted = true`
- و `verificationRequestStatus = Incomplete`

إذًا:

- افتح له شاشة رفع المستندات المطلوبة
- اعرض `missingRequiredVerificationDocuments`
- لا تفتح Home الطبيب التشغيلية

### الحالة 3: الطلب تحت المراجعة

إذا كان:

- `verificationRequestStatus = Pending`

إذًا:

- افتح شاشة "طلبك تحت المراجعة"
- اسمح له فقط بمسارات onboarding المسموحة
- لا تفتح features الطبيب التشغيلية

### الحالة 4: الطلب مرفوض

إذا كان:

- `verificationRequestStatus = Rejected`

إذًا:

- افتح شاشة "تم رفض الطلب"
- اعرض:
  - `verificationRejectionReason`
  - `verificationAdminNotes`
- اسمح له باستبدال الملفات المطلوبة
- لا تفتح Home الطبيب التشغيلية

### الحالة 5: الدكتور معتمد

إذا كان:

- `isActive = true`
- و `verificationRequestStatus = Approved`

إذًا:

- افتح التطبيق الطبيعي للطبيب
- اسمح بكل الـ doctor features

---

## Flutter Recommendation: لا تعتمد فقط على الـ token

رغم أن الـ token يحتوي claims مهمة، إلا أن الأفضل في التطبيق:

- استخدام الـ token لأغراض authorization فقط
- واستخدام `GET /api/doctor/profile` كمصدر الحقيقة الأساسي لواجهة المستخدم

السبب:

- الـ profile يعرض flags أوضح
- ويعرض البيانات التفصيلية اللازمة للـ onboarding
- ويجعل الـ UI أسهل في الإدارة

---

## Flutter Recommendation: مسار splash / bootstrap

أفضل flow عند تشغيل التطبيق:

1. اقرأ token من local storage
2. إذا غير موجود:
   - اذهب إلى login
3. إذا موجود:
   - حاول refresh عند الحاجة
   - ثم اطلب `GET /api/doctor/profile`
4. بناءً على response:
   - route إلى onboarding
   - أو route إلى rejected screen
   - أو route إلى pending review screen
   - أو route إلى doctor main home

---

## Flutter Recommendation: التعامل مع 403 أو Forbidden

إذا حاول Flutter استدعاء endpoint تشغيلية خاصة بالطبيب غير المعتمد، فالمتوقع أن يحصل على:

- `403 Forbidden`

في هذه الحالة:

- لا تعاملها كـ crash
- لا تعاملها كـ token expired
- أعد توجيه المستخدم إلى onboarding أو pending screen
- ثم أعد تحميل `GET /api/doctor/profile`

---

## Endpoints التي يجب أن يستخدمها Flutter أثناء الـ onboarding

### قراءة البروفايل

`GET /api/doctor/profile`

### استكمال البيانات الأساسية

`POST /api/doctor/profile/complete`

### تعديل basic info

`PATCH /api/doctor/profile/basic-info`

### تعديل location

`PATCH /api/doctor/profile/location`

### رفع verification document

`POST /api/doctor/profile/verification-documents`

### استبدال verification document

`PUT /api/doctor/profile/verification-documents/{verificationId}`

---

## Endpoints التي يجب اعتبارها Full Doctor Access Only

هذه لا يجب للـ Flutter اعتبارها متاحة إلا للطبيب المعتمد:

- endpoints الخاصة بإدارة appointments كطبيب
- endpoints الخاصة بالprescriptions
- endpoints الخاصة بكتابة medical records
- endpoints الخاصة بإدارة slot config
- endpoints الخاصة بإدارة time slots

حتى لو ظهر زر بالخطأ في الواجهة، الـ backend سيرفضها للطبيب غير المعتمد.

---

## UI/UX Recommendation لفريق Flutter

### شاشة onboarding الرئيسية

يفضل أن تحتوي على sections واضحة:

- Basic Information
- Clinic Information
- Required Verification Documents
- Verification Status

### اعرض حالة المستندات بوضوح

يفضل عرض:

- `Uploaded`
- `Missing`
- `Under Review`
- `Rejected`
- `Approved`

لكن القرار النهائي في UI يجب أن يعتمد على:

- `verificationRequestStatus`

وليس على status كل verification وحدها.

### شاشة pending review

يفضل أن تعرض:

- رسالة واضحة أن الحساب لا يزال تحت المراجعة
- لا يوجد وصول لميزات الطبيب حتى الآن
- إمكانية تحديث بعض البيانات إذا كانت السياسة تسمح

### شاشة rejected

يفضل أن تعرض:

- سبب الرفض
- ملاحظات الأدمن
- زر لإعادة رفع الملف أو استبداله

---

## مثال Decision Tree بسيط لفريق Flutter

```text
login success
  -> get doctor profile
     -> if isProfileCompleted == false
           go to complete profile
     -> else if verificationRequestStatus == Incomplete
           go to upload required documents
     -> else if verificationRequestStatus == Pending
           go to pending review screen
     -> else if verificationRequestStatus == Rejected
           go to rejected screen
     -> else if verificationRequestStatus == Approved && isActive == true
           go to doctor home
```

---

## ماذا يجب على Flutter Team تجنبه

- لا تفترض أن نجاح الـ login يعني نجاح اعتماد الطبيب.
- لا تبني الـ navigation فقط على وجود token.
- لا تعتمد على status كل verification منفردًا لاتخاذ قرار نهائي.
- لا تعرض optional `Other` documents في profile doctor إذا لم تكن approved.
- لا تعتبر `403` دائمًا مشكلة token أو logout فوري.

---

## ماذا يحدث بعد admin approve

عندما يعتمد الأدمن الدكتور:

- `doctor.IsActive = true`
- الـ request status يصبح `Approved`

بعد ذلك:

- لو الدكتور عمل login جديد سيأخذ token بحالة `Full`
- ولو كان لديه token قديم، فيفضل أن يقوم التطبيق بعمل:
  - refresh token
  - أو إعادة login
  - أو إعادة تحميل profile وتحديث الجلسة حسب flow التطبيق

### Recommendation

يفضل بعد شاشة pending أو rejected أن يقوم التطبيق دوريًا أو عند reopen screen بعمل:

- `GET /api/doctor/profile`

حتى يعرف إن كان الحساب قد اعتمد أم لا.

---

## ماذا يحدث إذا الطبيب المعتمد عدّل required document

هذه نقطة مهمة جدًا:

- قد يعود `isActive = false`
- وقد يعود إلى onboarding mode

إذًا Flutter يجب أن يكون مستعدًا لهذا السيناريو:

- لو API تشغيلية رجعت `403`
- أعد تحميل profile
- وإذا وجدت أن الحساب عاد إلى `Pending` أو `Rejected`
- انقله تلقائيًا من doctor home إلى onboarding flow المناسب

---

## ملخص تنفيذي

### Backend Summary

- doctor verification أصبحت `doctor-based`
- approval أصبحت على مستوى طلب الدكتور
- doctor الجديد يبدأ بـ `IsActive = false`
- doctor يستطيع `login` من أول مرة
- لكن صلاحياته تكون `Onboarding` فقط حتى الاعتماد
- التفعيل النهائي لا يتم إلا بعد اعتماد المستندات الأساسية الثلاثة

### Flutter Summary

- بعد login: اطلب `GET /api/doctor/profile`
- ابنِ navigation على:
  - `isProfileCompleted`
  - `verificationRequestStatus`
  - `isActive`
- onboarding screens يجب أن تكون منفصلة عن doctor home
- لا تسمح للواجهة باعتبار الدكتور fully active قبل `Approved + IsActive = true`

---

## ملاحظات أخيرة

هذا الملف يشرح المنطق الحالي بعد آخر التعديلات الموجودة في المشروع.

إذا تم تعديل الـ endpoints أو الـ response models مستقبلًا، يجب تحديث هذا الملف حتى يظل المرجع الرسمي بين فريق الـ backend وفريق الـ Flutter.
