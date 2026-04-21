import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/functions/show_snack_bar.dart';

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
      getIt<SessionManager>().userRole.toLowerCase() == 'patient';
  bool get isCompleted => _currentStatus.toLowerCase() == 'completed';
  bool get isCancelled => _currentStatus.toLowerCase() == 'cancelled';
  bool get isInProgress => _currentStatus.toLowerCase() == 'inprogress';

  // صلاحيات التعديل
  bool get canEditRecord =>
      !widget.isReadOnly &&
      !isPatient &&
      _isStarted &&
      !isCompleted &&
      !isCancelled;
  bool get canEditMeds =>
      !widget.isReadOnly && !isPatient && _isStarted && !isCancelled;
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
                  if (d.medicalRecord != null) {
                    _populateFields(d.medicalRecord!);
                  }
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
            if (state is MedicalRecordLoading && !_isStarted) {
              return _buildShimmer();
            }
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
              color: Colors.white.withValues(alpha: 0.2),
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
  //       border: Border.all(color: const Color(0xFF9333EA).withValues(alpha: 0.1)),
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
  //           activeThumbColor: const Color(0xFF9333EA),
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
        border: Border.all(
          color: const Color(0xFF9333EA).withValues(alpha: 0.1),
        ),
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
            activeThumbColor: const Color(0xFF9333EA),
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
            color: Colors.blue.withValues(alpha: 0.1),
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
        if (!isPatient && !widget.isReadOnly) ...[
          SizedBox(height: 30.h),
          _buildSubmitButton(),
        ],
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
    if (_prescriptionItems.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text("No medicines prescribed."),
        ),
      );
    }

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
      if (_diagnosisController.text.trim().isEmpty) {
        showSnackBar(
          context,
          "Please provide a final diagnosis before completing the session.",
          Colors.red,
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
            color: const Color(0xFF9333EA).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: const Color(0xFF9333EA).withValues(alpha: 0.2),
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
    _diagnosisCodeController.text = record.diagnosisCode;
    _treatmentPlanController.text = record.treatmentPlan;
    _doctorNotesController.text = record.doctorNotes;
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
