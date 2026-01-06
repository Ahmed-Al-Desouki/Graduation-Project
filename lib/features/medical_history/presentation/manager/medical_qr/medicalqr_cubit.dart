import 'package:bloc/bloc.dart';
import 'package:graduation_project/core/utils/helper/secure_storage_helper.dart';
import 'package:graduation_project/features/medical_history/data/repository/medical_history_qr_repo.dart';
import 'package:graduation_project/features/medical_history/domain/models/patient_profile_model.dart';
import 'package:graduation_project/features/medical_history/domain/models/shared_profile_model.dart';
import 'package:meta/meta.dart';

part 'medicalqr_state.dart';

class MedicalqrCubit extends Cubit<MedicalqrState> {
  final MedicalHistoryQrRepository repo;
  MedicalqrCubit(this.repo) : super(MedicalqrInitial());

  Future<void> generateQrCode(int medicalHistoryId) async {
    emit(MedicalQrLoading());

    // بنجيب الـ PatientId من اللوكال ستوريج
    final patientIdStr = await SecureStorageHelper.getUserId();

    if (patientIdStr == null) {
      emit(MedicalQrFailure("User ID not found"));
      return;
    }

    final result = await repo.generateQrCode(
      patientId: int.parse(patientIdStr),
      medicalHistoryId: medicalHistoryId,
    );

    result.fold(
      (failure) => emit(MedicalQrFailure(failure.errmessage)),
      (data) => emit(
        MedicalQrSuccess(
          data['qrCodeBase64']!, // الصورة (مش هنستخدمها بس خليها)
          data['token']!, // ✅ التوكن المهم للينك
        ),
      ),
    );
  }

  Future<void> fetchSharedHistory(String token) async {
    emit(SharedHistoryLoading());

    final result = await repo.getSharedHistory(token);

    result.fold(
      (failure) => emit(SharedHistoryFailure(failure.errmessage)),
      (profile) => emit(SharedHistorySuccess(profile)),
    );
  }
}
