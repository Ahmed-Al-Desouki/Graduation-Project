import 'package:bloc/bloc.dart';
import 'package:graduation_project/features/booking/domain/entities/appointment_full_details_entity.dart';
import 'package:graduation_project/features/booking/domain/use_cases/GetDoctorAppointmentsUseCase.dart';
import 'package:graduation_project/features/booking/domain/use_cases/GetPatientAppointmentsUseCase.dart';
import 'package:graduation_project/features/booking/domain/use_cases/cancel_block_by_doctor_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/cancel_by_patient_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/update_appointment_status_use_case.dart';
import 'package:meta/meta.dart';

part 'appointment_center_state.dart';

class AppointmentsCenterCubit extends Cubit<AppointmentsCenterState> {
  final GetDoctorAppointmentsUseCase getDoctorAppointmentsUseCase;
  final GetPatientAppointmentsUseCase getPatientAppointmentsUseCase;
  // final CancelByPatientUseCase cancelByPatientUseCase;
  // final CancelBlockByDoctorUseCase cancelBlockByDoctorUseCase;
  final UpdateAppointmentStatusUseCase updateStatusUseCase;
  AppointmentsCenterCubit({
    required this.getDoctorAppointmentsUseCase,
    required this.getPatientAppointmentsUseCase,
    // required this.cancelByPatientUseCase,
    // required this.cancelBlockByDoctorUseCase,
    required this.updateStatusUseCase,
  }) : super(AppointmentCenterInitial());

  // 🩺 جلب مواعيد الدكتور
  // 🩺 جلب مواعيد الدكتور
  Future<void> getDoctorAppointments({DateTime? date, String? status}) async {
    emit(AppointmentsCenterLoading());
    var result = await getDoctorAppointmentsUseCase.call(
      date: date,
      status: status,
    );

    result.fold(
      (failure) => emit(AppointmentsCenterFailure(failure.errmessage)),
      (appointmentsList) {
        // 🚨 هنا الزتونة: لازم تبعت appointmentsList في الخانتين أول مرة
        emit(
          AppointmentsCenterSuccess(
            appointments: appointmentsList,
            fullAppointments: appointmentsList, // عشان لما تبحث تلاقي داتا هنا
            currentStatus: status,
          ),
        );
      },
    );
  }

  // 👤 جلب مواعيد المريض (نفس التعديل)
  Future<void> getPatientAppointments({String? status}) async {
    emit(AppointmentsCenterLoading());
    var result = await getPatientAppointmentsUseCase.call(status: status);

    result.fold(
      (failure) => emit(AppointmentsCenterFailure(failure.errmessage)),
      (appointmentsList) {
        emit(
          AppointmentsCenterSuccess(
            appointments: appointmentsList,
            fullAppointments: appointmentsList, // 🚨 هنا كمان
            currentStatus: status,
          ),
        );
      },
    );
  }

  // جوه الـ Success state، إنت شايل الـ allAppointments
  // لما تنادي ميثود البحث:
  void searchAppointments(String query) {
    final currentState = state;
    if (currentState is AppointmentsCenterSuccess) {
      // 💡 نستخدم اللستة الكاملة اللي خزنّاها فوق عشان نفلتر منها
      final List<AppointmentFullDetailsEntity> source =
          currentState.fullAppointments;

      if (query.isEmpty) {
        emit(
          AppointmentsCenterSuccess(
            appointments: source,
            fullAppointments: source,
            currentStatus: currentState.currentStatus,
          ),
        );
      } else {
        final filteredList =
            source.where((appointment) {
              return appointment.patientName.toLowerCase().contains(
                query.toLowerCase(),
              );
            }).toList();

        emit(
          AppointmentsCenterSuccess(
            appointments: filteredList,
            fullAppointments: source, // بنحافظ على المصدر الأصلي زي ما هو
            currentStatus: currentState.currentStatus,
          ),
        );
      }
    }
  }

  Future<void> cancelAppointmentByPatient(
    String appointmentId,
    String reason,
  ) async {
    emit(AppointmentsCenterLoading());
    var result = await updateStatusUseCase.call(
      appointmentId,
      AppointmentAction.patientCancel,
      cancelReason: reason,
    );

    result.fold(
      (failure) => emit(AppointmentsCenterFailure(failure.errmessage)),
      (_) => getPatientAppointments(
        status: "cancelled",
      ), // بعد الإلغاء، جلب المواعيد مرة تانية لتحديث الواجهة
    );
  }

  Future<void> doctorCancel(String appointmentId, String reason) async {
    emit(AppointmentsCenterLoading());
    // نمرر الـ doctorCancel من الـ Enum اللي عدلناه في الـ UseCase
    final result = await updateStatusUseCase(
      appointmentId,
      AppointmentAction.doctorCancel,
      cancelReason: reason,
    );

    result.fold(
      (failure) => emit(AppointmentsCenterFailure(failure.errmessage)),
      (_) => getDoctorAppointments(
        status: "cancelled",
      ), // بعد الإلغاء، جلب المواعيد مرة تانية لتحديث الواجهة
    );
  }

  // داخل AppointmentsCenterCubit
  void loadPreFetchedAppointments(List<AppointmentFullDetailsEntity> list) {
    emit(
      AppointmentsCenterSuccess(
        appointments: list,
        fullAppointments: list,
        currentStatus: null,
      ),
    );
  }
}
