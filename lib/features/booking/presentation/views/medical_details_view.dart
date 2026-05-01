import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/features/booking/domain/use_cases/update_appointment_status_use_case.dart';
import 'package:graduation_project/features/booking/presentation/views/add_medication_sheet.dart';
import 'package:graduation_project/features/booking/presentation/views/widgets/cancelled_appointment_view.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../core/utils/functions/show_snack_bar.dart';
import '../../../../core/utils/helper/service_locator.dart';
import '../../../../core/utils/helper/session_manager.dart';
import '../../../../core/utils/functions/pdf_prescription_service.dart';
import '../../domain/entities/medical_record_entity.dart';
import '../../domain/entities/medication_item_entity.dart';
import '../../domain/entities/prescription_entity.dart';
import '../manager/exam_session_cubit/exam_session_cubit.dart';
import '../manager/appointment_action_cubit/appointment_action_cubit.dart';
import 'widgets/medical_profile_header.dart';
import 'widgets/medical_record_form.dart';
import 'widgets/medication_item_card.dart';
import 'widgets/waiting_room_view.dart';

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
  final _chiefComplaintController = TextEditingController();
  final _vitalsController = TextEditingController();
  final _physicalExamController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _diagnosisCodeController = TextEditingController();
  final _treatmentPlanController = TextEditingController();
  final _doctorNotesController = TextEditingController();
  final _followUpInstructionsController = TextEditingController();

  bool _isStarted = false;
  String _currentStatus = "";
  List<MedicationItemEntity> _prescriptionItems = [];
  String? _currentPrescriptionId;
  String? _actualPatientId;
  bool _isAccessGranted = false;
  String cancelledBy = "";
  String cancelledReason = "";

  bool get isPatient =>
      getIt<SessionManager>().userRole.toLowerCase() == 'patient';
  bool get isCompleted => _currentStatus.toLowerCase() == 'completed';
  bool get isCancelled => _currentStatus.toLowerCase() == 'cancelled';
  bool get isInProgress => _currentStatus.toLowerCase() == 'inprogress';

  bool get canEditRecord =>
      !widget.isReadOnly &&
      !isPatient &&
      _isStarted &&
      !isCompleted &&
      !isCancelled;
  bool get canEditMeds =>
      !widget.isReadOnly && !isPatient && _isStarted && !isCancelled;

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
          _buildExamSessionListener(),
          _buildAppointmentActionListener(),
        ],
        child: BlocBuilder<ExamSessionCubit, ExamSessionState>(
          builder: (context, state) {
            if (state is MedicalRecordLoading && !_isStarted) {
              return const Center(child: CircularProgressIndicator());
            }
            return _buildMainContent();
          },
        ),
      ),
    );
  }

  BlocListener _buildExamSessionListener() {
    return BlocListener<ExamSessionCubit, ExamSessionState>(
      listener: (context, state) {
        if (state is AppointmentDetailsFetched) {
          final d = state.details;
          setState(() {
            _actualPatientId = d.patientId.toString();
            _currentStatus = d.status;
            _isAccessGranted = d.canViewMedicalHistory;
            if (isInProgress || isCompleted) _isStarted = true;
            if (d.medicalRecord != null) _populateFields(d.medicalRecord!);
            if (d.prescriptions != null && d.prescriptions!.isNotEmpty) {
              _prescriptionItems = List.from(d.prescriptions!.first.items);
              _currentPrescriptionId = d.prescriptions!.first.prescriptionId;
            }
            if (isCancelled) {
              cancelledBy = d.cancelBy ?? "Unknown";
              cancelledReason = d.cancellationReason ?? "No reason provided";
            }
          });
        } else if (state is MedicalRecordSavedSuccess) {
          showSnackBar(context, state.message, Colors.green);
        } else if (state is PrescriptionCreatedSuccess) {
          showSnackBar(context, state.message, Colors.green);
          context.read<ExamSessionCubit>().fetchAppointmentDetails(
            widget.appointmentId,
          );
        } else if (state is ExamSessionFailure) {
          showSnackBar(context, state.errMessage, Colors.red);
        }
      },
    );
  }

  BlocListener _buildAppointmentActionListener() {
    return BlocListener<AppointmentActionCubit, AppointmentActionState>(
      listener: (context, state) {
        if (state is AppointmentActionSuccess) {
          if (state.actionType == 'start') {
            setState(() {
              _isStarted = true;
              _currentStatus = "InProgress";
            });
          }
        } else if (state is AppointmentActionFailure) {
          showSnackBar(context, state.errMessage, Colors.red);
        }
      },
    );
  }

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
          MedicalProfileHeader(
            name: isPatient ? widget.doctorName : widget.patientName,
            status: _currentStatus,
            isPatient: isPatient,
          ),
          SizedBox(height: 16.h),
          if (isPatient && !isCancelled) _buildAccessSwitch(),
          if (isCancelled)
            CancelledAppointmentView(
              cancelledBy: cancelledBy,
              reason: cancelledReason,
            ),
          if (!isCancelled)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child:
                  !_isStarted
                      ? WaitingRoomView(
                        isPatient: isPatient,
                        patientNote: widget.patientNote,
                        onStartSession:
                            () => context
                                .read<AppointmentActionCubit>()
                                .updateStatus(
                                  widget.appointmentId,
                                  AppointmentAction.start,
                                ),
                      )
                      : _buildActiveSessionArea(),
            ),
        ],
      ),
    );
  }

  Widget _buildActiveSessionArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isCompleted) _buildReadOnlyBanner(),
        _buildSectionTitle("Clinical Assessment"),
        MedicalRecordForm(
          canEdit: canEditRecord,
          chiefComplaintController: _chiefComplaintController,
          vitalsController: _vitalsController,
          physicalExamController: _physicalExamController,
          diagnosisController: _diagnosisController,
          diagnosisCodeController: _diagnosisCodeController,
          treatmentPlanController: _treatmentPlanController,
          doctorNotesController: _doctorNotesController,
        ),
        const Divider(height: 40),
        _buildSectionTitle("Medication Prescription"),
        _buildPrescriptionList(),
        if (canEditMeds) _buildAddMedButton(),
        if (!isPatient && !widget.isReadOnly) ...[
          SizedBox(height: 30.h),
          _buildSubmitButton(),
        ],
      ],
    );
  }

  Widget _buildPrescriptionList() {
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
      itemBuilder:
          (context, index) => MedicationItemCard(
            item: _prescriptionItems[index],
            hideDelete:
                isPatient ||
                (isCompleted && _prescriptionItems[index].itemId != null),
            onDelete: () => setState(() => _prescriptionItems.removeAt(index)),
          ),
    );
  }

  Widget _buildAddMedButton() {
    return InkWell(
      onTap:
          () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
            ),
            builder:
                (context) => AddMedicationSheet(
                  onAdd: (item) => setState(() => _prescriptionItems.add(item)),
                ),
          ),
      child: Container(
        margin: EdgeInsets.only(top: 15.h),
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
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<AppointmentActionCubit, AppointmentActionState>(
      builder: (context, state) {
        // bool isLoading = state is AppointmentActionLoading;
        bool isLoading =
            state is MedicalRecordLoading || state is PrescriptionLoading;
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

  Widget _buildAccessSwitch() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: const Color(0xFF9333EA).withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(
            _isAccessGranted ? Icons.lock_open : Icons.lock,
            color: const Color(0xFF9333EA),
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
              setState(() => _isAccessGranted = val);
              context.read<ExamSessionCubit>().toggleMedicalAccess(
                widget.appointmentId,
                val,
              );
            },
            activeColor: const Color(0xFF9333EA),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyBanner() {
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

  void _handleFinishSession() async {
    if (!isCompleted) {
      if (_diagnosisController.text.trim().isEmpty) {
        showSnackBar(context, "Please provide a diagnosis.", Colors.red);
        return;
      }
    }

    await _onCompletePressed();

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
    if (!isCompleted) {
      final record = MedicalRecordEntity(
        chiefComplaint: _chiefComplaintController.text,
        vitalSigns: _vitalsController.text,
        physicalExamination: _physicalExamController.text,
        diagnosis: _diagnosisController.text,
        diagnosisCode: _diagnosisCodeController.text,
        treatmentPlan: _treatmentPlanController.text,
        doctorNotes: _doctorNotesController.text,
        followUpInstructions: _followUpInstructionsController.text,
        followUpRequired:
            _followUpInstructionsController.text.trim().isNotEmpty,
      );

      final isUpdate =
          context.read<ExamSessionCubit>().state is MedicalRecordFetched;

      await context.read<ExamSessionCubit>().saveMedicalRecord(
        appointmentId: widget.appointmentId,
        record: record,
        isUpdate: isUpdate,
      );
    }

    if (!isCompleted) {
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

  void _populateFields(MedicalRecordEntity record) {
    _chiefComplaintController.text = record.chiefComplaint;
    _vitalsController.text = record.vitalSigns;
    _physicalExamController.text = record.physicalExamination;
    _diagnosisController.text = record.diagnosis;
    _diagnosisCodeController.text = record.diagnosisCode;
    _treatmentPlanController.text = record.treatmentPlan;
    _doctorNotesController.text = record.doctorNotes;
  }

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
                    AppRouter.kBookingCalendar,
                    extra: {
                      'isPatientView': false,
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
}
