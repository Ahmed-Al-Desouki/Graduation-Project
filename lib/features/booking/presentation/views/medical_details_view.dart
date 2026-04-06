import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/functions/pdf_prescription_service.dart';
import 'package:graduation_project/core/widgets/shimmer_loading.dart';
import 'package:graduation_project/features/booking/domain/entities/medication_item_entity.dart';
import 'package:graduation_project/features/booking/domain/entities/prescription_entity.dart';
import 'package:graduation_project/features/booking/domain/use_cases/update_appointment_status_use_case.dart';
import 'package:graduation_project/features/booking/presentation/manager/appointment_action_cubit/appointment_action_cubit.dart';
import 'package:graduation_project/features/booking/presentation/views/add_medication_sheet.dart';
import '../manager/exam_session_cubit/exam_session_cubit.dart';
import '../../domain/entities/medical_record_entity.dart';

class MedicalDetailsView extends StatefulWidget {
  final String appointmentId;
  final String patientId; // ✅ تأكد من استلام ID المريض
  final String patientName;
  final String? patientImage;
  final String doctorName;
  final String? doctorImage;
  final String doctorSpecialty;
  final String? patientNote;
  final String initialStatus;

  const MedicalDetailsView({
    super.key,
    required this.appointmentId,
    required this.patientId,
    required this.patientName,
    this.patientImage,
    required this.doctorName,
    this.doctorImage,
    required this.doctorSpecialty,
    this.patientNote,
    required this.initialStatus,
  });

  @override
  State<MedicalDetailsView> createState() => _MedicalDetailsViewState();
}

class _MedicalDetailsViewState extends State<MedicalDetailsView> {
  // 1. Controllers لكل حقول السجل الطبي
  final chiefComplaintController = TextEditingController();
  final vitalsController = TextEditingController();
  final physicalExamController = TextEditingController();
  final diagnosisController = TextEditingController();
  final diagnosisCodeController = TextEditingController();
  final treatmentPlanController = TextEditingController();
  final doctorNotesController = TextEditingController();
  final followUpInstructionsController = TextEditingController();

  bool isStarted = false;
  bool followUpRequired = false;
  DateTime? followUpDate;
  List<MedicationItemEntity> prescriptionItems = [];
  String? currentPrescriptionId;

  // هل الموعد مكتمل؟ (للقراءة فقط)
  bool get isCompleted => widget.initialStatus.toLowerCase() == 'completed';

  @override
  void initState() {
    super.initState();
    // لو الموعد منتهي أو قيد التنفيذ، نفتح الفورمة فوراً
    if (isCompleted || widget.initialStatus.toLowerCase() == 'inprogress') {
      isStarted = true;
    }

    // جلب البيانات المسجلة مسبقاً
    final cubit = context.read<ExamSessionCubit>();
    cubit.fetchMedicalRecord(widget.appointmentId);
    cubit.fetchPrescription(widget.appointmentId);
  }

  Widget _buildMedicalDetailsShimmer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // شيمر للكارد بتاع البروفايل
          const ShimmerLoading.rectangular(height: 90),
          const SizedBox(height: 30),

          // شيمر للعنوان
          const ShimmerLoading.rectangular(height: 25, width: 150),
          const SizedBox(height: 20),

          // شيمر للحقول (هنعمل 4 حقول مثلاً)
          ...List.generate(
            4,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: const ShimmerLoading.rectangular(height: 55),
            ),
          ),

          const SizedBox(height: 30),
          // شيمر لقسم الروشتة
          const ShimmerLoading.rectangular(height: 25, width: 200),
          const SizedBox(height: 15),
          const ShimmerLoading.rectangular(height: 100),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text(isCompleted ? "Medical Report" : "Examination Session"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.history_edu,
              color: Color(0xFF9333EA),
              size: 28,
            ),
            tooltip: "View Medical History",
            onPressed: () {
              // الانتقال لصفحة الهيستوري مع تمرير ID المريض وعلم الـ DoctorView
              context.push(
                AppRouter.kMedicalHistory,
                extra: {
                  'patientId': widget.patientId, // تأكد إنك استلمته من الكالندر
                  'appointmentId': widget.appointmentId,
                  'isDoctorView': true, // 👈 دي اللي هتقفل أزرار التعديل
                },
              );
            },
          ),
          if (isCompleted) // يظهر فقط لما الجلسة تخلص
            IconButton(
              icon: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
              onPressed: () {
                // هنا هننادي الفانكشن بتاعة الـ PDF اللي هنعملها المرة الجاية
                _showSnackBar("Generating PDF...");
                PdfPrescriptionService.generatePrescription(
                  patientName: widget.patientName,
                  doctorName: widget.doctorName,
                  diagnosis: diagnosisController.text,
                  items: prescriptionItems,
                );
              },
            ),
          const SizedBox(width: 10),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          // مراقب جلب البيانات
          BlocListener<ExamSessionCubit, ExamSessionState>(
            listener: (context, state) {
              if (state is MedicalRecordFetched) {
                _populateMedicalData(state.record);
              } else if (state is PrescriptionFetchedSuccess) {
                setState(() {
                  prescriptionItems = List.from(state.prescription.items);
                  currentPrescriptionId = state.prescription.prescriptionId;
                });
              } else if (state is PrescriptionCreatedSuccess) {
                // ✅ نحدث البيانات من السيرفر فوراً عشان الـ IDs تنزل والسلة تختفي
                context.read<ExamSessionCubit>().fetchPrescription(
                  widget.appointmentId,
                );
                _showSnackBar(state.message, isError: false);
              } else if (state is ExamSessionFailure) {
                _showSnackBar(state.errMessage, isError: true);
              }
            },
          ),
          // مراقب الأكشن (Start/Complete)
          BlocListener<AppointmentActionCubit, AppointmentActionState>(
            listener: (context, state) {
              if (state is AppointmentActionSuccess) {
                if (state.message.toLowerCase().contains("start") ||
                    !isStarted) {
                  setState(() => isStarted = true);
                }
              } else if (state is AppointmentActionFailure) {
                _showSnackBar(state.errMessage, isError: true);
              }
            },
          ),
        ],
        child: BlocBuilder<ExamSessionCubit, ExamSessionState>(
          builder: (context, state) {
            if (state is MedicalRecordLoading && !isStarted) {
              return _buildMedicalDetailsShimmer();
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileCard(),
                  const SizedBox(height: 20),

                  // التبديل بين شاشة الانتظار وشاشة الجلسة النشطة
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child:
                        !isStarted
                            ? _buildPreStartDashboard()
                            : _buildSessionActiveUI(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- 🎨 UI Widgets ---

  // 1. شاشة ما قبل بدء الجلسة
  Widget _buildPreStartDashboard() {
    return Column(
      key: const ValueKey("preStart"),
      children: [
        const SizedBox(height: 40),
        Center(
          child: Container(
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
        ),
        const SizedBox(height: 20),
        const Text(
          "Ready to start the session?",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          "Review patient notes before you begin.",
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 30),
        _buildPatientNoteSection(),
        const SizedBox(height: 40),
        _buildStartButton(),
      ],
    );
  }

  // 2. الجلسة النشطة (الفورمة والروشتة)
  Widget _buildSessionActiveUI() {
    return Column(
      key: const ValueKey("activeSession"),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isCompleted) _buildReadOnlyBanner(),
        const Text(
          "Clinical Assessment",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        _buildMedicalRecordForm(),
        const Divider(height: 50, thickness: 1),
        _buildPrescriptionSection(),
        const SizedBox(height: 40),
        _buildActionButton(),
      ],
    );
  }

  // 3. قسم ملاحظات المريض
  // Widget _buildPatientNoteSection() {
  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.orange.withOpacity(0.05),
  //       borderRadius: BorderRadius.circular(15),
  //       border: Border.all(color: Colors.orange.withOpacity(0.2)),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Row(
  //           children: [
  //             Icon(Icons.note_alt, size: 18, color: Colors.orange),
  //             SizedBox(width: 8),
  //             Text(
  //               "Patient's Note",
  //               style: TextStyle(
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.orange,
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 8),
  //         Text(
  //           widget.patientNote ?? "No additional notes provided by patient.",
  //           style: const TextStyle(fontSize: 14, color: Colors.black87),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildPatientNoteSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              const SizedBox(width: 8),
              Text(
                "Reason for Visit (Patient's Note)",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Text(
            // ✅ هنا الملاحظة اللي المريض كتبها وقت الحجز
            (widget.patientNote != null && widget.patientNote!.isNotEmpty)
                ? widget.patientNote!
                : "No specific reason provided by the patient.",
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF334155),
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // 4. بانر "للقراءة فقط" للمواعيد المنتهية
  Widget _buildReadOnlyBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock_outline, color: Colors.grey),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "This session is completed. Medical records are locked, but you can update medications.",
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 5. حقول السجل الطبي (الفورمة كاملة)
  Widget _buildMedicalRecordForm() {
    return Column(
      children: [
        _CustomTextField(
          controller: chiefComplaintController,
          label: "Chief Complaint",
          icon: Icons.sick_outlined,
          enabled: !isCompleted,
        ),
        _CustomTextField(
          controller: vitalsController,
          label: "Vital Signs (BP, Temp, Pulse)",
          icon: Icons.monitor_heart_outlined,
          enabled: !isCompleted,
        ),
        _CustomTextField(
          controller: physicalExamController,
          label: "Physical Examination",
          icon: Icons.accessibility_new_outlined,
          enabled: !isCompleted,
        ),
        _CustomTextField(
          controller: diagnosisController,
          label: "Final Diagnosis *",
          icon: Icons.fact_check_outlined,
          enabled: !isCompleted,
        ),
        _CustomTextField(
          controller: diagnosisCodeController,
          label: "Diagnosis Code (ICD-10)",
          icon: Icons.qr_code_outlined,
          enabled: !isCompleted,
        ),
        _CustomTextField(
          controller: treatmentPlanController,
          label: "Treatment Plan",
          icon: Icons.event_note_outlined,
          maxLines: 3,
          enabled: !isCompleted,
        ),
        _CustomTextField(
          controller: doctorNotesController,
          label: "Internal Doctor Notes",
          icon: Icons.note_alt_outlined,
          maxLines: 2,
          enabled: !isCompleted,
        ),
      ],
    );
  }

  // 6. قسم الروشتة (العناوين، اللستة، وزرار الإضافة)
  Widget _buildPrescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Medication Prescription",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        _buildPrescriptionItemsList(),
        const SizedBox(height: 15),
        InkWell(
          onTap: _showAddMedicationSheet,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF9333EA).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF9333EA).withOpacity(0.2),
              ),
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
      ],
    );
  }

  // 7. زرار الأكشن النهائي (Finish أو Update)
  Widget _buildActionButton() {
    return BlocBuilder<AppointmentActionCubit, AppointmentActionState>(
      builder: (context, state) {
        bool isLoading = state is AppointmentActionLoading;
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isCompleted ? Colors.blue : const Color(0xFF9333EA),
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
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
                      fontSize: 16,
                    ),
                  ),
        );
      },
    );
  }

  // --- ⚙️ Logic Methods ---

  void _handleFinishSession() async {
    // التحقق من البيانات فقط في الجلسة الجديدة
    if (!isCompleted) {
      if (diagnosisController.text.trim().isEmpty ||
          prescriptionItems.isEmpty) {
        _showSnackBar(
          "Diagnosis and at least one medication are required",
          isError: true,
        );
        return;
      }
    }

    // حفظ البيانات (ريكورد + روشتة)
    await _onCompletePressed();

    if (!isCompleted) {
      final sessionState = context.read<ExamSessionCubit>().state;
      if (sessionState is! ExamSessionFailure) {
        // تحديث حالة الموعد لـ Complete في السيرفر
        await context.read<AppointmentActionCubit>().updateStatus(
          widget.appointmentId,
          AppointmentAction.complete,
        );
        _showFollowUpDialog();
      }
    }
  }

  Future<void> _onCompletePressed() async {
    // 1. تجهيز الريكورد (للعلم فقط لو مش Completed)
    final record = MedicalRecordEntity(
      chiefComplaint: chiefComplaintController.text,
      vitalSigns: vitalsController.text,
      physicalExamination: physicalExamController.text,
      diagnosis: diagnosisController.text,
      diagnosisCode: diagnosisCodeController.text,
      treatmentPlan: treatmentPlanController.text,
      doctorNotes: doctorNotesController.text,
      followUpRequired: followUpRequired,
      followUpDate: followUpDate,
      followUpInstructions:
          followUpInstructionsController.text.isEmpty
              ? "None"
              : followUpInstructionsController.text,
    );

    // 2. لو الجلسة لسه شغالة (InProgress)
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
        items: prescriptionItems,
      );
      await context.read<ExamSessionCubit>().createPrescription(
        appointmentId: widget.appointmentId,
        prescription: prescription,
      );
    }
    // 3. ✅ لو الجلسة منتهية (Completed) - سيناريو تحديث الأدوية
    else {
      final newItems =
          prescriptionItems.where((item) => item.itemId == null).map((item) {
            if (item.reminderFrequencyType == 0) {
              return item.copyWith(
                duration: "1 day",
                reminderEndDate: null, // ✅ تأكيد إرسال null للـ Once
                reminderWeeklyDays: null, // ✅ تأكيد إرسال null
                reminderFirstDoseTime: null,
                frequency: "Once",
              );
            }
            return item;
          }).toList();
      if (newItems.isNotEmpty && currentPrescriptionId != null) {
        await context.read<ExamSessionCubit>().addPrescriptionItems(
          prescriptionId: currentPrescriptionId!,
          items: newItems,
        );
      }
    }
  }

  // --- 🛠️ Helper Methods ---

  void _populateMedicalData(MedicalRecordEntity record) {
    setState(() {
      chiefComplaintController.text = record.chiefComplaint;
      vitalsController.text = record.vitalSigns;
      physicalExamController.text = record.physicalExamination;
      diagnosisController.text = record.diagnosis;
      diagnosisCodeController.text = record.diagnosisCode;
      treatmentPlanController.text = record.treatmentPlan;
      doctorNotesController.text = record.doctorNotes;
      isStarted = true;
    });
  }

  Widget _buildPrescriptionItemsList() {
    if (prescriptionItems.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text("No medicines added"),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: prescriptionItems.length,
      itemBuilder: (context, index) {
        final item = prescriptionItems[index];
        // ✅ السلة هتختفي لو الـ itemId جاي من السيرفر (مش null)
        bool isSavedOnServer = item.itemId != null;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
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
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFF3E8FF),
                    child: Icon(
                      Icons.medication,
                      color: const Color(0xFF9333EA),
                    ),
                  ),
                  title: Text(
                    item.medicationName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    "Quantity: ${item.quantity} units",
                  ), // ✅ إضافة الكمية [cite: 50]
                  trailing:
                      (isCompleted && isSavedOnServer)
                          ? null // ✅ إخفاء السلة للأدوية المسجلة في المواعيد المنتهية
                          : IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed:
                                () => setState(
                                  () => prescriptionItems.removeAt(index),
                                ),
                          ),
                ),
                const Divider(height: 20),
                // ✅ عرض التفاصيل الإضافية للمريض
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
                if (item.instructions != null &&
                    item.instructions!.isNotEmpty &&
                    item.instructions != "No special instructions")
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "💡 Note: ${item.instructions}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ويدجت مساعدة لعرض الأيقونة مع النص
  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87)),
      ],
    );
  }

  // تحويل رقم الـ Enum لاسم مفهوم للمريض [cite: 25, 27]
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

  // Widget _buildProfileCard() {
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(20),
  //       boxShadow: [
  //         BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
  //       ],
  //     ),
  //     child: Row(
  //       children: [
  //         CircleAvatar(
  //           radius: 25,
  //           backgroundImage:
  //               widget.patientImage != null
  //                   ? NetworkImage(widget.patientImage!)
  //                   : null,
  //           child:
  //               widget.patientImage == null ? const Icon(Icons.person) : null,
  //         ),
  //         const SizedBox(width: 15),
  //         Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               widget.patientName,
  //               style: const TextStyle(
  //                 fontWeight: FontWeight.bold,
  //                 fontSize: 16,
  //               ),
  //             ),
  //             const Text(
  //               "Patient Profile",
  //               style: TextStyle(color: Colors.grey, fontSize: 12),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9333EA), Color(0xFF7E22CE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9333EA).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Icon(Icons.person, size: 35, color: Colors.white),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Patient Name",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  widget.patientName, // ✅ اسم المريض
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.initialStatus.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return Center(
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          minimumSize: const Size(250, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
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
    );
  }

  void _showFollowUpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text("Session Completed"),
            content: const Text(
              "Would you like to schedule a follow-up appointment?",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.pop();
                },
                child: const Text("No, Home"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9333EA),
                ),
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
                child: const Text(
                  "Yes, Schedule",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  void _showAddMedicationSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder:
          (context) => AddMedicationSheet(
            onAdd: (item) => setState(() => prescriptionItems.add(item)),
          ),
    );
  }
}

// الـ Widget المساعد للـ TextField
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
      padding: const EdgeInsets.only(bottom: 15),
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
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey.shade50,
        ),
      ),
    );
  }
}
