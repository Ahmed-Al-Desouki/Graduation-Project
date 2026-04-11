// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:go_router/go_router.dart';
// import 'package:graduation_project/core/utils/app_router.dart';
// import 'package:graduation_project/core/utils/functions/pdf_prescription_service.dart';
// import 'package:graduation_project/core/utils/helper/service_locator.dart';
// import 'package:graduation_project/core/utils/helper/session_manager.dart';
// import 'package:graduation_project/core/widgets/shimmer_loading.dart';
// import 'package:graduation_project/features/booking/domain/entities/medication_item_entity.dart';
// import 'package:graduation_project/features/booking/domain/entities/prescription_entity.dart';
// import 'package:graduation_project/features/booking/domain/use_cases/update_appointment_status_use_case.dart';
// import 'package:graduation_project/features/booking/presentation/manager/appointment_action_cubit/appointment_action_cubit.dart';
// import 'package:graduation_project/features/booking/presentation/views/add_medication_sheet.dart';
// import '../manager/exam_session_cubit/exam_session_cubit.dart';
// import '../../domain/entities/medical_record_entity.dart';

// class MedicalDetailsView extends StatefulWidget {
//   final String appointmentId;
//   final String patientId; // ✅ تأكد من استلام ID المريض
//   final String patientName;
//   final String? patientImage;
//   final String doctorName;
//   final String? doctorImage;
//   final String doctorSpecialty;
//   final String? patientNote;
//   final String initialStatus;
//   final bool isReadOnly; // ✅ أضفنا ده

//   const MedicalDetailsView({
//     super.key,
//     required this.appointmentId,
//     required this.patientId,
//     required this.patientName,
//     this.patientImage,
//     required this.doctorName,
//     this.doctorImage,
//     required this.doctorSpecialty,
//     this.patientNote,
//     required this.initialStatus,
//     this.isReadOnly = false,
//   });

//   @override
//   State<MedicalDetailsView> createState() => _MedicalDetailsViewState();
// }

// class _MedicalDetailsViewState extends State<MedicalDetailsView> {
//   // 1. Controllers لكل حقول السجل الطبي
//   final chiefComplaintController = TextEditingController();
//   final vitalsController = TextEditingController();
//   final physicalExamController = TextEditingController();
//   final diagnosisController = TextEditingController();
//   final diagnosisCodeController = TextEditingController();
//   final treatmentPlanController = TextEditingController();
//   final doctorNotesController = TextEditingController();
//   final followUpInstructionsController = TextEditingController();

//   bool isStarted = false;
//   bool followUpRequired = false;
//   DateTime? followUpDate;
//   List<MedicationItemEntity> prescriptionItems = [];
//   String? currentPrescriptionId;
//   String? _actualPatientId;

//   // هل الموعد مكتمل؟ (للقراءة فقط)
//   bool get isCompleted => widget.initialStatus.toLowerCase() == 'completed';

//   bool get isPatient =>
//       getIt<SessionManager>().userRole?.toLowerCase() == 'patient';
//   bool get isCancelled => widget.initialStatus.toLowerCase() == 'cancelled';
//   bool get isPending => widget.initialStatus.toLowerCase() == 'pending';
//   bool get isInProgress => widget.initialStatus.toLowerCase() == 'inprogress';

//   @override
//   void initState() {
//     super.initState();
//     // لو الموعد منتهي أو قيد التنفيذ، نفتح الفورمة فوراً
//     if (isCompleted || widget.initialStatus.toLowerCase() == 'inprogress') {
//       isStarted = true;
//     }

//     // جلب البيانات المسجلة مسبقاً
//     final cubit = context.read<ExamSessionCubit>();
//     cubit.fetchAppointmentDetails(widget.appointmentId);
//   }

//   Widget _buildAccessControl() {
//     if (!isPatient || isCompleted || isCancelled)
//       return const SizedBox.shrink();

//     return Container(
//       padding: EdgeInsets.all(12.w),
//       margin: EdgeInsets.only(bottom: 16.h),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(color: const Color(0xFF9333EA).withOpacity(0.2)),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.lock_open_outlined, color: Color(0xFF9333EA)),
//           SizedBox(width: 10.w),
//           const Expanded(
//             child: Text("Allow doctor to view my full medical history"),
//           ),
//           Switch(
//             value:
//                 true, // المفروض دي تيجي من الـ API (grantMedicalHistoryAccess)
//             onChanged: (val) {
//               // نداء ريكوست تحديث الصلاحية من الكيوبت
//             },
//             activeColor: const Color(0xFF9333EA),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMedicalDetailsShimmer() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // شيمر للكارد بتاع البروفايل
//           const ShimmerLoading.rectangular(height: 90),
//           const SizedBox(height: 30),

//           // شيمر للعنوان
//           const ShimmerLoading.rectangular(height: 25, width: 150),
//           const SizedBox(height: 20),

//           // شيمر للحقول (هنعمل 4 حقول مثلاً)
//           ...List.generate(
//             4,
//             (index) => Padding(
//               padding: const EdgeInsets.only(bottom: 15),
//               child: const ShimmerLoading.rectangular(height: 55),
//             ),
//           ),

//           const SizedBox(height: 30),
//           // شيمر لقسم الروشتة
//           const ShimmerLoading.rectangular(height: 25, width: 200),
//           const SizedBox(height: 15),
//           const ShimmerLoading.rectangular(height: 100),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FD),
//       appBar: AppBar(
//         title: Text(isCompleted ? "Medical Report" : "Examination Session"),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(
//               Icons.history_edu,
//               color: Color(0xFF9333EA),
//               size: 28,
//             ),
//             tooltip: "View Medical History",
//             onPressed: () {
//               // الانتقال لصفحة الهيستوري مع تمرير ID المريض وعلم الـ DoctorView
//               context.push(
//                 AppRouter.kMedicalHistory,
//                 extra: {
//                   'patientId': _actualPatientId, // تأكد إنك استلمته من الكالندر
//                   'appointmentId': widget.appointmentId,
//                   'isDoctorView': true, // 👈 دي اللي هتقفل أزرار التعديل
//                 },
//               );
//             },
//           ),
//           if (isCompleted) // يظهر فقط لما الجلسة تخلص
//             IconButton(
//               icon: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
//               onPressed: () {
//                 // هنا هننادي الفانكشن بتاعة الـ PDF اللي هنعملها المرة الجاية
//                 _showSnackBar("Generating PDF...");
//                 PdfPrescriptionService.generatePrescription(
//                   patientName: widget.patientName,
//                   doctorName: widget.doctorName,
//                   diagnosis: diagnosisController.text,
//                   items: prescriptionItems,
//                 );
//               },
//             ),
//           const SizedBox(width: 10),
//         ],
//       ),
//       body: MultiBlocListener(
//         listeners: [
//           // مراقب جلب البيانات
//           BlocListener<ExamSessionCubit, ExamSessionState>(
//             listener: (context, state) {
//               if (state is AppointmentDetailsFetched) {
//                 // ✅ الستيت الجديدة الشاملة
//                 final details = state.details;
//                 setState(() {
//                   _actualPatientId =
//                       details.patientId
//                           .toString(); // ✅ سجل الـ ID اللي جه من السيرفر
//                 });
//                 // 1. ملء بيانات السجل الطبي لو موجودة
//                 if (details.medicalRecord != null) {
//                   _populateMedicalData(details.medicalRecord!);
//                   setState(
//                     () => isStarted = true,
//                   ); // لو فيه ريكورد يبقى بدأت فعلاً
//                 }

//                 // 2. ملء الروشتات (بناخد أول روشتة لأن الأيندبوينت بتبعت لستة)
//                 if (details.prescriptions != null &&
//                     details.prescriptions!.isNotEmpty) {
//                   setState(() {
//                     prescriptionItems = List.from(
//                       details.prescriptions!.first.items,
//                     );
//                     currentPrescriptionId =
//                         details.prescriptions!.first.prescriptionId;
//                   });
//                 }
//               }
//               // if (state is MedicalRecordFetched) {
//               //   _populateMedicalData(state.record);
//               // } else if (state is PrescriptionFetchedSuccess) {
//               //   setState(() {
//               //     prescriptionItems = List.from(state.prescription.items);
//               //     currentPrescriptionId = state.prescription.prescriptionId;
//               //   });
//               // } else
//               if (state is PrescriptionCreatedSuccess) {
//                 // ✅ نحدث البيانات من السيرفر فوراً عشان الـ IDs تنزل والسلة تختفي
//                 context.read<ExamSessionCubit>().fetchPrescription(
//                   widget.appointmentId,
//                 );
//                 _showSnackBar(state.message, isError: false);
//               } else if (state is ExamSessionFailure) {
//                 _showSnackBar(state.errMessage, isError: true);
//               }
//             },
//           ),
//           // مراقب الأكشن (Start/Complete)
//           BlocListener<AppointmentActionCubit, AppointmentActionState>(
//             listener: (context, state) {
//               if (state is AppointmentActionSuccess) {
//                 if (state.message.toLowerCase().contains("start") ||
//                     !isStarted) {
//                   setState(() => isStarted = true);
//                 }
//               } else if (state is AppointmentActionFailure) {
//                 _showSnackBar(state.errMessage, isError: true);
//               }
//             },
//           ),
//         ],
//         child: BlocBuilder<ExamSessionCubit, ExamSessionState>(
//           builder: (context, state) {
//             if (state is MedicalRecordLoading && !isStarted) {
//               return _buildMedicalDetailsShimmer();
//             }

//             return SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildProfileCard(),
//                   const SizedBox(height: 20),
//                   _buildAccessControl(),
//                   if (isCancelled) _buildCancelledBanner(), // بانر الإلغاء
//                   // التبديل بين شاشة الانتظار وشاشة الجلسة النشطة
//                   AnimatedSwitcher(
//                     duration: const Duration(milliseconds: 500),
//                     // child:
//                     //     !isStarted
//                     //         ? _buildPreStartDashboard()
//                     //         : _buildSessionActiveUI(),
//                     child: _buildBodyByStatus(),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildBodyByStatus() {
//     // 1. حالة الملغي
//     if (isCancelled) return _buildCancelledView();

//     // 2. حالة الـ Pending (للدكتور يظهر زرار Start، وللمريض يظهر انتظار)
//     if (isPending && !isStarted) return _buildPreStartDashboard();

//     // 3. حالة الـ InProgress أو الـ Completed
//     return _buildSessionActiveUI();
//   }

//   // --- 🎨 UI Widgets ---

//   // 1. شاشة ما قبل بدء الجلسة
//   Widget _buildPreStartDashboard() {
//     return Column(
//       key: const ValueKey("preStart"),
//       children: [
//         const SizedBox(height: 40),
//         Center(
//           child: Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.blue.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.medical_services_outlined,
//               size: 80,
//               color: Colors.blue,
//             ),
//           ),
//         ),
//         const SizedBox(height: 20),
//         const Text(
//           "Ready to start the session?",
//           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 10),
//         const Text(
//           "Review patient notes before you begin.",
//           style: TextStyle(color: Colors.grey),
//         ),
//         const SizedBox(height: 30),
//         _buildPatientNoteSection(),
//         const SizedBox(height: 40),
//         _buildStartButton(),
//       ],
//     );
//   }

//   // 2. الجلسة النشطة (الفورمة والروشتة)
//   // Widget _buildSessionActiveUI() {
//   //   return Column(
//   //     key: const ValueKey("activeSession"),
//   //     crossAxisAlignment: CrossAxisAlignment.start,
//   //     children: [
//   //       if (isCompleted) _buildReadOnlyBanner(),
//   //       const Text(
//   //         "Clinical Assessment",
//   //         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//   //       ),
//   //       const SizedBox(height: 15),
//   //       _buildMedicalRecordForm(),
//   //       const Divider(height: 50, thickness: 1),
//   //       _buildPrescriptionSection(),
//   //       const SizedBox(height: 40),
//   //       _buildActionButton(),
//   //     ],
//   //   );
//   // }

//   Widget _buildSessionActiveUI() {
//     bool canEdit =
//         !widget.isReadOnly && !isCompleted; // الدكتور فقط وفي جلسة نشطة

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (isCompleted) _buildReadOnlyBanner(),
//         const Text(
//           "Clinical Assessment",
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 15),
//         _buildMedicalRecordForm(), // الحقول هتكون Enabled بناءً على الـ isCompleted

//         const Divider(height: 50, thickness: 1),
//         _buildPrescriptionSection(),

//         // ✅ زرار الحفظ يظهر للدكتور فقط وليس في وضع القراءة
//         if (canEdit || (isCompleted && !widget.isReadOnly))
//           _buildActionButton(),
//       ],
//     );
//   }

//   Widget _buildCancelledBanner() {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: Colors.red.shade50,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.red.shade200),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.cancel_rounded, color: Colors.red),
//           SizedBox(width: 10.w),
//           const Expanded(
//             child: Text(
//               "This appointment has been cancelled. No clinical data available.",
//               style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCancelledView() {
//     return Center(
//       child: Column(
//         children: [
//           SizedBox(height: 40.h),
//           Icon(Icons.event_busy, size: 80.sp, color: Colors.grey.shade300),
//           const SizedBox(height: 16),
//           const Text(
//             "Appointment Cancelled",
//             style: TextStyle(color: Colors.grey, fontSize: 18),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPatientNoteSection() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.orange.shade200),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Icons.psychology_alt,
//                 color: Colors.orange.shade700,
//                 size: 20,
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 "Reason for Visit (Patient's Note)",
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.orange.shade900,
//                   fontSize: 14,
//                 ),
//               ),
//             ],
//           ),
//           const Divider(height: 20),
//           Text(
//             // ✅ هنا الملاحظة اللي المريض كتبها وقت الحجز
//             (widget.patientNote != null && widget.patientNote!.isNotEmpty)
//                 ? widget.patientNote!
//                 : "No specific reason provided by the patient.",
//             style: const TextStyle(
//               fontSize: 15,
//               color: Color(0xFF334155),
//               height: 1.5,
//               fontStyle: FontStyle.italic,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // 4. بانر "للقراءة فقط" للمواعيد المنتهية
//   Widget _buildReadOnlyBanner() {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       margin: const EdgeInsets.only(bottom: 20),
//       decoration: BoxDecoration(
//         color: Colors.grey[200],
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey[400]!),
//       ),
//       child: const Row(
//         children: [
//           Icon(Icons.lock_outline, color: Colors.grey),
//           SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               "This session is completed. Medical records are locked, but you can update medications.",
//               style: TextStyle(
//                 color: Colors.grey,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 12,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // 5. حقول السجل الطبي (الفورمة كاملة)
//   Widget _buildMedicalRecordForm() {
//     return Column(
//       children: [
//         _CustomTextField(
//           controller: chiefComplaintController,
//           label: "Chief Complaint",
//           icon: Icons.sick_outlined,
//           enabled: !isCompleted,
//         ),
//         _CustomTextField(
//           controller: vitalsController,
//           label: "Vital Signs (BP, Temp, Pulse)",
//           icon: Icons.monitor_heart_outlined,
//           enabled: !isCompleted,
//         ),
//         _CustomTextField(
//           controller: physicalExamController,
//           label: "Physical Examination",
//           icon: Icons.accessibility_new_outlined,
//           enabled: !isCompleted,
//         ),
//         _CustomTextField(
//           controller: diagnosisController,
//           label: "Final Diagnosis *",
//           icon: Icons.fact_check_outlined,
//           enabled: !isCompleted,
//         ),
//         _CustomTextField(
//           controller: diagnosisCodeController,
//           label: "Diagnosis Code (ICD-10)",
//           icon: Icons.qr_code_outlined,
//           enabled: !isCompleted,
//         ),
//         _CustomTextField(
//           controller: treatmentPlanController,
//           label: "Treatment Plan",
//           icon: Icons.event_note_outlined,
//           maxLines: 3,
//           enabled: !isCompleted,
//         ),
//         _CustomTextField(
//           controller: doctorNotesController,
//           label: "Internal Doctor Notes",
//           icon: Icons.note_alt_outlined,
//           maxLines: 2,
//           enabled: !isCompleted,
//         ),
//       ],
//     );
//   }

//   // 6. قسم الروشتة (العناوين، اللستة، وزرار الإضافة)
//   Widget _buildPrescriptionSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "Medication Prescription",
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 15),
//         _buildPrescriptionItemsList(),
//         const SizedBox(height: 15),
//         InkWell(
//           onTap: _showAddMedicationSheet,
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 14),
//             decoration: BoxDecoration(
//               color: const Color(0xFF9333EA).withOpacity(0.05),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: const Color(0xFF9333EA).withOpacity(0.2),
//               ),
//             ),
//             child: const Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.add_circle_outline, color: Color(0xFF9333EA)),
//                 SizedBox(width: 8),
//                 Text(
//                   "Add Medication",
//                   style: TextStyle(
//                     color: Color(0xFF9333EA),
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // 7. زرار الأكشن النهائي (Finish أو Update)
//   Widget _buildActionButton() {
//     return BlocBuilder<AppointmentActionCubit, AppointmentActionState>(
//       builder: (context, state) {
//         bool isLoading = state is AppointmentActionLoading;
//         return ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             backgroundColor:
//                 isCompleted ? Colors.blue : const Color(0xFF9333EA),
//             minimumSize: const Size(double.infinity, 55),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(15),
//             ),
//           ),
//           onPressed: isLoading ? null : _handleFinishSession,
//           child:
//               isLoading
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : Text(
//                     isCompleted
//                         ? "Update Treatment Plan"
//                         : "Finish & Complete Session",
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//         );
//       },
//     );
//   }

//   // --- ⚙️ Logic Methods ---

//   void _handleFinishSession() async {
//     // التحقق من البيانات فقط في الجلسة الجديدة
//     if (!isCompleted) {
//       if (diagnosisController.text.trim().isEmpty ||
//           prescriptionItems.isEmpty) {
//         _showSnackBar(
//           "Diagnosis and at least one medication are required",
//           isError: true,
//         );
//         return;
//       }
//     }

//     // حفظ البيانات (ريكورد + روشتة)
//     await _onCompletePressed();

//     if (!isCompleted) {
//       final sessionState = context.read<ExamSessionCubit>().state;
//       if (sessionState is! ExamSessionFailure) {
//         // تحديث حالة الموعد لـ Complete في السيرفر
//         await context.read<AppointmentActionCubit>().updateStatus(
//           widget.appointmentId,
//           AppointmentAction.complete,
//         );
//         _showFollowUpDialog();
//       }
//     }
//   }

//   Future<void> _onCompletePressed() async {
//     // 1. تجهيز الريكورد (للعلم فقط لو مش Completed)
//     final record = MedicalRecordEntity(
//       chiefComplaint: chiefComplaintController.text,
//       vitalSigns: vitalsController.text,
//       physicalExamination: physicalExamController.text,
//       diagnosis: diagnosisController.text,
//       diagnosisCode: diagnosisCodeController.text,
//       treatmentPlan: treatmentPlanController.text,
//       doctorNotes: doctorNotesController.text,
//       followUpRequired: followUpRequired,
//       followUpDate: followUpDate,
//       followUpInstructions:
//           followUpInstructionsController.text.isEmpty
//               ? "None"
//               : followUpInstructionsController.text,
//     );

//     // 2. لو الجلسة لسه شغالة (InProgress)
//     if (!isCompleted) {
//       final isUpdate =
//           context.read<ExamSessionCubit>().state is MedicalRecordFetched;
//       await context.read<ExamSessionCubit>().saveMedicalRecord(
//         appointmentId: widget.appointmentId,
//         record: record,
//         isUpdate: isUpdate,
//       );

//       final prescription = PrescriptionEntity(
//         validUntil: DateTime.now().add(const Duration(days: 30)),
//         items: prescriptionItems,
//       );
//       await context.read<ExamSessionCubit>().createPrescription(
//         appointmentId: widget.appointmentId,
//         prescription: prescription,
//       );
//     }
//     // 3. ✅ لو الجلسة منتهية (Completed) - سيناريو تحديث الأدوية
//     else {
//       final newItems =
//           prescriptionItems.where((item) => item.itemId == null).map((item) {
//             if (item.reminderFrequencyType == 0) {
//               return item.copyWith(
//                 duration: "1 day",
//                 reminderEndDate: null, // ✅ تأكيد إرسال null للـ Once
//                 reminderWeeklyDays: null, // ✅ تأكيد إرسال null
//                 reminderFirstDoseTime: null,
//                 frequency: "Once",
//               );
//             }
//             return item;
//           }).toList();
//       if (newItems.isNotEmpty && currentPrescriptionId != null) {
//         await context.read<ExamSessionCubit>().addPrescriptionItems(
//           prescriptionId: currentPrescriptionId!,
//           items: newItems,
//         );
//       }
//     }
//   }

//   // --- 🛠️ Helper Methods ---

//   void _populateMedicalData(MedicalRecordEntity record) {
//     setState(() {
//       chiefComplaintController.text = record.chiefComplaint;
//       vitalsController.text = record.vitalSigns;
//       physicalExamController.text = record.physicalExamination;
//       diagnosisController.text = record.diagnosis;
//       diagnosisCodeController.text = record.diagnosisCode;
//       treatmentPlanController.text = record.treatmentPlan;
//       doctorNotesController.text = record.doctorNotes;
//       isStarted = true;
//     });
//   }

//   Widget _buildPrescriptionItemsList() {
//     if (prescriptionItems.isEmpty) {
//       return const Center(
//         child: Padding(
//           padding: EdgeInsets.all(20),
//           child: Text("No medicines added"),
//         ),
//       );
//     }

//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: prescriptionItems.length,
//       itemBuilder: (context, index) {
//         final item = prescriptionItems[index];
//         // ✅ السلة هتختفي لو الـ itemId جاي من السيرفر (مش null)
//         bool isSavedOnServer = item.itemId != null;

//         return Card(
//           margin: const EdgeInsets.only(bottom: 12),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15),
//             side: BorderSide(color: Colors.grey.shade200),
//           ),
//           elevation: 0,
//           child: Padding(
//             padding: const EdgeInsets.all(12),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 ListTile(
//                   contentPadding: EdgeInsets.zero,
//                   leading: CircleAvatar(
//                     backgroundColor: const Color(0xFFF3E8FF),
//                     child: Icon(
//                       Icons.medication,
//                       color: const Color(0xFF9333EA),
//                     ),
//                   ),
//                   title: Text(
//                     item.medicationName,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//                   subtitle: Text(
//                     "Quantity: ${item.quantity} units",
//                   ), // ✅ إضافة الكمية [cite: 50]
//                   trailing:
//                       (isCompleted && isSavedOnServer)
//                           ? null // ✅ إخفاء السلة للأدوية المسجلة في المواعيد المنتهية
//                           : IconButton(
//                             icon: const Icon(
//                               Icons.delete_outline,
//                               color: Colors.red,
//                             ),
//                             onPressed:
//                                 () => setState(
//                                   () => prescriptionItems.removeAt(index),
//                                 ),
//                           ),
//                 ),
//                 const Divider(height: 20),
//                 // ✅ عرض التفاصيل الإضافية للمريض
//                 Wrap(
//                   spacing: 20,
//                   runSpacing: 10,
//                   children: [
//                     _buildDetailItem(Icons.shutter_speed, item.dosage),
//                     _buildDetailItem(Icons.calendar_today, item.duration),
//                     _buildDetailItem(
//                       Icons.repeat,
//                       _getFrequencyName(item.reminderFrequencyType),
//                     ),
//                   ],
//                 ),
//                 if (item.instructions != null &&
//                     item.instructions!.isNotEmpty &&
//                     item.instructions != "No special instructions")
//                   Padding(
//                     padding: const EdgeInsets.only(top: 12),
//                     child: Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: Colors.blue.withOpacity(0.05),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         "💡 Note: ${item.instructions}",
//                         style: const TextStyle(
//                           fontSize: 12,
//                           color: Colors.blueGrey,
//                           fontStyle: FontStyle.italic,
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // ويدجت مساعدة لعرض الأيقونة مع النص
//   Widget _buildDetailItem(IconData icon, String text) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(icon, size: 16, color: Colors.grey),
//         const SizedBox(width: 5),
//         Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87)),
//       ],
//     );
//   }

//   // تحويل رقم الـ Enum لاسم مفهوم للمريض [cite: 25, 27]
//   String _getFrequencyName(int type) {
//     switch (type) {
//       case 0:
//         return "Once";
//       case 1:
//         return "Daily";
//       case 2:
//         return "Weekly";
//       case 3:
//         return "Monthly";
//       case 4:
//         return "Every X Hours";
//       default:
//         return "As prescribed";
//     }
//   }

//   Widget _buildProfileCard() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF9333EA), Color(0xFF7E22CE)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF9333EA).withOpacity(0.3),
//             blurRadius: 15,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 30,
//             backgroundColor: Colors.white.withOpacity(0.2),
//             child: const Icon(Icons.person, size: 35, color: Colors.white),
//           ),
//           const SizedBox(width: 15),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Patient Name",
//                   style: TextStyle(color: Colors.white70, fontSize: 12),
//                 ),
//                 Text(
//                   widget.patientName, // ✅ اسم المريض
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 20,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               widget.initialStatus.toUpperCase(),
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 10,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStartButton() {
//     return Center(
//       child: ElevatedButton.icon(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.green,
//           foregroundColor: Colors.white,
//           minimumSize: const Size(250, 55),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(30),
//           ),
//         ),
//         onPressed:
//             () => context.read<AppointmentActionCubit>().updateStatus(
//               widget.appointmentId,
//               AppointmentAction.start,
//             ),
//         icon: const Icon(Icons.play_arrow_rounded),
//         label: const Text(
//           "Start Session",
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//         ),
//       ),
//     );
//   }

//   void _showFollowUpDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder:
//           (context) => AlertDialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20),
//             ),
//             title: const Text("Session Completed"),
//             content: const Text(
//               "Would you like to schedule a follow-up appointment?",
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   context.pop();
//                 },
//                 child: const Text("No, Home"),
//               ),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF9333EA),
//                 ),
//                 onPressed: () {
//                   Navigator.pop(context);
//                   context.pushReplacement(
//                     AppRouter.kDoctorSchedule,
//                     extra: {
//                       'patientName': widget.patientName,
//                       'originalAppointmentId': widget.appointmentId,
//                     },
//                   );
//                 },
//                 child: const Text(
//                   "Yes, Schedule",
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//             ],
//           ),
//     );
//   }

//   void _showSnackBar(String msg, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(msg),
//         backgroundColor: isError ? Colors.red : Colors.green,
//       ),
//     );
//   }

//   void _showAddMedicationSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
//       ),
//       builder:
//           (context) => AddMedicationSheet(
//             onAdd: (item) => setState(() => prescriptionItems.add(item)),
//           ),
//     );
//   }
// }

// الـ Widget المساعد للـ TextField
// class _CustomTextField extends StatelessWidget {
//   final TextEditingController controller;
//   final String label;
//   final IconData icon;
//   final bool enabled;
//   final int maxLines;
//   const _CustomTextField({
//     required this.controller,
//     required this.label,
//     required this.icon,
//     this.enabled = true,
//     this.maxLines = 1,
//   });
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 15),
//       child: TextField(
//         controller: controller,
//         enabled: enabled,
//         maxLines: maxLines,
//         decoration: InputDecoration(
//           labelText: label,
//           prefixIcon: Icon(
//             icon,
//             color: enabled ? const Color(0xFF9333EA) : Colors.grey,
//             size: 20,
//           ),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15),
//             borderSide: BorderSide(color: Colors.grey[200]!),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15),
//             borderSide: BorderSide(color: Colors.grey[200]!),
//           ),
//           filled: true,
//           fillColor: enabled ? Colors.white : Colors.grey.shade50,
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:go_router/go_router.dart';
// import 'package:graduation_project/core/utils/app_router.dart';
// import 'package:graduation_project/core/utils/functions/pdf_prescription_service.dart';
// import 'package:graduation_project/core/widgets/shimmer_loading.dart';
// import 'package:graduation_project/features/booking/domain/entities/medication_item_entity.dart';
// import 'package:graduation_project/features/booking/domain/entities/prescription_entity.dart';
// import 'package:graduation_project/features/booking/domain/use_cases/update_appointment_status_use_case.dart';
// import 'package:graduation_project/features/booking/presentation/manager/appointment_action_cubit/appointment_action_cubit.dart';
// import 'package:graduation_project/features/booking/presentation/views/add_medication_sheet.dart';
// import '../../../../core/utils/helper/service_locator.dart';
// import '../../../../core/utils/helper/session_manager.dart';
// import '../manager/exam_session_cubit/exam_session_cubit.dart';
// import '../../domain/entities/medical_record_entity.dart';

// class MedicalDetailsView extends StatefulWidget {
//   final String appointmentId;
//   final String patientId;
//   final String patientName;
//   final String? patientImage;
//   final String doctorName;
//   final String? doctorImage;
//   final String doctorSpecialty;
//   final String? patientNote;
//   final String initialStatus;
//   final bool isReadOnly; // ممررة من صفحة الأجندة

//   const MedicalDetailsView({
//     super.key,
//     required this.appointmentId,
//     required this.patientId,
//     required this.patientName,
//     this.patientImage,
//     required this.doctorName,
//     this.doctorImage,
//     required this.doctorSpecialty,
//     this.patientNote,
//     required this.initialStatus,
//     this.isReadOnly = false,
//   });

//   @override
//   State<MedicalDetailsView> createState() => _MedicalDetailsViewState();
// }

// class _MedicalDetailsViewState extends State<MedicalDetailsView> {
//   final chiefComplaintController = TextEditingController();
//   final vitalsController = TextEditingController();
//   final physicalExamController = TextEditingController();
//   final diagnosisController = TextEditingController();
//   final diagnosisCodeController = TextEditingController();
//   final treatmentPlanController = TextEditingController();
//   final doctorNotesController = TextEditingController();
//   final followUpInstructionsController = TextEditingController();

//   bool isStarted = false;
//   bool followUpRequired = false;
//   DateTime? followUpDate;
//   List<MedicationItemEntity> prescriptionItems = [];
//   String? currentPrescriptionId;
//   String? _actualPatientId;

//   // 🧠 Getters لتسهيل الشروط في الكود
//   bool get isPatient =>
//       getIt<SessionManager>().userRole?.toLowerCase() == 'patient';
//   bool get isCompleted => widget.initialStatus.toLowerCase() == 'completed';
//   bool get isCancelled => widget.initialStatus.toLowerCase() == 'cancelled';
//   bool get isPending => widget.initialStatus.toLowerCase() == 'pending';
//   bool get isInProgress => widget.initialStatus.toLowerCase() == 'inprogress';

//   // هل مسموح للدكتور بالتعديل؟
//   bool get canEdit =>
//       !isPatient && !isCancelled && (isInProgress || isCompleted);

//   @override
//   void initState() {
//     super.initState();
//     if (isCompleted || isInProgress) {
//       isStarted = true;
//     }
//     context.read<ExamSessionCubit>().fetchAppointmentDetails(
//       widget.appointmentId,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FD),
//       appBar: AppBar(
//         title: Text(isCompleted ? "Medical Report" : "Appointment Details"),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0.5,
//         actions: [
//           // 🛡️ المريض مش محتاج زرار الهيستوري (لأنه جواه)
//           if (!isPatient)
//             IconButton(
//               icon: const Icon(
//                 Icons.history_edu,
//                 color: Color(0xFF9333EA),
//                 size: 28,
//               ),
//               onPressed:
//                   () => context.push(
//                     AppRouter.kMedicalHistory,
//                     extra: {
//                       'patientId': _actualPatientId ?? widget.patientId,
//                       'appointmentId': widget.appointmentId,
//                       'isDoctorView': true,
//                     },
//                   ),
//             ),
//           if (isCompleted)
//             IconButton(
//               icon: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
//               onPressed:
//                   () => PdfPrescriptionService.generatePrescription(
//                     patientName: widget.patientName,
//                     doctorName: widget.doctorName,
//                     diagnosis: diagnosisController.text,
//                     items: prescriptionItems,
//                   ),
//             ),
//           const SizedBox(width: 10),
//         ],
//       ),
//       body: MultiBlocListener(
//         listeners: [
//           BlocListener<ExamSessionCubit, ExamSessionState>(
//             listener: (context, state) {
//               if (state is AppointmentDetailsFetched) {
//                 final details = state.details;
//                 setState(() => _actualPatientId = details.patientId.toString());
//                 if (details.medicalRecord != null) {
//                   _populateMedicalData(details.medicalRecord!);
//                 }
//                 if (details.prescriptions != null &&
//                     details.prescriptions!.isNotEmpty) {
//                   setState(() {
//                     prescriptionItems = List.from(
//                       details.prescriptions!.first.items,
//                     );
//                     currentPrescriptionId =
//                         details.prescriptions!.first.prescriptionId;
//                   });
//                 }
//               }
//             },
//           ),
//           BlocListener<AppointmentActionCubit, AppointmentActionState>(
//             listener: (context, state) {
//               if (state is AppointmentActionSuccess &&
//                   (state.message.contains("start") || !isStarted)) {
//                 setState(() => isStarted = true);
//               }
//             },
//           ),
//         ],
//         child: BlocBuilder<ExamSessionCubit, ExamSessionState>(
//           builder: (context, state) {
//             if (state is MedicalRecordLoading && !isStarted)
//               return _buildMedicalDetailsShimmer();

//             return SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildProfileCard(),
//                   const SizedBox(height: 15),

//                   // 🔐 التحكم في الأكسس للمريض (يظهر في كل الحالات ماعدا الملغي)
//                   if (isPatient && !isCancelled) _buildAccessControl(),

//                   if (isCancelled) _buildCancelledView(),

//                   if (!isCancelled)
//                     AnimatedSwitcher(
//                       duration: const Duration(milliseconds: 400),
//                       child:
//                           !isStarted
//                               ? _buildPreStartDashboard()
//                               : _buildSessionActiveUI(),
//                     ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   // --- 🎨 UI Sections ---

//   // 1. كارت البروفايل (ذكي)
//   Widget _buildProfileCard() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF9333EA), Color(0xFF7E22CE)],
//         ),
//         borderRadius: BorderRadius.circular(24),
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 30,
//             backgroundColor: Colors.white.withOpacity(0.2),
//             child: const Icon(Icons.person, size: 35, color: Colors.white),
//           ),
//           const SizedBox(width: 15),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   isPatient ? "Doctor Name" : "Patient Name",
//                   style: const TextStyle(color: Colors.white70, fontSize: 12),
//                 ),
//                 Text(
//                   isPatient ? widget.doctorName : widget.patientName,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 18,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Text(
//               widget.initialStatus.toUpperCase(),
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 10,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMedicalDetailsShimmer() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // شيمر للكارد بتاع البروفايل
//           const ShimmerLoading.rectangular(height: 90),
//           const SizedBox(height: 30),

//           // شيمر للعنوان
//           const ShimmerLoading.rectangular(height: 25, width: 150),
//           const SizedBox(height: 20),

//           // شيمر للحقول (هنعمل 4 حقول مثلاً)
//           ...List.generate(
//             4,
//             (index) => Padding(
//               padding: const EdgeInsets.only(bottom: 15),
//               child: const ShimmerLoading.rectangular(height: 55),
//             ),
//           ),

//           const SizedBox(height: 30),
//           // شيمر لقسم الروشتة
//           const ShimmerLoading.rectangular(height: 25, width: 200),
//           const SizedBox(height: 15),
//           const ShimmerLoading.rectangular(height: 100),
//         ],
//       ),
//     );
//   }

//   // 2. زرار الصلاحية للمريض
//   Widget _buildAccessControl() {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(color: const Color(0xFF9333EA).withOpacity(0.1)),
//       ),
//       child: Row(
//         children: [
//           const Icon(
//             Icons.lock_open_outlined,
//             color: Color(0xFF9333EA),
//             size: 20,
//           ),
//           const SizedBox(width: 12),
//           const Expanded(
//             child: Text(
//               "Grant doctor full history access",
//               style: TextStyle(fontSize: 13),
//             ),
//           ),
//           Switch(
//             value: true, // يفضل ربطها بالباك إند
//             onChanged: (val) {},
//             activeColor: const Color(0xFF9333EA),
//           ),
//         ],
//       ),
//     );
//   }

//   // 3. شاشة الانتظار (قبل البدء)
//   Widget _buildPreStartDashboard() {
//     if (isPatient) {
//       return Column(
//         children: [
//           const SizedBox(height: 50),
//           const Icon(
//             Icons.hourglass_top_rounded,
//             size: 80,
//             color: Colors.orange,
//           ),
//           const SizedBox(height: 20),
//           const Text(
//             "Waiting for Doctor",
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           const Text(
//             "The doctor will start the session shortly.",
//             style: TextStyle(color: Colors.grey),
//           ),
//           const SizedBox(height: 30),
//           _buildPatientNoteSection(),
//         ],
//       );
//     }
//     // للدكتور: يظهر زرار البداية وملاحظة المريض
//     return Column(
//       children: [
//         const SizedBox(height: 40),
//         _buildPatientNoteSection(),
//         const SizedBox(height: 40),
//         ElevatedButton.icon(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.green,
//             minimumSize: const Size(250, 55),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(30),
//             ),
//           ),
//           onPressed:
//               () => context.read<AppointmentActionCubit>().updateStatus(
//                 widget.appointmentId,
//                 AppointmentAction.start,
//               ),
//           icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
//           label: const Text(
//             "Start Session",
//             style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//           ),
//         ),
//       ],
//     );
//   }

//   // 4. الجلسة النشطة (الفورمة والروشتة)
//   Widget _buildSessionActiveUI() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (isCompleted) _buildReadOnlyBanner(),
//         const Text(
//           "Clinical Assessment",
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 15),

//         // الحقول تفتح فقط للدكتور وفي جلسة نشطة
//         _buildMedicalRecordForm(enabled: canEdit && !isCompleted),

//         const Divider(height: 50),
//         _buildPrescriptionSection(),

//         // إخفاء الأكشنات للمريض تماماً
//         if (!isPatient) ...[const SizedBox(height: 30), _buildActionButton()],
//       ],
//     );
//   }

//   Widget _buildMedicalRecordForm({required bool enabled}) {
//     return Column(
//       children: [
//         _CustomTextField(
//           controller: chiefComplaintController,
//           label: "Chief Complaint",
//           icon: Icons.sick_outlined,
//           enabled: enabled,
//         ),
//         _CustomTextField(
//           controller: vitalsController,
//           label: "Vital Signs",
//           icon: Icons.monitor_heart_outlined,
//           enabled: enabled,
//         ),
//         _CustomTextField(
//           controller: physicalExamController,
//           label: "Physical Exam",
//           icon: Icons.accessibility_new,
//           enabled: enabled,
//         ),
//         _CustomTextField(
//           controller: diagnosisController,
//           label: "Diagnosis *",
//           icon: Icons.fact_check,
//           enabled: enabled,
//         ),
//         _CustomTextField(
//           controller: treatmentPlanController,
//           label: "Treatment Plan",
//           icon: Icons.event_note,
//           maxLines: 3,
//           enabled: enabled,
//         ),
//       ],
//     );
//   }

//   Widget _buildPrescriptionSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "Prescription",
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 15),
//         _buildPrescriptionItemsList(),

//         // زرار الإضافة يظهر للدكتور فقط
//         if (!isPatient && !isCompleted)
//           Padding(
//             padding: const EdgeInsets.only(top: 15),
//             child: InkWell(
//               onTap: _showAddMedicationSheet,
//               child: _buildAddMedicationButtonUI(),
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildPrescriptionItemsList() {
//     if (prescriptionItems.isEmpty) {
//       return const Center(
//         child: Padding(
//           padding: EdgeInsets.all(20),
//           child: Text("No medicines added"),
//         ),
//       );
//     }

//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: prescriptionItems.length,
//       itemBuilder: (context, index) {
//         final item = prescriptionItems[index];
//         // ✅ السلة هتختفي لو الـ itemId جاي من السيرفر (مش null)
//         bool isSavedOnServer = item.itemId != null;

//         return Card(
//           margin: const EdgeInsets.only(bottom: 12),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15),
//             side: BorderSide(color: Colors.grey.shade200),
//           ),
//           elevation: 0,
//           child: Padding(
//             padding: const EdgeInsets.all(12),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 ListTile(
//                   contentPadding: EdgeInsets.zero,
//                   leading: CircleAvatar(
//                     backgroundColor: const Color(0xFFF3E8FF),
//                     child: Icon(
//                       Icons.medication,
//                       color: const Color(0xFF9333EA),
//                     ),
//                   ),
//                   title: Text(
//                     item.medicationName,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//                   subtitle: Text(
//                     "Quantity: ${item.quantity} units",
//                   ), // ✅ إضافة الكمية [cite: 50]
//                   trailing:
//                       (isCompleted && isSavedOnServer)
//                           ? null // ✅ إخفاء السلة للأدوية المسجلة في المواعيد المنتهية
//                           : IconButton(
//                             icon: const Icon(
//                               Icons.delete_outline,
//                               color: Colors.red,
//                             ),
//                             onPressed:
//                                 () => setState(
//                                   () => prescriptionItems.removeAt(index),
//                                 ),
//                           ),
//                 ),
//                 const Divider(height: 20),
//                 // ✅ عرض التفاصيل الإضافية للمريض
//                 Wrap(
//                   spacing: 20,
//                   runSpacing: 10,
//                   children: [
//                     _buildDetailItem(Icons.shutter_speed, item.dosage),
//                     _buildDetailItem(Icons.calendar_today, item.duration),
//                     _buildDetailItem(
//                       Icons.repeat,
//                       _getFrequencyName(item.reminderFrequencyType),
//                     ),
//                   ],
//                 ),
//                 if (item.instructions != null &&
//                     item.instructions!.isNotEmpty &&
//                     item.instructions != "No special instructions")
//                   Padding(
//                     padding: const EdgeInsets.only(top: 12),
//                     child: Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: Colors.blue.withOpacity(0.05),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         "💡 Note: ${item.instructions}",
//                         style: const TextStyle(
//                           fontSize: 12,
//                           color: Colors.blueGrey,
//                           fontStyle: FontStyle.italic,
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // ويدجت مساعدة لعرض الأيقونة مع النص
//   Widget _buildDetailItem(IconData icon, String text) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(icon, size: 16, color: Colors.grey),
//         const SizedBox(width: 5),
//         Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87)),
//       ],
//     );
//   }

//   // تحويل رقم الـ Enum لاسم مفهوم للمريض [cite: 25, 27]
//   String _getFrequencyName(int type) {
//     switch (type) {
//       case 0:
//         return "Once";
//       case 1:
//         return "Daily";
//       case 2:
//         return "Weekly";
//       case 3:
//         return "Monthly";
//       case 4:
//         return "Every X Hours";
//       default:
//         return "As prescribed";
//     }
//   }

//   Widget _buildActionButton() {
//     return BlocBuilder<AppointmentActionCubit, AppointmentActionState>(
//       builder: (context, state) {
//         bool isLoading = state is AppointmentActionLoading;
//         return ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             backgroundColor:
//                 isCompleted ? Colors.blue : const Color(0xFF9333EA),
//             minimumSize: const Size(double.infinity, 55),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(15),
//             ),
//           ),
//           onPressed: isLoading ? null : _handleFinishSession,
//           child:
//               isLoading
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : Text(
//                     isCompleted ? "Update Assessment" : "Finish Session",
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//         );
//       },
//     );
//   }

//   Widget _buildCancelledView() {
//     return Center(
//       child: Column(
//         children: [
//           SizedBox(height: 60.h),
//           Icon(
//             Icons.event_busy_rounded,
//             size: 100.sp,
//             color: Colors.red.shade200,
//           ),
//           const SizedBox(height: 20),
//           const Text(
//             "Appointment Cancelled",
//             style: TextStyle(
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//               color: Colors.red,
//             ),
//           ),
//           const Padding(
//             padding: EdgeInsets.all(20),
//             child: Text(
//               "This session was cancelled and no medical records were created.",
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.grey),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _handleFinishSession() async {
//     // التحقق من البيانات فقط في الجلسة الجديدة
//     if (!isCompleted) {
//       if (diagnosisController.text.trim().isEmpty ||
//           prescriptionItems.isEmpty) {
//         _showSnackBar(
//           "Diagnosis and at least one medication are required",
//           isError: true,
//         );
//         return;
//       }
//     }

//     // حفظ البيانات (ريكورد + روشتة)
//     await _onCompletePressed();

//     if (!isCompleted) {
//       final sessionState = context.read<ExamSessionCubit>().state;
//       if (sessionState is! ExamSessionFailure) {
//         // تحديث حالة الموعد لـ Complete في السيرفر
//         await context.read<AppointmentActionCubit>().updateStatus(
//           widget.appointmentId,
//           AppointmentAction.complete,
//         );
//         _showFollowUpDialog();
//       }
//     }
//   }

//   void _showFollowUpDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder:
//           (context) => AlertDialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20),
//             ),
//             title: const Text("Session Completed"),
//             content: const Text(
//               "Would you like to schedule a follow-up appointment?",
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   context.pop();
//                 },
//                 child: const Text("No, Home"),
//               ),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF9333EA),
//                 ),
//                 onPressed: () {
//                   Navigator.pop(context);
//                   context.pushReplacement(
//                     AppRouter.kDoctorSchedule,
//                     extra: {
//                       'patientName': widget.patientName,
//                       'originalAppointmentId': widget.appointmentId,
//                     },
//                   );
//                 },
//                 child: const Text(
//                   "Yes, Schedule",
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//             ],
//           ),
//     );
//   }

//   Future<void> _onCompletePressed() async {
//     // 1. تجهيز الريكورد (للعلم فقط لو مش Completed)
//     final record = MedicalRecordEntity(
//       chiefComplaint: chiefComplaintController.text,
//       vitalSigns: vitalsController.text,
//       physicalExamination: physicalExamController.text,
//       diagnosis: diagnosisController.text,
//       diagnosisCode: diagnosisCodeController.text,
//       treatmentPlan: treatmentPlanController.text,
//       doctorNotes: doctorNotesController.text,
//       followUpRequired: followUpRequired,
//       followUpDate: followUpDate,
//       followUpInstructions:
//           followUpInstructionsController.text.isEmpty
//               ? "None"
//               : followUpInstructionsController.text,
//     );

//     // 2. لو الجلسة لسه شغالة (InProgress)
//     if (!isCompleted) {
//       final isUpdate =
//           context.read<ExamSessionCubit>().state is MedicalRecordFetched;
//       await context.read<ExamSessionCubit>().saveMedicalRecord(
//         appointmentId: widget.appointmentId,
//         record: record,
//         isUpdate: isUpdate,
//       );

//       final prescription = PrescriptionEntity(
//         validUntil: DateTime.now().add(const Duration(days: 30)),
//         items: prescriptionItems,
//       );
//       await context.read<ExamSessionCubit>().createPrescription(
//         appointmentId: widget.appointmentId,
//         prescription: prescription,
//       );
//     }
//     // 3. ✅ لو الجلسة منتهية (Completed) - سيناريو تحديث الأدوية
//     else {
//       final newItems =
//           prescriptionItems.where((item) => item.itemId == null).map((item) {
//             if (item.reminderFrequencyType == 0) {
//               return item.copyWith(
//                 duration: "1 day",
//                 reminderEndDate: null, // ✅ تأكيد إرسال null للـ Once
//                 reminderWeeklyDays: null, // ✅ تأكيد إرسال null
//                 reminderFirstDoseTime: null,
//                 frequency: "Once",
//               );
//             }
//             return item;
//           }).toList();
//       if (newItems.isNotEmpty && currentPrescriptionId != null) {
//         await context.read<ExamSessionCubit>().addPrescriptionItems(
//           prescriptionId: currentPrescriptionId!,
//           items: newItems,
//         );
//       }
//     }
//   }

//   // --- 🛠️ Helpers ---

//   Widget _buildReadOnlyBanner() {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       margin: const EdgeInsets.only(bottom: 20),
//       decoration: BoxDecoration(
//         color: Colors.blue.shade50,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.blue.shade200),
//       ),
//       child: const Row(
//         children: [
//           Icon(Icons.info_outline, color: Colors.blue),
//           SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               "This report is finalized. Changes are restricted.",
//               style: TextStyle(
//                 color: Colors.blue,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 12,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAddMedicationButtonUI() {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 14),
//       decoration: BoxDecoration(
//         color: const Color(0xFF9333EA).withOpacity(0.05),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFF9333EA).withOpacity(0.2)),
//       ),
//       child: const Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.add_circle_outline, color: Color(0xFF9333EA)),
//           SizedBox(width: 8),
//           Text(
//             "Add Medication",
//             style: TextStyle(
//               color: Color(0xFF9333EA),
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _populateMedicalData(MedicalRecordEntity record) {
//     setState(() {
//       chiefComplaintController.text = record.chiefComplaint;
//       vitalsController.text = record.vitalSigns;
//       physicalExamController.text = record.physicalExamination;
//       diagnosisController.text = record.diagnosis;
//       treatmentPlanController.text = record.treatmentPlan;
//       isStarted = true;
//     });
//   }

//   // ... (نفس الميثودز القديمة للـ Prescription Items و الـ SnackBar) ...

//   Widget _buildPatientNoteSection() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.orange.shade200),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Icons.psychology_alt,
//                 color: Colors.orange.shade700,
//                 size: 20,
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 "Reason for Visit (Patient's Note)",
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.orange.shade900,
//                   fontSize: 14,
//                 ),
//               ),
//             ],
//           ),
//           const Divider(height: 20),
//           Text(
//             // ✅ هنا الملاحظة اللي المريض كتبها وقت الحجز
//             (widget.patientNote != null && widget.patientNote!.isNotEmpty)
//                 ? widget.patientNote!
//                 : "No specific reason provided by the patient.",
//             style: const TextStyle(
//               fontSize: 15,
//               color: Color(0xFF334155),
//               height: 1.5,
//               fontStyle: FontStyle.italic,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showSnackBar(String msg, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(msg),
//         backgroundColor: isError ? Colors.red : Colors.green,
//       ),
//     );
//   }

//   void _showAddMedicationSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
//       ),
//       builder:
//           (context) => AddMedicationSheet(
//             onAdd: (item) => setState(() => prescriptionItems.add(item)),
//           ),
//     );
//   }
// }

// // الـ Widget المساعد للـ TextField
// class _CustomTextField extends StatelessWidget {
//   final TextEditingController controller;
//   final String label;
//   final IconData icon;
//   final bool enabled;
//   final int maxLines;
//   const _CustomTextField({
//     required this.controller,
//     required this.label,
//     required this.icon,
//     this.enabled = true,
//     this.maxLines = 1,
//   });
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 15),
//       child: TextField(
//         controller: controller,
//         enabled: enabled,
//         maxLines: maxLines,
//         decoration: InputDecoration(
//           labelText: label,
//           prefixIcon: Icon(
//             icon,
//             color: enabled ? const Color(0xFF9333EA) : Colors.grey,
//             size: 20,
//           ),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15),
//             borderSide: BorderSide(color: Colors.grey[200]!),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15),
//             borderSide: BorderSide(color: Colors.grey[200]!),
//           ),
//           filled: true,
//           fillColor: enabled ? Colors.white : Colors.grey.shade50,
//         ),
//       ),
//     );
//   }
// }

// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:go_router/go_router.dart';
// import 'package:graduation_project/core/utils/app_router.dart';
// import 'package:graduation_project/core/utils/functions/pdf_prescription_service.dart';
// import 'package:graduation_project/core/widgets/shimmer_loading.dart';
// import 'package:graduation_project/features/booking/domain/entities/medication_item_entity.dart';
// import 'package:graduation_project/features/booking/domain/entities/prescription_entity.dart';
// import 'package:graduation_project/features/booking/domain/use_cases/update_appointment_status_use_case.dart';
// import 'package:graduation_project/features/booking/presentation/manager/appointment_action_cubit/appointment_action_cubit.dart';
// import 'package:graduation_project/features/booking/presentation/views/add_medication_sheet.dart';
// import '../../../../core/utils/helper/service_locator.dart';
// import '../../../../core/utils/helper/session_manager.dart';
// import '../manager/exam_session_cubit/exam_session_cubit.dart';
// import '../../domain/entities/medical_record_entity.dart';

// class MedicalDetailsView extends StatefulWidget {
//   final String appointmentId;
//   final String? patientId;
//   final String patientName;
//   final String? patientImage;
//   final String doctorName;
//   final String? doctorImage;
//   final String doctorSpecialty;
//   final String? patientNote;
//   final String initialStatus;
//   final bool isReadOnly; // ممررة من صفحة الأجندة

//   const MedicalDetailsView({
//     super.key,
//     required this.appointmentId,
//     required this.patientId,
//     required this.patientName,
//     this.patientImage,
//     required this.doctorName,
//     this.doctorImage,
//     required this.doctorSpecialty,
//     this.patientNote,
//     required this.initialStatus,
//     this.isReadOnly = false,
//   });

//   @override
//   State<MedicalDetailsView> createState() => _MedicalDetailsViewState();
// }

// class _MedicalDetailsViewState extends State<MedicalDetailsView> {
//   // 1. Controllers لكل حقول السجل الطبي
//   final chiefComplaintController = TextEditingController();
//   final vitalsController = TextEditingController();
//   final physicalExamController = TextEditingController();
//   final diagnosisController = TextEditingController();
//   final diagnosisCodeController = TextEditingController();
//   final treatmentPlanController = TextEditingController();
//   final doctorNotesController = TextEditingController();
//   final followUpInstructionsController = TextEditingController();

//   bool isStarted = false;
//   bool followUpRequired = false;
//   DateTime? followUpDate;
//   List<MedicationItemEntity> prescriptionItems = [];
//   String? currentPrescriptionId;
//   String? _actualPatientId;
//   bool isAccessGranted = false; // هنحدثها لما الداتا تيجي

//   // 🧠 Getters لتسهيل الشروط في الكود بناءً على الـ Role والحالة
//   bool get isPatient =>
//       getIt<SessionManager>().userRole?.toLowerCase() == 'patient';
//   bool get isCompleted => widget.initialStatus.toLowerCase() == 'completed';
//   bool get isCancelled => widget.initialStatus.toLowerCase() == 'cancelled';
//   bool get isPending => widget.initialStatus.toLowerCase() == 'pending';
//   bool get isInProgress => widget.initialStatus.toLowerCase() == 'inprogress';

//   // ✅ للدكتور فقط، وفقط في الـ InProgress أو لو ببيعدل روشتة مخلصة
//   // bool get canEdit =>
//   //     !isPatient && !isCancelled && (isInProgress || isCompleted);

//   // جوه الـ State
//   bool get canEditRecord =>
//       !isPatient && isInProgress; // ريكورد: فقط لو الجلسة شغالة
//   bool get canEditMeds =>
//       !isPatient && (isInProgress || isCompleted); // أدوية: شغالة أو خلصت

//   @override
//   void initState() {
//     super.initState();
//     // لو الموعد منتهي أو قيد التنفيذ، نفتح الفورمة فوراً
//     if (isCompleted || isInProgress) {
//       isStarted = true;
//     }

//     // جلب البيانات المسجلة مسبقاً
//     final cubit = context.read<ExamSessionCubit>();
//     cubit.fetchAppointmentDetails(widget.appointmentId);
//   }

//   @override
//   Widget build(BuildContext context) {
//     log(
//       'doctorName: ${widget.doctorName}, patientName: ${widget.patientName}, initialStatus: ${widget.initialStatus}',
//     );
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FD),
//       appBar: AppBar(
//         title: Text(isCompleted ? "Medical Report" : "Appointment Details"),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0.5,
//         actions: [
//           // 🛡️ المريض مش محتاج زرار الهيستوري (لأنه جواه)
//           if (!isPatient)
//             IconButton(
//               icon: const Icon(
//                 Icons.history_edu,
//                 color: Color(0xFF9333EA),
//                 size: 28,
//               ),
//               tooltip: "View Medical History",
//               onPressed: () {
//                 // الانتقال لصفحة الهيستوري مع تمرير ID المريض وعلم الـ DoctorView
//                 context.push(
//                   AppRouter.kMedicalHistory,
//                   extra: {
//                     'patientId':
//                         _actualPatientId ??
//                         widget.patientId, // تأكد إنك استلمته من الكالندر
//                     'appointmentId': widget.appointmentId,
//                     'isDoctorView': true,
//                   },
//                 );
//               },
//             ),
//           if (isCompleted) // PDF PRESCRIPTION يظهر للكل في الـ Completed
//             IconButton(
//               icon: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
//               onPressed: () {
//                 PdfPrescriptionService.generatePrescription(
//                   patientName: widget.patientName,
//                   doctorName: widget.doctorName,
//                   diagnosis: diagnosisController.text,
//                   items: prescriptionItems,
//                 );
//               },
//             ),
//           const SizedBox(width: 10),
//         ],
//       ),
//       body: MultiBlocListener(
//         listeners: [
//           // مراقب جلب البيانات
//           BlocListener<ExamSessionCubit, ExamSessionState>(
//             listener: (context, state) {
//               if (state is AppointmentDetailsFetched) {
//                 final details = state.details;
//                 setState(() {
//                   _actualPatientId =
//                       details.patientId
//                           .toString(); // ✅ سجل الـ ID اللي جه من السيرفر
//                   // isAccessGranted = state.details.grantMedicalHistoryAccess ?? false;
//                   isAccessGranted = false;
//                 });
//                 // 1. ملء بيانات السجل الطبي لو موجودة
//                 if (details.medicalRecord != null) {
//                   _populateMedicalData(details.medicalRecord!);
//                   setState(
//                     () => isStarted = true,
//                   ); // لو فيه ريكورد يبقى بدأت فعلاً
//                 }

//                 // 2. ملء الروشتات (بناخد أول روشتة)
//                 if (details.prescriptions != null &&
//                     details.prescriptions!.isNotEmpty) {
//                   setState(() {
//                     prescriptionItems = List.from(
//                       details.prescriptions!.first.items,
//                     );
//                     currentPrescriptionId =
//                         details.prescriptions!.first.prescriptionId;
//                   });
//                 }
//               } else if (state is PrescriptionCreatedSuccess) {
//                 // ✅ نحدث البيانات من السيرفر فوراً عشان الـ IDs تنزل والسلة تختفي
//                 context.read<ExamSessionCubit>().fetchPrescription(
//                   widget.appointmentId,
//                 );
//                 _showSnackBar(state.message, isError: false);
//               } else if (state is ExamSessionFailure) {
//                 _showSnackBar(state.errMessage, isError: true);
//               }
//             },
//           ),
//           // مراقب الأكشن (Start/Complete)
//           BlocListener<AppointmentActionCubit, AppointmentActionState>(
//             listener: (context, state) {
//               if (state is AppointmentActionSuccess) {
//                 if (state.message.toLowerCase().contains("start") ||
//                     !isStarted) {
//                   setState(() => isStarted = true);
//                 }
//               } else if (state is AppointmentActionFailure) {
//                 _showSnackBar(state.errMessage, isError: true);
//               }
//             },
//           ),
//         ],
//         child: BlocBuilder<ExamSessionCubit, ExamSessionState>(
//           builder: (context, state) {
//             if (state is MedicalRecordLoading && !isStarted) {
//               return _buildMedicalDetailsShimmer();
//             }

//             return SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildProfileCard(),
//                   const SizedBox(height: 15),

//                   // 🔐 التحكم في الأكسس للمريض (يظهر في كل الحالات ماعدا الملغي)
//                   if (isPatient && !isCancelled) _buildAccessControl(),

//                   if (isCancelled) _buildCancelledView(),

//                   if (!isCancelled)
//                     AnimatedSwitcher(
//                       duration: const Duration(milliseconds: 500),
//                       // التبديل بين شاشة الانتظار وشاشة الجلسة النشطة
//                       child:
//                           !isStarted
//                               ? _buildPreStartDashboard()
//                               : _buildSessionActiveUI(),
//                     ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   void _populateMedicalData(MedicalRecordEntity record) {
//     setState(() {
//       chiefComplaintController.text = record.chiefComplaint;
//       vitalsController.text = record.vitalSigns;
//       physicalExamController.text = record.physicalExamination;
//       diagnosisController.text = record.diagnosis;
//       diagnosisCodeController.text = record.diagnosisCode;
//       treatmentPlanController.text = record.treatmentPlan;
//       doctorNotesController.text = record.doctorNotes;
//       isStarted = true;
//     });
//   }

//   // --- 🎨 UI Sections ---

//   // 1. كارت البروفايل (ذكي - يعرف مين اللي بيبص عشان يظهر اسم مين)
//   Widget _buildProfileCard() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF9333EA), Color(0xFF7E22CE)],
//         ),
//         borderRadius: BorderRadius.circular(24),
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 30,
//             backgroundColor: Colors.white.withOpacity(0.2),
//             child: const Icon(Icons.person, size: 35, color: Colors.white),
//           ),
//           const SizedBox(width: 15),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   // 🧠 للدكتور بيظهر Patient Name، وللمريض بيظهر Doctor Name (طلب 1)
//                   isPatient ? "Doctor Name" : "Patient Name",
//                   style: const TextStyle(color: Colors.white70, fontSize: 12),
//                 ),
//                 Text(
//                   // 🧠 بنغير الاسم اللي بيتعرض بناءً على مين اللي بيبص (طلب 1)
//                   // للدكتور بيظهر اسم المريض، وللمريض بيظهر اسم الدكتور
//                   isPatient ? widget.doctorName : widget.patientName,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 20,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Text(
//               widget.initialStatus.toUpperCase(),
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 10,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // 2. زرار الصلاحية للمريض (Grant Access)
//   Widget _buildAccessControl() {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(color: const Color(0xFF9333EA).withOpacity(0.1)),
//       ),
//       child: Row(
//         children: [
//           const Icon(
//             Icons.lock_open_outlined,
//             color: Color(0xFF9333EA),
//             size: 20,
//           ),
//           const SizedBox(width: 12),
//           const Expanded(
//             child: Text(
//               "Grant doctor full history access",
//               style: TextStyle(fontSize: 13),
//             ),
//           ),
//           BlocBuilder<ExamSessionCubit, ExamSessionState>(
//             builder: (context, state) {
//               bool isLoading = state is MedicalRecordLoading;
//               return Switch(
//                 value:
//                     isAccessGranted, // المفروض تربطها بمتغير في الـ Cubit (grantAccess)
//                 onChanged: (val) {
//                   // setState(() => isAccessGranted = val);
//                   if (val && !isAccessGranted && !isLoading) {
//                     context.read<ExamSessionCubit>().grantMedicalAccess(
//                       widget.appointmentId,
//                     );
//                     setState(() => isAccessGranted = true); // تفعيل لحظي للـ UI
//                   }
//                   // نداء الكيوبت لتحديث الصلاحية
//                 },
//                 activeColor: const Color(0xFF9333EA),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   // 3. شاشة ما قبل بدء الجلسة (وضع الانتظار للمريض)
//   Widget _buildPreStartDashboard() {
//     if (isPatient) {
//       // 🏠 شكل المريض وهو مستني الدكتور يبدأ (الطلب القديم بالصورة 7c287f)
//       return Column(
//         children: [
//           const SizedBox(height: 50),
//           const Icon(
//             Icons.hourglass_empty_rounded,
//             size: 80,
//             color: Colors.orange,
//           ),
//           const SizedBox(height: 20),
//           const Text(
//             "Waiting for Doctor",
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           const Text(
//             "The doctor will start the session shortly.",
//             style: TextStyle(color: Colors.grey),
//           ),
//           const SizedBox(height: 30),
//           _buildPatientNoteSection(), // المريض يشوف ملاحظته اللي كتبها وقت الحجز
//         ],
//       );
//     }
//     // للدكتور: يظهر زرار البداية وملاحظة المريض
//     return Column(
//       key: const ValueKey("preStart"),
//       children: [
//         const SizedBox(height: 40),
//         Center(
//           child: Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.blue.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.medical_services_outlined,
//               size: 80,
//               color: Colors.blue,
//             ),
//           ),
//         ),
//         const SizedBox(height: 20),
//         const Text(
//           "Ready to start the session?",
//           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//         const Text(
//           "Review patient notes before you begin.",
//           style: TextStyle(color: Colors.grey),
//         ),
//         const SizedBox(height: 30),
//         _buildPatientNoteSection(),
//         const SizedBox(height: 40),
//         Center(
//           child: ElevatedButton.icon(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.green,
//               foregroundColor: Colors.white,
//               minimumSize: const Size(250, 55),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(30),
//               ),
//             ),
//             onPressed:
//                 () => context.read<AppointmentActionCubit>().updateStatus(
//                   widget.appointmentId,
//                   AppointmentAction.start,
//                 ),
//             icon: const Icon(Icons.play_arrow_rounded),
//             label: const Text(
//               "Start Session",
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // 4. الجلسة النشطة (الفورمة والروشتة مقفولة للمريض)
//   Widget _buildSessionActiveUI() {
//     return Column(
//       key: const ValueKey("activeSession"),
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (isCompleted) _buildReadOnlyBanner(),
//         const Text(
//           "Clinical Assessment",
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 15),
//         _buildMedicalRecordForm(),
//         const Divider(height: 50, thickness: 1),
//         _buildPrescriptionSection(),
//         const SizedBox(height: 40),
//         if (!isPatient) _buildActionButton(), // ✅ إخفاء زرار الحفظ للمريض
//       ],
//     );
//   }

//   Widget _buildPatientNoteSection() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.orange.shade200),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Icons.psychology_alt,
//                 color: Colors.orange.shade700,
//                 size: 20,
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 "Reason for Visit (Patient's Note)",
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.orange.shade900,
//                   fontSize: 14,
//                 ),
//               ),
//             ],
//           ),
//           const Divider(height: 20),
//           Text(
//             (widget.patientNote != null && widget.patientNote!.isNotEmpty)
//                 ? widget.patientNote!
//                 : "No specific reason provided by the patient.",
//             style: const TextStyle(
//               fontSize: 15,
//               color: Color(0xFF334155),
//               height: 1.5,
//               fontStyle: FontStyle.italic,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildReadOnlyBanner() {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       margin: const EdgeInsets.only(bottom: 20),
//       decoration: BoxDecoration(
//         color: Colors.blue.shade50,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.blue.shade200),
//       ),
//       child: const Row(
//         children: [
//           Icon(Icons.lock_outline, color: Colors.blue),
//           SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               "This session is completed. Medical records are finalized.",
//               style: TextStyle(
//                 color: Colors.blue,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 12,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMedicalRecordForm() {
//     // للدكتور: enabled لوisInProgress أو isCompleted (الدكتور بيعدل على Completed من الريكوست اللي تحت)
//     // للمريض: dايماً false (Read-only)
//     final bool fieldsEnabled = canEditRecord;

//     return Column(
//       children: [
//         _CustomTextField(
//           controller: chiefComplaintController,
//           label: "Chief Complaint",
//           icon: Icons.sick_outlined,
//           enabled: fieldsEnabled,
//         ),
//         _CustomTextField(
//           controller: vitalsController,
//           label: "Vital Signs",
//           icon: Icons.monitor_heart_outlined,
//           enabled: fieldsEnabled,
//         ),
//         _CustomTextField(
//           controller: physicalExamController,
//           label: "Physical Examination",
//           icon: Icons.accessibility_new_outlined,
//           enabled: fieldsEnabled,
//         ),
//         _CustomTextField(
//           controller: diagnosisController,
//           label: "Final Diagnosis *",
//           icon: Icons.fact_check_outlined,
//           enabled: fieldsEnabled,
//         ),
//         _CustomTextField(
//           controller: treatmentPlanController,
//           label: "Treatment Plan",
//           icon: Icons.event_note_outlined,
//           maxLines: 3,
//           enabled: fieldsEnabled,
//         ),
//       ],
//     );
//   }

//   Widget _buildPrescriptionSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "Medication Prescription",
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 15),
//         _buildPrescriptionItemsList(),
//         const SizedBox(height: 15),
//         // ✅ إخفاء زرار الإضافة للمريض تماماً
//         // if (!isPatient && !isCancelled)
//         if (!isPatient && (isInProgress || isCompleted))
//           InkWell(
//             onTap: _showAddMedicationSheet,
//             child: Container(
//               padding: const EdgeInsets.symmetric(vertical: 14),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF9333EA).withOpacity(0.05),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: const Color(0xFF9333EA).withOpacity(0.2),
//                 ),
//               ),
//               child: const Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.add_circle_outline, color: Color(0xFF9333EA)),
//                   SizedBox(width: 8),
//                   Text(
//                     "Add Medication",
//                     style: TextStyle(
//                       color: Color(0xFF9333EA),
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildActionButton() {
//     // الزرار ده مخفي من المريض في الـ builds_session_active_ui
//     return BlocBuilder<AppointmentActionCubit, AppointmentActionState>(
//       builder: (context, state) {
//         bool isLoading = state is AppointmentActionLoading;
//         return ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             backgroundColor:
//                 isCompleted ? Colors.blue : const Color(0xFF9333EA),
//             minimumSize: const Size(double.infinity, 55),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(15),
//             ),
//           ),
//           onPressed: isLoading ? null : _handleFinishSession,
//           child:
//               isLoading
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : Text(
//                     isCompleted
//                         ? "Update Assessment"
//                         : "Finish & Complete Session",
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//         );
//       },
//     );
//   }

//   Widget _buildCancelledView() {
//     return Center(
//       child: Column(
//         children: [
//           SizedBox(height: 60.h),
//           Icon(
//             Icons.event_busy_rounded,
//             size: 100.sp,
//             color: Colors.red.shade200,
//           ),
//           const SizedBox(height: 20),
//           const Text(
//             "Appointment Cancelled",
//             style: TextStyle(
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//               color: Colors.red,
//             ),
//           ),
//           const Padding(
//             padding: EdgeInsets.all(20),
//             child: Text(
//               "This session was cancelled and no medical records were created.",
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.grey),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // --- ⚙️ Logic Methods ---

//   void _handleFinishSession() async {
//     if (!isCompleted) {
//       if (diagnosisController.text.trim().isEmpty ||
//           prescriptionItems.isEmpty) {
//         _showSnackBar(
//           "Diagnosis and at least one medication are required",
//           isError: true,
//         );
//         return;
//       }
//     }

//     await _onCompletePressed();

//     if (!isCompleted) {
//       final sessionState = context.read<ExamSessionCubit>().state;
//       if (sessionState is! ExamSessionFailure) {
//         await context.read<AppointmentActionCubit>().updateStatus(
//           widget.appointmentId,
//           AppointmentAction.complete,
//         );
//         _showFollowUpDialog();
//       }
//     }
//   }

//   // Future<void> _onCompletePressed() async {
//   //   final record = MedicalRecordEntity(
//   //     chiefComplaint: chiefComplaintController.text,
//   //     vitalSigns: vitalsController.text,
//   //     physicalExamination: physicalExamController.text,
//   //     diagnosis: diagnosisController.text,
//   //     treatmentPlan: treatmentPlanController.text,
//   //     doctorNotes: doctorNotesController.text,
//   //     followUpRequired: followUpRequired,
//   //     followUpDate: followUpDate,
//   //   );

//   //   if (!isCompleted) {
//   //     final isUpdate =
//   //         context.read<ExamSessionCubit>().state is MedicalRecordFetched;
//   //     await context.read<ExamSessionCubit>().saveMedicalRecord(
//   //       appointmentId: widget.appointmentId,
//   //       record: record,
//   //       isUpdate: isUpdate,
//   //     );

//   //     final prescription = PrescriptionEntity(
//   //       validUntil: DateTime.now().add(const Duration(days: 30)),
//   //       items: prescriptionItems,
//   //     );
//   //     await context.read<ExamSessionCubit>().createPrescription(
//   //       appointmentId: widget.appointmentId,
//   //       prescription: prescription,
//   //     );
//   //   } else {
//   //     final newItems =
//   //         prescriptionItems.where((item) => item.itemId == null).toList();
//   //     if (newItems.isNotEmpty && currentPrescriptionId != null) {
//   //       await context.read<ExamSessionCubit>().addPrescriptionItems(
//   //         prescriptionId: currentPrescriptionId!,
//   //         items: newItems,
//   //       );
//   //     }
//   //   }
//   // }
//   Future<void> _onCompletePressed() async {
//     // 1. تجهيز الريكورد (للعلم فقط لو مش Completed)
//     final record = MedicalRecordEntity(
//       chiefComplaint: chiefComplaintController.text,
//       vitalSigns: vitalsController.text,
//       physicalExamination: physicalExamController.text,
//       diagnosis: diagnosisController.text,
//       diagnosisCode: diagnosisCodeController.text,
//       treatmentPlan: treatmentPlanController.text,
//       doctorNotes: doctorNotesController.text,
//       followUpRequired: followUpRequired,
//       followUpDate: followUpDate,
//       followUpInstructions:
//           followUpInstructionsController.text.isEmpty
//               ? "None"
//               : followUpInstructionsController.text,
//     );

//     // 2. لو الجلسة لسه شغالة (InProgress)
//     if (!isCompleted) {
//       final isUpdate =
//           context.read<ExamSessionCubit>().state is MedicalRecordFetched;
//       await context.read<ExamSessionCubit>().saveMedicalRecord(
//         appointmentId: widget.appointmentId,
//         record: record,
//         isUpdate: isUpdate,
//       );

//       final prescription = PrescriptionEntity(
//         validUntil: DateTime.now().add(const Duration(days: 30)),
//         items: prescriptionItems,
//       );
//       await context.read<ExamSessionCubit>().createPrescription(
//         appointmentId: widget.appointmentId,
//         prescription: prescription,
//       );
//     }
//     // 3. ✅ لو الجلسة منتهية (Completed) - سيناريو تحديث الأدوية
//     else {
//       final newItems =
//           prescriptionItems.where((item) => item.itemId == null).map((item) {
//             if (item.reminderFrequencyType == 0) {
//               return item.copyWith(
//                 duration: "1 day",
//                 reminderEndDate: null, // ✅ تأكيد إرسال null للـ Once
//                 reminderWeeklyDays: null, // ✅ تأكيد إرسال null
//                 reminderFirstDoseTime: null,
//                 frequency: "Once",
//               );
//             }
//             return item;
//           }).toList();
//       if (newItems.isNotEmpty && currentPrescriptionId != null) {
//         await context.read<ExamSessionCubit>().addPrescriptionItems(
//           prescriptionId: currentPrescriptionId!,
//           items: newItems,
//         );
//       }
//     }
//   }

//   // --- 🛠️ Helper Methods ---

//   Widget _buildMedicalDetailsShimmer() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const ShimmerLoading.rectangular(height: 90),
//           const SizedBox(height: 30),
//           const ShimmerLoading.rectangular(height: 25, width: 150),
//           const SizedBox(height: 20),
//           ...List.generate(
//             4,
//             (index) => Padding(
//               padding: const EdgeInsets.only(bottom: 15),
//               child: const ShimmerLoading.rectangular(height: 55),
//             ),
//           ),
//           const SizedBox(height: 30),
//           const ShimmerLoading.rectangular(height: 25, width: 200),
//           const SizedBox(height: 15),
//           const ShimmerLoading.rectangular(height: 100),
//         ],
//       ),
//     );
//   }

//   // Widget _buildPrescriptionItemsList() {
//   //   if (prescriptionItems.isEmpty) {
//   //     return const Center(
//   //       child: Padding(
//   //         padding: EdgeInsets.all(20),
//   //         child: Text("No medicines added"),
//   //       ),
//   //     );
//   //   }

//   //   return ListView.builder(
//   //     shrinkWrap: true,
//   //     physics: const NeverScrollableScrollPhysics(),
//   //     itemCount: prescriptionItems.length,
//   //     itemBuilder: (context, index) {
//   //       final item = prescriptionItems[index];
//   //       bool isSavedOnServer = item.itemId != null;

//   //       // Conditions to hide the delete icon:
//   //       // 1. Viewer is a patient (fixed issue in In-Progress - طلب 2).
//   //       // 2. Doctor views, appointment is completed, and medication is already saved on server.
//   //       final bool hideDeleteIcon =
//   //           isPatient || (isCompleted && isSavedOnServer);

//   //       return Card(
//   //         margin: const EdgeInsets.only(bottom: 12),
//   //         shape: RoundedRectangleBorder(
//   //           borderRadius: BorderRadius.circular(15),
//   //           side: BorderSide(color: Colors.grey.shade200),
//   //         ),
//   //         elevation: 0,
//   //         child: Padding(
//   //           padding: const EdgeInsets.all(12),
//   //           child: ListTile(
//   //             contentPadding: EdgeInsets.zero,
//   //             leading: CircleAvatar(
//   //               backgroundColor: const Color(0xFFF3E8FF),
//   //               child: Icon(Icons.medication, color: const Color(0xFF9333EA)),
//   //             ),
//   //             title: Text(
//   //               item.medicationName,
//   //               style: const TextStyle(
//   //                 fontWeight: FontWeight.bold,
//   //                 fontSize: 16,
//   //               ),
//   //             ),
//   //             subtitle: Text("Dose: ${item.dosage}"),
//   //             // ✅ السلة هتختفي للمريض فوراً حتى في الـ In-progress (طلب 2)
//   //             trailing:
//   //                 hideDeleteIcon
//   //                     ? null
//   //                     : IconButton(
//   //                       icon: const Icon(
//   //                         Icons.delete_outline,
//   //                         color: Colors.red,
//   //                       ),
//   //                       onPressed:
//   //                           () => setState(
//   //                             () => prescriptionItems.removeAt(index),
//   //                           ),
//   //                     ),
//   //           ),
//   //         ),
//   //       );
//   //     },
//   //   );
//   // }

//   Widget _buildPrescriptionItemsList() {
//     if (prescriptionItems.isEmpty) {
//       return const Center(
//         child: Padding(
//           padding: EdgeInsets.all(20),
//           child: Text("No medicines added"),
//         ),
//       );
//     }

//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: prescriptionItems.length,
//       itemBuilder: (context, index) {
//         final item = prescriptionItems[index];
//         bool isSavedOnServer = item.itemId != null;

//         // ✅ شرط إخفاء أيقونة الحذف
//         final bool hideDeleteIcon =
//             isPatient || (isCompleted && isSavedOnServer);

//         return Card(
//           margin: const EdgeInsets.only(bottom: 12),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15),
//             side: BorderSide(color: Colors.grey.shade200),
//           ),
//           elevation: 0,
//           child: Padding(
//             padding: const EdgeInsets.all(12),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 ListTile(
//                   contentPadding: EdgeInsets.zero,
//                   leading: CircleAvatar(
//                     backgroundColor: const Color(0xFFF3E8FF),
//                     child: Icon(
//                       Icons.medication,
//                       color: const Color(0xFF9333EA),
//                     ),
//                   ),
//                   title: Text(
//                     item.medicationName,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//                   subtitle: Text("Quantity: ${item.quantity} units"),
//                   trailing:
//                       hideDeleteIcon
//                           ? null
//                           : IconButton(
//                             icon: const Icon(
//                               Icons.delete_outline,
//                               color: Colors.red,
//                             ),
//                             onPressed:
//                                 () => setState(
//                                   () => prescriptionItems.removeAt(index),
//                                 ),
//                           ),
//                 ),
//                 const Divider(height: 20),
//                 // 🚨 هنا البيانات اللي كانت ناقصة (الرجوع للشكل القديم)
//                 Wrap(
//                   spacing: 20,
//                   runSpacing: 10,
//                   children: [
//                     _buildDetailItem(Icons.shutter_speed, item.dosage),
//                     _buildDetailItem(Icons.calendar_today, item.duration),
//                     _buildDetailItem(
//                       Icons.repeat,
//                       _getFrequencyName(item.reminderFrequencyType),
//                     ),
//                   ],
//                 ),
//                 if (item.instructions != null &&
//                     item.instructions!.isNotEmpty &&
//                     item.instructions != "No instructions")
//                   Padding(
//                     padding: const EdgeInsets.only(top: 12),
//                     child: Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: Colors.blue.withOpacity(0.05),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         "💡 Note: ${item.instructions}",
//                         style: const TextStyle(
//                           fontSize: 12,
//                           color: Colors.blueGrey,
//                           fontStyle: FontStyle.italic,
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // ميثود مساعدة لعرض البيانات الصغيرة (الأيقونة + النص)
//   Widget _buildDetailItem(IconData icon, String text) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(icon, size: 16, color: Colors.grey),
//         const SizedBox(width: 5),
//         Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87)),
//       ],
//     );
//   }

//   // ميثود تحويل رقم الفريكوانسي لنص (مهمة جداً)
//   String _getFrequencyName(int type) {
//     switch (type) {
//       case 0:
//         return "Once";
//       case 1:
//         return "Daily";
//       case 2:
//         return "Weekly";
//       case 3:
//         return "Monthly";
//       case 4:
//         return "Every X Hours";
//       default:
//         return "As prescribed";
//     }
//   }

//   void _showAddMedicationSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
//       ),
//       builder:
//           (context) => AddMedicationSheet(
//             onAdd: (item) => setState(() => prescriptionItems.add(item)),
//           ),
//     );
//   }

//   void _showSnackBar(String msg, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(msg),
//         backgroundColor: isError ? Colors.red : Colors.green,
//       ),
//     );
//   }

//   void _showFollowUpDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder:
//           (context) => AlertDialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20),
//             ),
//             title: const Text("Session Completed"),
//             content: const Text(
//               "Would you like to schedule a follow-up appointment?",
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   context.pop();
//                 },
//                 child: const Text("No, Home"),
//               ),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF9333EA),
//                 ),
//                 onPressed: () {
//                   Navigator.pop(context);
//                   context.pushReplacement(
//                     AppRouter.kDoctorSchedule,
//                     extra: {
//                       'patientName': widget.patientName,
//                       'originalAppointmentId': widget.appointmentId,
//                     },
//                   );
//                 },
//                 child: const Text(
//                   "Yes, Schedule",
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//             ],
//           ),
//     );
//   }
// }

// class _CustomTextField extends StatelessWidget {
//   final TextEditingController controller;
//   final String label;
//   final IconData icon;
//   final bool enabled;
//   final int maxLines;
//   const _CustomTextField({
//     required this.controller,
//     required this.label,
//     required this.icon,
//     this.enabled = true,
//     this.maxLines = 1,
//   });
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 15),
//       child: TextField(
//         controller: controller,
//         enabled: enabled,
//         maxLines: maxLines,
//         decoration: InputDecoration(
//           labelText: label,
//           prefixIcon: Icon(
//             icon,
//             color: enabled ? const Color(0xFF9333EA) : Colors.grey,
//             size: 20,
//           ),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15),
//             borderSide: BorderSide(color: Colors.grey[200]!),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15),
//             borderSide: BorderSide(color: Colors.grey[200]!),
//           ),
//           filled: true,
//           fillColor: enabled ? Colors.white : Colors.grey.shade50,
//         ),
//       ),
//     );
//   }
// }

// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:go_router/go_router.dart';

// import '../../../../core/utils/app_router.dart';
// import '../../../../core/utils/functions/pdf_prescription_service.dart';
// import '../../../../core/utils/helper/service_locator.dart';
// import '../../../../core/utils/helper/session_manager.dart';
// import '../../../../core/widgets/shimmer_loading.dart';
// import '../../domain/entities/medical_record_entity.dart';
// import '../../domain/entities/medication_item_entity.dart';
// import '../../domain/entities/prescription_entity.dart';
// import '../../domain/use_cases/update_appointment_status_use_case.dart';
// import '../manager/appointment_action_cubit/appointment_action_cubit.dart';
// import '../manager/exam_session_cubit/exam_session_cubit.dart';
// import 'add_medication_sheet.dart';

// class MedicalDetailsView extends StatefulWidget {
//   final String appointmentId;
//   final String? patientId;
//   final String patientName;
//   final String doctorName;
//   final String initialStatus;
//   final String? patientNote;
//   final bool isReadOnly;

//   const MedicalDetailsView({
//     super.key,
//     required this.appointmentId,
//     this.patientId,
//     required this.patientName,
//     required this.doctorName,
//     required this.initialStatus,
//     this.patientNote,
//     this.isReadOnly = false,
//   });

//   @override
//   State<MedicalDetailsView> createState() => _MedicalDetailsViewState();
// }

// class _MedicalDetailsViewState extends State<MedicalDetailsView> {
//   // --- 1. Controllers ---
//   final _chiefComplaintController = TextEditingController();
//   final _vitalsController = TextEditingController();
//   final _physicalExamController = TextEditingController();
//   final _diagnosisController = TextEditingController();
//   final _diagnosisCodeController = TextEditingController();
//   final _treatmentPlanController = TextEditingController();
//   final _doctorNotesController = TextEditingController();
//   final _followUpInstructionsController = TextEditingController();

//   // --- 2. State Variables ---
//   bool _isStarted = false;
//   bool _followUpRequired = false;
//   DateTime? _followUpDate;
//   List<MedicationItemEntity> _prescriptionItems = [];
//   String? _currentPrescriptionId;
//   String? _actualPatientId;
//   bool _isAccessGranted = false;

//   // --- 3. Getters (Logic Core) ---
//   bool get isPatient =>
//       getIt<SessionManager>().userRole?.toLowerCase() == 'patient';
//   bool get isCompleted => widget.initialStatus.toLowerCase() == 'completed';
//   bool get isCancelled => widget.initialStatus.toLowerCase() == 'cancelled';
//   bool get isInProgress => widget.initialStatus.toLowerCase() == 'inprogress';
//   bool get isPendingOrBooked =>
//       widget.initialStatus.toLowerCase() == 'pending' ||
//       widget.initialStatus.toLowerCase() == 'booked';

//   // صلاحيات التعديل
//   bool get canEditRecord =>
//       !isPatient && _isStarted && !isCompleted && !isCancelled;
//   bool get canEditMeds => !isPatient && _isStarted && !isCancelled;

//   @override
//   void initState() {
//     super.initState();
//     // لو الحالة جاية أصلاً شغالة أو منتهية، نفتح الفورمة فوراً
//     if (isCompleted || isInProgress) {
//       _isStarted = true;
//     }
//     context.read<ExamSessionCubit>().fetchAppointmentDetails(
//       widget.appointmentId,
//     );
//   }

//   @override
//   void dispose() {
//     _chiefComplaintController.dispose();
//     _vitalsController.dispose();
//     _physicalExamController.dispose();
//     _diagnosisController.dispose();
//     _diagnosisCodeController.dispose();
//     _treatmentPlanController.dispose();
//     _doctorNotesController.dispose();
//     _followUpInstructionsController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FD),
//       appBar: _buildAppBar(),
//       body: MultiBlocListener(
//         listeners: [
//           // مراقب جلب البيانات
//           BlocListener<ExamSessionCubit, ExamSessionState>(
//             listener: (context, state) {
//               if (state is AppointmentDetailsFetched) {
//                 final d = state.details;
//                 setState(() {
//                   _actualPatientId = d.patientId.toString();
//                   if (d.medicalRecord != null)
//                     _populateFields(d.medicalRecord!);
//                   if (d.prescriptions != null && d.prescriptions!.isNotEmpty) {
//                     _prescriptionItems = List.from(
//                       d.prescriptions!.first.items,
//                     );
//                     _currentPrescriptionId =
//                         d.prescriptions!.first.prescriptionId;
//                   }
//                 });
//               } else if (state is PrescriptionCreatedSuccess) {
//                 context.read<ExamSessionCubit>().fetchPrescription(
//                   widget.appointmentId,
//                 );
//                 _showSnackBar(state.message, isError: false);
//               } else if (state is ExamSessionFailure) {
//                 _showSnackBar(state.errMessage, isError: true);
//               }
//             },
//           ),
//           // مراقب الأكشن (Start/Complete)
//           BlocListener<AppointmentActionCubit, AppointmentActionState>(
//             listener: (context, state) {
//               if (state is AppointmentActionSuccess) {
//                 if (state.message.toLowerCase().contains("start") ||
//                     state.actionType == 'start') {
//                   setState(() => _isStarted = true);
//                 }
//               } else if (state is AppointmentActionFailure) {
//                 _showSnackBar(state.errMessage, isError: true);
//               }
//             },
//           ),
//         ],
//         child: BlocBuilder<ExamSessionCubit, ExamSessionState>(
//           builder: (context, state) {
//             if (state is MedicalRecordLoading && !_isStarted) {
//               return _buildShimmer();
//             }
//             return _buildMainContent();
//           },
//         ),
//       ),
//     );
//   }

//   // --- 🎨 UI Methods ---

//   AppBar _buildAppBar() {
//     return AppBar(
//       title: Text(isCompleted ? "Medical Report" : "Session Details"),
//       backgroundColor: Colors.white,
//       foregroundColor: Colors.black,
//       elevation: 0.5,
//       actions: [
//         if (!isPatient)
//           IconButton(
//             icon: const Icon(
//               Icons.history_edu,
//               color: Color(0xFF9333EA),
//               size: 28,
//             ),
//             onPressed:
//                 () => context.push(
//                   AppRouter.kMedicalHistory,
//                   extra: {
//                     'patientId': _actualPatientId ?? widget.patientId,
//                     'appointmentId': widget.appointmentId,
//                     'isDoctorView': true,
//                   },
//                 ),
//           ),
//         if (isCompleted)
//           IconButton(
//             icon: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
//             onPressed:
//                 () => PdfPrescriptionService.generatePrescription(
//                   patientName: widget.patientName,
//                   doctorName: widget.doctorName,
//                   diagnosis: _diagnosisController.text,
//                   items: _prescriptionItems,
//                 ),
//           ),
//         const SizedBox(width: 10),
//       ],
//     );
//   }

//   Widget _buildMainContent() {
//     return SingleChildScrollView(
//       padding: EdgeInsets.all(16.w),
//       child: Column(
//         children: [
//           _buildProfileHeader(),
//           SizedBox(height: 16.h),

//           // 🔐 الأكسس للمريض فقط
//           if (isPatient && !isCancelled) _buildAccessSwitch(),

//           if (isCancelled) _buildCancelledView(),

//           if (!isCancelled)
//             AnimatedSwitcher(
//               duration: const Duration(milliseconds: 500),
//               child:
//                   !_isStarted
//                       ? _buildWaitingOrStartArea()
//                       : _buildActiveSessionArea(),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProfileHeader() {
//     return Container(
//       padding: EdgeInsets.all(20.w),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF9333EA), Color(0xFF7E22CE)],
//         ),
//         borderRadius: BorderRadius.circular(20.r),
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 30.r,
//             backgroundColor: Colors.white.withOpacity(0.2),
//             child: const Icon(Icons.person, size: 35, color: Colors.white),
//           ),
//           SizedBox(width: 15.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   isPatient ? "Attending Doctor" : "Patient Name",
//                   style: TextStyle(color: Colors.white70, fontSize: 11.sp),
//                 ),
//                 Text(
//                   isPatient ? widget.doctorName : widget.patientName,
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 18.sp,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           _buildStatusBadge(),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusBadge() {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.2),
//         borderRadius: BorderRadius.circular(10.r),
//       ),
//       child: Text(
//         widget.initialStatus.toUpperCase(),
//         style: TextStyle(
//           color: Colors.white,
//           fontSize: 10.sp,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   Widget _buildAccessSwitch() {
//     return Container(
//       margin: EdgeInsets.only(bottom: 16.h),
//       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15.r),
//         border: Border.all(color: const Color(0xFF9333EA).withOpacity(0.1)),
//       ),
//       child: Row(
//         children: [
//           const Icon(
//             Icons.lock_open_outlined,
//             color: Color(0xFF9333EA),
//             size: 20,
//           ),
//           SizedBox(width: 12.w),
//           const Expanded(
//             child: Text(
//               "Grant doctor full history access",
//               style: TextStyle(fontSize: 13),
//             ),
//           ),
//           Switch(
//             value: _isAccessGranted,
//             onChanged: (val) {
//               if (val && !_isAccessGranted) {
//                 context.read<ExamSessionCubit>().grantMedicalAccess(
//                   widget.appointmentId,
//                 );
//                 setState(() => _isAccessGranted = true);
//               }
//             },
//             activeColor: const Color(0xFF9333EA),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildWaitingOrStartArea() {
//     if (isPatient) {
//       return Column(
//         children: [
//           SizedBox(height: 50.h),
//           const Icon(
//             Icons.hourglass_empty_rounded,
//             size: 80,
//             color: Colors.orange,
//           ),
//           SizedBox(height: 20.h),
//           const Text(
//             "Waiting for Doctor",
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           const Text(
//             "The doctor will start the session shortly.",
//             style: TextStyle(color: Colors.grey),
//           ),
//           SizedBox(height: 30.h),
//           _buildPatientNoteContainer(),
//         ],
//       );
//     }
//     return Column(
//       children: [
//         SizedBox(height: 40.h),
//         _buildPatientNoteContainer(),
//         SizedBox(height: 40.h),
//         ElevatedButton.icon(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.green,
//             foregroundColor: Colors.white,
//             minimumSize: Size(250.w, 55.h),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(30.r),
//             ),
//           ),
//           onPressed:
//               () => context.read<AppointmentActionCubit>().updateStatus(
//                 widget.appointmentId,
//                 AppointmentAction.start,
//               ),
//           icon: const Icon(Icons.play_arrow_rounded),
//           label: const Text(
//             "Start Session",
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildActiveSessionArea() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (isCompleted) _buildReadOnlyInfoBanner(),
//         _buildSectionTitle("Clinical Assessment"),
//         _buildMedicalForm(),
//         const Divider(height: 50),
//         _buildSectionTitle("Prescription"),
//         _buildPrescriptionItemsList(),
//         if (canEditMeds) _buildAddMedicationButton(),
//         if (!isPatient) ...[SizedBox(height: 30.h), _buildSubmitButton()],
//       ],
//     );
//   }

//   Widget _buildMedicalForm() {
//     return Column(
//       children: [
//         _CustomTextField(
//           controller: _chiefComplaintController,
//           label: "Chief Complaint",
//           icon: Icons.sick_outlined,
//           enabled: canEditRecord,
//         ),
//         _CustomTextField(
//           controller: _vitalsController,
//           label: "Vital Signs",
//           icon: Icons.monitor_heart_outlined,
//           enabled: canEditRecord,
//         ),
//         _CustomTextField(
//           controller: _physicalExamController,
//           label: "Physical Examination",
//           icon: Icons.accessibility_new,
//           enabled: canEditRecord,
//         ),
//         _CustomTextField(
//           controller: _diagnosisController,
//           label: "Final Diagnosis *",
//           icon: Icons.fact_check,
//           enabled: canEditRecord,
//         ),
//         _CustomTextField(
//           controller: _treatmentPlanController,
//           label: "Treatment Plan",
//           icon: Icons.event_note,
//           maxLines: 3,
//           enabled: canEditRecord,
//         ),
//       ],
//     );
//   }

//   Widget _buildPrescriptionItemsList() {
//     if (_prescriptionItems.isEmpty)
//       return const Center(
//         child: Padding(
//           padding: EdgeInsets.all(20),
//           child: Text("No medicines added"),
//         ),
//       );

//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: _prescriptionItems.length,
//       itemBuilder: (context, index) {
//         final item = _prescriptionItems[index];
//         final bool hideDelete =
//             isPatient || (isCompleted && item.itemId != null);

//         return Card(
//           margin: EdgeInsets.only(bottom: 12.h),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15.r),
//             side: BorderSide(color: Colors.grey.shade200),
//           ),
//           elevation: 0,
//           child: Padding(
//             padding: const EdgeInsets.all(12),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 ListTile(
//                   contentPadding: EdgeInsets.zero,
//                   leading: const CircleAvatar(
//                     backgroundColor: Color(0xFFF3E8FF),
//                     child: Icon(Icons.medication, color: Color(0xFF9333EA)),
//                   ),
//                   title: Text(
//                     item.medicationName,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//                   subtitle: Text("Quantity: ${item.quantity} units"),
//                   trailing:
//                       hideDelete
//                           ? null
//                           : IconButton(
//                             icon: const Icon(
//                               Icons.delete_outline,
//                               color: Colors.red,
//                             ),
//                             onPressed:
//                                 () => setState(
//                                   () => _prescriptionItems.removeAt(index),
//                                 ),
//                           ),
//                 ),
//                 const Divider(height: 20),
//                 Wrap(
//                   spacing: 20,
//                   runSpacing: 10,
//                   children: [
//                     _buildDetailItem(Icons.shutter_speed, item.dosage),
//                     _buildDetailItem(Icons.calendar_today, item.duration),
//                     _buildDetailItem(
//                       Icons.repeat,
//                       _getFrequencyName(item.reminderFrequencyType),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // --- 🛠️ Logic Helpers ---

//   void _populateFields(MedicalRecordEntity record) {
//     _chiefComplaintController.text = record.chiefComplaint;
//     _vitalsController.text = record.vitalSigns;
//     _physicalExamController.text = record.physicalExamination;
//     _diagnosisController.text = record.diagnosis;
//     _treatmentPlanController.text = record.treatmentPlan;
//   }

//   void _handleFinishSession() async {
//     if (!isCompleted) {
//       if (_diagnosisController.text.trim().isEmpty ||
//           _prescriptionItems.isEmpty) {
//         _showSnackBar(
//           "Diagnosis and at least one medication are required",
//           isError: true,
//         );
//         return;
//       }
//     }
//     await _onCompletePressed();
//     if (!isCompleted) {
//       final sessionState = context.read<ExamSessionCubit>().state;
//       if (sessionState is! ExamSessionFailure) {
//         await context.read<AppointmentActionCubit>().updateStatus(
//           widget.appointmentId,
//           AppointmentAction.complete,
//         );
//         _showFollowUpDialog();
//       }
//     }
//   }

//   Future<void> _onCompletePressed() async {
//     final record = MedicalRecordEntity(
//       chiefComplaint: _chiefComplaintController.text,
//       vitalSigns: _vitalsController.text,
//       physicalExamination: _physicalExamController.text,
//       diagnosis: _diagnosisController.text,
//       treatmentPlan: _treatmentPlanController.text,
//       doctorNotes: _doctorNotesController.text,
//       followUpInstructions: _followUpInstructionsController.text,
//       diagnosisCode: _diagnosisCodeController.text,
//       followUpRequired: _followUpRequired,
//     );

//     if (!isCompleted) {
//       final isUpdate =
//           context.read<ExamSessionCubit>().state is MedicalRecordFetched;
//       await context.read<ExamSessionCubit>().saveMedicalRecord(
//         appointmentId: widget.appointmentId,
//         record: record,
//         isUpdate: isUpdate,
//       );

//       final prescription = PrescriptionEntity(
//         validUntil: DateTime.now().add(const Duration(days: 30)),
//         items: _prescriptionItems,
//       );
//       await context.read<ExamSessionCubit>().createPrescription(
//         appointmentId: widget.appointmentId,
//         prescription: prescription,
//       );
//     } else {
//       final newItems =
//           _prescriptionItems.where((item) => item.itemId == null).toList();
//       if (newItems.isNotEmpty && _currentPrescriptionId != null) {
//         await context.read<ExamSessionCubit>().addPrescriptionItems(
//           prescriptionId: _currentPrescriptionId!,
//           items: newItems,
//         );
//       }
//     }
//   }

//   // --- 🧱 Reusable Widgets ---

//   Widget _buildSectionTitle(String title) => Padding(
//     padding: EdgeInsets.symmetric(vertical: 12.h),
//     child: Text(
//       title,
//       style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),
//     ),
//   );

//   Widget _buildPatientNoteContainer() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16.r),
//         border: Border.all(color: Colors.orange.shade200),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Icons.psychology_alt,
//                 color: Colors.orange.shade700,
//                 size: 20,
//               ),
//               SizedBox(width: 8.w),
//               Text(
//                 "Reason for Visit",
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.orange.shade900,
//                 ),
//               ),
//             ],
//           ),
//           const Divider(height: 20),
//           Text(
//             widget.patientNote?.isNotEmpty == true
//                 ? widget.patientNote!
//                 : "No patient notes.",
//             style: const TextStyle(
//               fontStyle: FontStyle.italic,
//               color: Color(0xFF334155),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSubmitButton() {
//     return BlocBuilder<AppointmentActionCubit, AppointmentActionState>(
//       builder: (context, state) {
//         bool isLoading = state is AppointmentActionLoading;
//         return ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             backgroundColor:
//                 isCompleted ? Colors.blue : const Color(0xFF9333EA),
//             minimumSize: Size(double.infinity, 55.h),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(15.r),
//             ),
//           ),
//           onPressed: isLoading ? null : _handleFinishSession,
//           child:
//               isLoading
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : Text(
//                     isCompleted ? "Update Assessment" : "Finish Session",
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//         );
//       },
//     );
//   }

//   Widget _buildAddMedicationButton() {
//     return Padding(
//       padding: EdgeInsets.only(top: 15.h),
//       child: InkWell(
//         onTap:
//             () => showModalBottomSheet(
//               context: context,
//               isScrollControlled: true,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
//               ),
//               builder:
//                   (context) => AddMedicationSheet(
//                     onAdd:
//                         (item) => setState(() => _prescriptionItems.add(item)),
//                   ),
//             ),
//         child: Container(
//           padding: EdgeInsets.symmetric(vertical: 14.h),
//           decoration: BoxDecoration(
//             color: const Color(0xFF9333EA).withOpacity(0.05),
//             borderRadius: BorderRadius.circular(12.r),
//             border: Border.all(color: const Color(0xFF9333EA).withOpacity(0.2)),
//           ),
//           child: const Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.add_circle_outline, color: Color(0xFF9333EA)),
//               SizedBox(width: 8),
//               Text(
//                 "Add Medication",
//                 style: TextStyle(
//                   color: Color(0xFF9333EA),
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCancelledView() {
//     return Center(
//       child: Column(
//         children: [
//           SizedBox(height: 60.h),
//           Icon(
//             Icons.event_busy_rounded,
//             size: 100.sp,
//             color: Colors.red.shade200,
//           ),
//           SizedBox(height: 20.h),
//           const Text(
//             "Appointment Cancelled",
//             style: TextStyle(
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//               color: Colors.red,
//             ),
//           ),
//           const Padding(
//             padding: EdgeInsets.all(20),
//             child: Text(
//               "This session was cancelled. No records were created.",
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.grey),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildReadOnlyInfoBanner() {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       margin: EdgeInsets.only(bottom: 20.h),
//       decoration: BoxDecoration(
//         color: Colors.blue.shade50,
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(color: Colors.blue.shade200),
//       ),
//       child: const Row(
//         children: [
//           Icon(Icons.info_outline, color: Colors.blue),
//           SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               "Clinical records are finalized.",
//               style: TextStyle(
//                 color: Colors.blue,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 12,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailItem(IconData icon, String text) => Row(
//     mainAxisSize: MainAxisSize.min,
//     children: [
//       Icon(icon, size: 16, color: Colors.grey),
//       const SizedBox(width: 5),
//       Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87)),
//     ],
//   );

//   String _getFrequencyName(int type) {
//     switch (type) {
//       case 0:
//         return "Once";
//       case 1:
//         return "Daily";
//       case 2:
//         return "Weekly";
//       case 3:
//         return "Monthly";
//       case 4:
//         return "Every X Hours";
//       default:
//         return "As prescribed";
//     }
//   }

//   void _showSnackBar(String msg, {bool isError = false}) =>
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(msg),
//           backgroundColor: isError ? Colors.red : Colors.green,
//         ),
//       );

//   void _showFollowUpDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder:
//           (context) => AlertDialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20.r),
//             ),
//             title: const Text("Session Completed"),
//             content: const Text("Schedule a follow-up?"),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   context.pop();
//                 },
//                 child: const Text("No"),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   context.pushReplacement(
//                     AppRouter.kDoctorSchedule,
//                     extra: {
//                       'patientName': widget.patientName,
//                       'originalAppointmentId': widget.appointmentId,
//                     },
//                   );
//                 },
//                 child: const Text("Yes"),
//               ),
//             ],
//           ),
//     );
//   }

//   Widget _buildShimmer() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           const ShimmerLoading.rectangular(height: 90),
//           const SizedBox(height: 30),
//           const ShimmerLoading.rectangular(height: 25, width: 150),
//           const SizedBox(height: 20),
//           ...List.generate(
//             4,
//             (index) => const Padding(
//               padding: EdgeInsets.only(bottom: 15),
//               child: ShimmerLoading.rectangular(height: 55),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _CustomTextField extends StatelessWidget {
//   final TextEditingController controller;
//   final String label;
//   final IconData icon;
//   final bool enabled;
//   final int maxLines;
//   const _CustomTextField({
//     required this.controller,
//     required this.label,
//     required this.icon,
//     this.enabled = true,
//     this.maxLines = 1,
//   });
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: 15.h),
//       child: TextField(
//         controller: controller,
//         enabled: enabled,
//         maxLines: maxLines,
//         decoration: InputDecoration(
//           labelText: label,
//           prefixIcon: Icon(
//             icon,
//             color: enabled ? const Color(0xFF9333EA) : Colors.grey,
//             size: 20,
//           ),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15.r),
//             borderSide: BorderSide(color: Colors.grey[200]!),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15.r),
//             borderSide: BorderSide(color: Colors.grey[200]!),
//           ),
//           filled: true,
//           fillColor: enabled ? Colors.white : Colors.grey.shade50,
//         ),
//       ),
//     );
//   }
// }

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/app_router.dart';
import '../../../../core/utils/functions/pdf_prescription_service.dart';
import '../../../../core/utils/helper/service_locator.dart';
import '../../../../core/utils/helper/session_manager.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../domain/entities/medical_record_entity.dart';
import '../../domain/entities/medication_item_entity.dart';
import '../../domain/entities/prescription_entity.dart';
import '../../domain/use_cases/update_appointment_status_use_case.dart';
import '../manager/appointment_action_cubit/appointment_action_cubit.dart';
import '../manager/exam_session_cubit/exam_session_cubit.dart';
import 'add_medication_sheet.dart';

class MedicalDetailsView extends StatefulWidget {
  final String appointmentId;
  final String? patientId;
  final String patientName;
  final String doctorName;
  final String initialStatus;
  final String? patientNote;
  final bool isReadOnly;

  const MedicalDetailsView({
    super.key,
    required this.appointmentId,
    this.patientId,
    required this.patientName,
    required this.doctorName,
    required this.initialStatus,
    this.patientNote,
    this.isReadOnly = false,
  });

  @override
  State<MedicalDetailsView> createState() => _MedicalDetailsViewState();
}

class _MedicalDetailsViewState extends State<MedicalDetailsView> {
  // --- 1. Controllers ---
  final _chiefComplaintController = TextEditingController();
  final _vitalsController = TextEditingController();
  final _physicalExamController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _diagnosisCodeController = TextEditingController();
  final _treatmentPlanController = TextEditingController();
  final _doctorNotesController = TextEditingController();
  final _followUpInstructionsController = TextEditingController();

  // --- 2. State Variables ---
  bool _isStarted = false;
  String _currentStatus = "";
  List<MedicationItemEntity> _prescriptionItems = [];
  String? _currentPrescriptionId;
  String? _actualPatientId;
  bool _isAccessGranted = false;

  // --- 3. Logic Core (Getters) ---
  bool get isPatient =>
      getIt<SessionManager>().userRole?.toLowerCase() == 'patient';
  bool get isCompleted => _currentStatus.toLowerCase() == 'completed';
  bool get isCancelled => _currentStatus.toLowerCase() == 'cancelled';
  bool get isInProgress => _currentStatus.toLowerCase() == 'inprogress';

  // صلاحيات التعديل
  bool get canEditRecord =>
      !isPatient && _isStarted && !isCompleted && !isCancelled;
  bool get canEditMeds => !isPatient && _isStarted && !isCancelled;
  String cancelledBy = "";
  String cancelledReason = "";
  @override
  void initState() {
    super.initState();
    _currentStatus = widget.initialStatus;
    if (isCompleted || isInProgress) _isStarted = true;
    context.read<ExamSessionCubit>().fetchAppointmentDetails(
      widget.appointmentId,
    );
  }

  @override
  void dispose() {
    _chiefComplaintController.dispose();
    _vitalsController.dispose();
    _physicalExamController.dispose();
    _diagnosisController.dispose();
    _diagnosisCodeController.dispose();
    _treatmentPlanController.dispose();
    _doctorNotesController.dispose();
    _followUpInstructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: _buildAppBar(),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ExamSessionCubit, ExamSessionState>(
            listener: (context, state) {
              if (state is AppointmentDetailsFetched) {
                final d = state.details;
                setState(() {
                  _actualPatientId = d.patientId.toString();
                  _currentStatus = d.status;
                  _isAccessGranted = d.canViewMedicalHistory;
                  if (isInProgress || isCompleted) _isStarted = true;
                  if (d.medicalRecord != null)
                    _populateFields(d.medicalRecord!);
                  if (d.prescriptions != null && d.prescriptions!.isNotEmpty) {
                    _prescriptionItems = List.from(
                      d.prescriptions!.first.items,
                    );
                    _currentPrescriptionId =
                        d.prescriptions!.first.prescriptionId;
                  }
                  if (isCancelled) {
                    cancelledBy = d.cancelBy ?? "Unknown";
                    cancelledReason =
                        d.cancellationReason ?? "No reason provided";
                  }
                });
              }
            },
          ),
          BlocListener<AppointmentActionCubit, AppointmentActionState>(
            listener: (context, state) {
              if (state is AppointmentActionSuccess) {
                if (state.message.toLowerCase().contains("start") ||
                    state.actionType == 'start') {
                  setState(() {
                    _isStarted = true;
                    _currentStatus = "InProgress";
                  });
                }
              } else if (state is AppointmentActionFailure) {
                _showSnackBar(state.errMessage, isError: true);
              }
            },
          ),
        ],
        child: BlocBuilder<ExamSessionCubit, ExamSessionState>(
          builder: (context, state) {
            if (state is MedicalRecordLoading && !_isStarted)
              return _buildShimmer();
            return _buildMainContent();
          },
        ),
      ),
    );
  }

  // --- 🎨 UI Methods ---

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(isCompleted ? "Medical Report" : "Appointment Details"),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0.5,
      actions: [
        if (!isPatient)
          IconButton(
            icon: const Icon(
              Icons.history_edu,
              color: Color(0xFF9333EA),
              size: 28,
            ),
            onPressed:
                () => context.push(
                  AppRouter.kMedicalHistory,
                  extra: {
                    'patientId': _actualPatientId ?? widget.patientId,
                    'appointmentId': widget.appointmentId,
                    'isDoctorView': true,
                  },
                ),
          ),
        if (isCompleted)
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
            onPressed:
                () => PdfPrescriptionService.generatePrescription(
                  patientName: widget.patientName,
                  doctorName: widget.doctorName,
                  diagnosis: _diagnosisController.text,
                  items: _prescriptionItems,
                ),
          ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          _buildProfileHeader(),
          SizedBox(height: 16.h),
          if (isPatient && !isCancelled) _buildAccessSwitch(),
          if (isCancelled) _buildCancelledView(),
          if (!isCancelled)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child:
                  !_isStarted
                      ? _buildWaitingOrStartArea()
                      : _buildActiveSessionArea(),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9333EA), Color(0xFF7E22CE)],
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, size: 35, color: Colors.white),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPatient ? "Attending Doctor" : "Patient Name",
                  style: TextStyle(color: Colors.white70, fontSize: 11.sp),
                ),
                Text(
                  isPatient ? widget.doctorName : widget.patientName,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              _currentStatus.toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildAccessSwitch() {
  //   return Container(
  //     margin: EdgeInsets.only(bottom: 16.h),
  //     padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(15.r),
  //       border: Border.all(color: const Color(0xFF9333EA).withOpacity(0.1)),
  //     ),
  //     child: Row(
  //       children: [
  //         const Icon(
  //           Icons.lock_open_outlined,
  //           color: Color(0xFF9333EA),
  //           size: 20,
  //         ),
  //         SizedBox(width: 12.w),
  //         const Expanded(
  //           child: Text(
  //             "Grant doctor full history access",
  //             style: TextStyle(fontSize: 13),
  //           ),
  //         ),
  //         Switch(
  //           value: _isAccessGranted,
  //           onChanged: (val) {
  //             // if (val && !_isAccessGranted) {
  //             context.read<ExamSessionCubit>().grantMedicalAccess(
  //               widget.appointmentId,
  //             );
  //             setState(() => _isAccessGranted = val);
  //             // }
  //           },
  //           activeColor: const Color(0xFF9333EA),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Widget _buildAccessSwitch() {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: const Color(0xFF9333EA).withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(
            _isAccessGranted ? Icons.lock_open_outlined : Icons.lock_outline,
            color: const Color(0xFF9333EA),
            size: 20,
          ),
          SizedBox(width: 12.w),
          const Expanded(
            child: Text(
              "Grant doctor full history access",
              style: TextStyle(fontSize: 13),
            ),
          ),
          Switch(
            value: _isAccessGranted,
            onChanged: (val) {
              // 1. تحديث الـ UI فوراً عشان اليوزر يحس بالسرعة
              setState(() => _isAccessGranted = val);

              // 2. نداء الكيوبت بالمنطق الجديد (true للفتح، false للقفل)
              context.read<ExamSessionCubit>().toggleMedicalAccess(
                widget.appointmentId,
                val,
              );

              // 3. رسالة تأكيد بسيطة
              _showSnackBar(
                val ? "Medical access opened" : "Medical access closed",
                isError: !val,
              );
            },
            activeColor: const Color(0xFF9333EA),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingOrStartArea() {
    if (isPatient) {
      return Column(
        children: [
          SizedBox(height: 50.h),
          const Icon(
            Icons.hourglass_empty_rounded,
            size: 80,
            color: Colors.orange,
          ),
          SizedBox(height: 20.h),
          const Text(
            "Waiting for Doctor",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Text(
            "The doctor will start the session shortly.",
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 30.h),
          _buildPatientNoteContainer(),
        ],
      );
    }
    return Column(
      children: [
        SizedBox(height: 40.h),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.medical_services_outlined,
            size: 80,
            color: Colors.blue,
          ),
        ),
        SizedBox(height: 20.h),
        const Text(
          "Ready to start the session?",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 30.h),
        _buildPatientNoteContainer(),
        SizedBox(height: 40.h),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            minimumSize: Size(250.w, 55.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.r),
            ),
          ),
          onPressed:
              () => context.read<AppointmentActionCubit>().updateStatus(
                widget.appointmentId,
                AppointmentAction.start,
              ),
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text(
            "Start Session",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveSessionArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isCompleted) _buildReadOnlyInfoBanner(),
        _buildSectionTitle("Clinical Assessment"),
        _buildMedicalForm(),
        const Divider(height: 50),
        _buildSectionTitle("Medication Prescription"),
        _buildPrescriptionItemsList(),
        if (canEditMeds) _buildAddMedicationButton(),
        if (!isPatient) ...[SizedBox(height: 30.h), _buildSubmitButton()],
      ],
    );
  }

  // ✅ طلبك الأول: الويدجيت الناقصة _buildSectionTitle
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 17.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1E293B),
        ),
      ),
    );
  }

  Widget _buildMedicalForm() {
    return Column(
      children: [
        _CustomTextField(
          controller: _chiefComplaintController,
          label: "Chief Complaint",
          icon: Icons.sick_outlined,
          enabled: canEditRecord,
        ),
        _CustomTextField(
          controller: _vitalsController,
          label: "Vital Signs",
          icon: Icons.monitor_heart_outlined,
          enabled: canEditRecord,
        ),
        _CustomTextField(
          controller: _physicalExamController,
          label: "Physical Examination",
          icon: Icons.accessibility_new,
          enabled: canEditRecord,
        ),
        _CustomTextField(
          controller: _diagnosisController,
          label: "Final Diagnosis *",
          icon: Icons.fact_check,
          enabled: canEditRecord,
        ),
        _CustomTextField(
          controller: _diagnosisCodeController,
          label: "Diagnosis Code (ICD-10)",
          icon: Icons.qr_code,
          enabled: canEditRecord,
        ),
        _CustomTextField(
          controller: _treatmentPlanController,
          label: "Treatment Plan",
          icon: Icons.event_note,
          maxLines: 3,
          enabled: canEditRecord,
        ),
        _CustomTextField(
          controller: _doctorNotesController,
          label: "Internal Doctor Notes",
          icon: Icons.note_alt,
          maxLines: 2,
          enabled: canEditRecord,
        ),
      ],
    );
  }

  Widget _buildPrescriptionItemsList() {
    if (_prescriptionItems.isEmpty)
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text("No medicines prescribed."),
        ),
      );

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _prescriptionItems.length,
      itemBuilder: (context, index) {
        final item = _prescriptionItems[index];
        final bool hideDelete =
            isPatient || (isCompleted && item.itemId != null);

        return Card(
          margin: EdgeInsets.only(bottom: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFF3E8FF),
                    child: Icon(Icons.medication, color: Color(0xFF9333EA)),
                  ),
                  title: Text(
                    item.medicationName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text("Quantity: ${item.quantity} units"),
                  trailing:
                      hideDelete
                          ? null
                          : IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed:
                                () => setState(
                                  () => _prescriptionItems.removeAt(index),
                                ),
                          ),
                ),
                const Divider(height: 20),
                Wrap(
                  spacing: 20,
                  runSpacing: 10,
                  children: [
                    _buildDetailItem(Icons.shutter_speed, item.dosage),
                    _buildDetailItem(Icons.calendar_today, item.duration),
                    _buildDetailItem(
                      Icons.repeat,
                      _getFrequencyName(item.reminderFrequencyType),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ طلبك الثاني: الويدجيت الناقصة _handleFinishSession
  void _handleFinishSession() async {
    // التحقق فقط إذا لم تكن الجلسة مكتملة بالفعل
    if (!isCompleted) {
      if (_diagnosisController.text.trim().isEmpty ||
          _prescriptionItems.isEmpty) {
        _showSnackBar(
          "Diagnosis and at least one medication are required",
          isError: true,
        );
        return;
      }
    }

    // حفظ البيانات (Medical Record + Prescription)
    await _onCompletePressed();

    // تحديث الحالة لـ Complete إذا كانت الجلسة قيد التنفيذ
    if (!isCompleted) {
      final sessionState = context.read<ExamSessionCubit>().state;
      if (sessionState is! ExamSessionFailure) {
        await context.read<AppointmentActionCubit>().updateStatus(
          widget.appointmentId,
          AppointmentAction.complete,
        );
        _showFollowUpDialog();
      }
    }
  }

  Future<void> _onCompletePressed() async {
    final record = MedicalRecordEntity(
      chiefComplaint: _chiefComplaintController.text,
      vitalSigns: _vitalsController.text,
      physicalExamination: _physicalExamController.text,
      diagnosis: _diagnosisController.text,
      diagnosisCode: _diagnosisCodeController.text,
      treatmentPlan: _treatmentPlanController.text,
      doctorNotes: _doctorNotesController.text,
      followUpInstructions: _followUpInstructionsController.text,
      followUpRequired: _followUpInstructionsController.text.trim().isNotEmpty,
    );

    if (!isCompleted) {
      final isUpdate =
          context.read<ExamSessionCubit>().state is MedicalRecordFetched;
      await context.read<ExamSessionCubit>().saveMedicalRecord(
        appointmentId: widget.appointmentId,
        record: record,
        isUpdate: isUpdate,
      );

      final prescription = PrescriptionEntity(
        validUntil: DateTime.now().add(const Duration(days: 30)),
        items: _prescriptionItems,
      );
      await context.read<ExamSessionCubit>().createPrescription(
        appointmentId: widget.appointmentId,
        prescription: prescription,
      );
    } else {
      final newItems =
          _prescriptionItems.where((item) => item.itemId == null).toList();
      if (newItems.isNotEmpty && _currentPrescriptionId != null) {
        await context.read<ExamSessionCubit>().addPrescriptionItems(
          prescriptionId: _currentPrescriptionId!,
          items: newItems,
        );
      }
    }
  }

  // --- 🛠️ Reusable Widgets ---

  Widget _buildPatientNoteContainer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology_alt,
                color: Colors.orange.shade700,
                size: 20,
              ),
              SizedBox(width: 8.w),
              Text(
                "Reason for Visit",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade900,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Text(
            widget.patientNote?.isNotEmpty == true
                ? widget.patientNote!
                : "No patient notes provided.",
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<AppointmentActionCubit, AppointmentActionState>(
      builder: (context, state) {
        bool isLoading = state is AppointmentActionLoading;
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isCompleted ? Colors.blue : const Color(0xFF9333EA),
            minimumSize: Size(double.infinity, 55.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.r),
            ),
          ),
          onPressed: isLoading ? null : _handleFinishSession,
          child:
              isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                    isCompleted
                        ? "Update Treatment Plan"
                        : "Finish & Complete Session",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
        );
      },
    );
  }

  Widget _buildAddMedicationButton() {
    return Padding(
      padding: EdgeInsets.only(top: 15.h),
      child: InkWell(
        onTap:
            () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
              ),
              builder:
                  (context) => AddMedicationSheet(
                    onAdd:
                        (item) => setState(() => _prescriptionItems.add(item)),
                  ),
            ),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: const Color(0xFF9333EA).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFF9333EA).withOpacity(0.2)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, color: Color(0xFF9333EA)),
              SizedBox(width: 8),
              Text(
                "Add Medication",
                style: TextStyle(
                  color: Color(0xFF9333EA),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCancelledView() {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 60.h),
          Icon(
            Icons.event_busy_rounded,
            size: 100.sp,
            color: Colors.red.shade200,
          ),
          SizedBox(height: 20.h),
          const Text(
            "Appointment Cancelled",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              "This session was cancelled and no medical records were created.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          if (cancelledBy.isNotEmpty) ...[
            Text(
              "Cancelled By: $cancelledBy",
              style: TextStyle(fontSize: 14, color: Colors.red.shade400),
            ),
            const SizedBox(height: 8),
          ],
          if (cancelledReason.isNotEmpty) ...[
            Text(
              "Reason: $cancelledReason",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: Colors.red.shade300,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReadOnlyInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "This report is finalized. Records are locked for patient safety.",
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 14, color: Colors.grey),
      const SizedBox(width: 4),
      Text(text, style: TextStyle(fontSize: 12.sp, color: Colors.black87)),
    ],
  );

  String _getFrequencyName(int type) {
    switch (type) {
      case 0:
        return "Once";
      case 1:
        return "Daily";
      case 2:
        return "Weekly";
      case 3:
        return "Monthly";
      case 4:
        return "Every X Hours";
      default:
        return "As prescribed";
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );

  void _showFollowUpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            title: const Text("Success"),
            content: const Text(
              "Session completed successfully. Would you like to schedule a follow-up?",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.pop();
                },
                child: const Text("No"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.pushReplacement(
                    AppRouter.kDoctorSchedule,
                    extra: {
                      'patientName': widget.patientName,
                      'originalAppointmentId': widget.appointmentId,
                    },
                  );
                },
                child: const Text("Yes"),
              ),
            ],
          ),
    );
  }

  Widget _buildShimmer() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        const ShimmerLoading.rectangular(height: 90),
        const SizedBox(height: 30),
        const ShimmerLoading.rectangular(height: 25, width: 150),
        const SizedBox(height: 20),
        ...List.generate(
          4,
          (index) => const Padding(
            padding: EdgeInsets.only(bottom: 15),
            child: ShimmerLoading.rectangular(height: 55),
          ),
        ),
      ],
    ),
  );

  void _populateFields(MedicalRecordEntity record) {
    _chiefComplaintController.text = record.chiefComplaint;
    _vitalsController.text = record.vitalSigns;
    _physicalExamController.text = record.physicalExamination;
    _diagnosisController.text = record.diagnosis;
    _diagnosisCodeController.text = record.diagnosisCode ?? "";
    _treatmentPlanController.text = record.treatmentPlan;
    _doctorNotesController.text = record.doctorNotes ?? "";
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool enabled;
  final int maxLines;
  const _CustomTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.enabled = true,
    this.maxLines = 1,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.h),
      child: TextField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            color: enabled ? const Color(0xFF9333EA) : Colors.grey,
            size: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.r),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.r),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey.shade50,
        ),
      ),
    );
  }
}
