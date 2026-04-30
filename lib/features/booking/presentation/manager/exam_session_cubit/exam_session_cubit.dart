import 'package:bloc/bloc.dart';
import 'package:graduation_project/features/booking/domain/entities/appointment_full_details_entity.dart';
import 'package:graduation_project/features/booking/domain/entities/medical_record_entity.dart';
import 'package:graduation_project/features/booking/domain/entities/medication_item_entity.dart';
import 'package:graduation_project/features/booking/domain/entities/prescription_entity.dart';
import 'package:graduation_project/features/booking/domain/use_cases/add_prescription_items_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/create_prescription_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/get_appointment_full_details_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/get_medical_record_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/get_prescription_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/open_access_for_medical_history_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/save_medical_record_use_case.dart';
import 'package:meta/meta.dart';

part 'exam_session_state.dart';

class ExamSessionCubit extends Cubit<ExamSessionState> {
  final GetAppointmentFullDetailsUseCase getAppointmentFullDetailsUseCase;
  final GetMedicalRecordUseCase getMedicalRecordUseCase;
  final SaveMedicalRecordUseCase saveMedicalRecordUseCase;
  final CreatePrescriptionUseCase createPrescriptionUseCase;
  final GetPrescriptionUseCase getPrescriptionUseCase;
  final AddPrescriptionItemsUseCase addPrescriptionItemsUseCase;
  final OpenAccessForMedicalHistoryUseCase openAccessForMedicalHistoryUseCase;
  ExamSessionCubit(
    this.getMedicalRecordUseCase,
    this.saveMedicalRecordUseCase,
    this.createPrescriptionUseCase,
    this.getPrescriptionUseCase,
    this.addPrescriptionItemsUseCase,
    this.getAppointmentFullDetailsUseCase,
    this.openAccessForMedicalHistoryUseCase,
  ) : super(ExamSessionInitial());

  Future<void> fetchAppointmentDetails(String appointmentId) async {
    emit(MedicalRecordLoading());

    final result = await getAppointmentFullDetailsUseCase(appointmentId);

    result.fold(
      (failure) => emit(ExamSessionFailure(failure.errmessage)),
      (details) => emit(AppointmentDetailsFetched(details)),
    );
  }

  Future<void> fetchMedicalRecord(String appointmentId) async {
    emit(MedicalRecordLoading());
    final result = await getMedicalRecordUseCase(appointmentId);

    result.fold((failure) {
      if (failure.errmessage.contains("404")) {
        emit(ExamSessionInitial());
      } else {
        emit(ExamSessionFailure(failure.errmessage));
      }
    }, (record) => emit(MedicalRecordFetched(record)));
  }

  Future<void> saveMedicalRecord({
    required String appointmentId,
    required MedicalRecordEntity record,
    required bool isUpdate,
  }) async {
    emit(MedicalRecordLoading());
    final result = await saveMedicalRecordUseCase(
      appointmentId: appointmentId,
      record: record,
      isUpdate: isUpdate,
    );

    result.fold(
      (failure) => emit(ExamSessionFailure(failure.errmessage)),
      (message) => emit(MedicalRecordSavedSuccess(message)),
    );
  }

  Future<void> createPrescription({
    required String appointmentId,
    required PrescriptionEntity prescription,
  }) async {
    emit(PrescriptionLoading());
    final result = await createPrescriptionUseCase(appointmentId, prescription);

    result.fold(
      (failure) => emit(ExamSessionFailure(failure.errmessage)),
      (newPrescription) =>
          emit(PrescriptionCreatedSuccess("Prescription issued successfully!")),
    );
  }

  // داخل ExamSessionCubit
  Future<void> fetchPrescription(String appointmentId) async {
    emit(MedicalRecordLoading());
    final result = await getPrescriptionUseCase(appointmentId);
    result.fold(
      (failure) => emit(ExamSessionFailure(failure.errmessage)),
      (prescription) => emit(PrescriptionFetchedSuccess(prescription)),
    );
  }

  Future<void> addPrescriptionItems({
    required String prescriptionId,
    required List<MedicationItemEntity> items,
  }) async {
    emit(MedicalRecordLoading());
    final result = await addPrescriptionItemsUseCase(
      prescriptionId: prescriptionId,
      items: items,
    );
    result.fold(
      (failure) => emit(ExamSessionFailure(failure.errmessage)),
      (message) => emit(PrescriptionCreatedSuccess(message)),
    );
  }

  Future<void> toggleMedicalAccess(
    String appointmentId,
    bool shouldGrant,
  ) async {
    final result = await openAccessForMedicalHistoryUseCase(
      appointmentId,
      shouldGrant,
    );

    result.fold(
      (failure) => emit(ExamSessionFailure(failure.errmessage)),
      (message) {},
    );
  }
}
