import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:graduation_project/core/utils/helper/session_manager.dart';
import 'package:graduation_project/features/booking/domain/use_cases/update_appointment_status_use_case.dart';
import '../../../domain/entities/slot_entity.dart';
import '../../manager/appointment_action_cubit/appointment_action_cubit.dart';
import '../../manager/booking_calendar_cubit/booking_calendar_cubit.dart';
import 'slot_card.dart';

class AppointmentSlotList extends StatelessWidget {
  final List<SlotEntity> slots;
  final bool isFollowUpMode; // ✅
  final String? originalAppointmentId; //

  const AppointmentSlotList({
    super.key,
    required this.slots,
    this.isFollowUpMode = false,
    this.originalAppointmentId,
  });

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return const Center(
        child: Text(
          "No slots generated for this day.",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Scrollbar(
      thumbVisibility: true,
      thickness: 8,
      radius: const Radius.circular(10),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: slots.length,
        itemBuilder: (context, index) {
          final slot = slots[index];
          return SlotCard(
            slot: slot,
            // onConfirm:
            //     () => context.read<AppointmentActionCubit>().updateStatus(
            //       slot.appointmentId!,
            //       AppointmentAction.confirm,
            //     ),
            onCancelByDoctor: () {
              context.read<AppointmentActionCubit>().doctorCancel(
                slot.appointmentId!,
                "Doctor Request",
              );
            },
            isFollowUpMode: isFollowUpMode,
            onBookFollowUp: () {
              if (originalAppointmentId != null) {
                context.read<AppointmentActionCubit>().bookFollowUp(
                  originalId: originalAppointmentId!,
                  slotId: slot.slotId,
                  instructions: "Follow-up appointment",
                );
              } else {
                debugPrint(
                  "❌ Error: originalAppointmentId is null in Follow-up mode",
                );
              }
            },
            onDetails: () {
              // 1. الانتقال لصفحة التفاصيل
              // تأكد من تعريف المسار في AppRouter أولاً
              context.push(
                AppRouter.kMedicalDetails,
                extra: {
                  'appointmentId': slot.appointmentId,
                  'patientName': slot.patientName,
                  'patientNote':
                      slot.patientNote, // تأكد إن الحقل ده موجود في Entity
                  // بيانات الدكتور ممكن تجيبها من الـ SessionManager مباشرة جوه الصفحة
                  'status': slot.status,
                },
              );
            },
            // onDelete: () => context.read<AppointmentActionCubit>().updateStatus(
            //   slot.appointmentId!,
            //   AppointmentAction.cancel,
            // ),
            onDelete: () {
              if (slot.status.toLowerCase() == 'available') {
                context.read<AppointmentActionCubit>().deleteAvailableSlot(
                  slot.slotId,
                );
              } else {
                // لو فيه مريض وحبيت تكنسل
                context.read<AppointmentActionCubit>().updateStatus(
                  slot.appointmentId!,
                  AppointmentAction.doctorCancel,
                  reason: "Doctor's request",
                );
              }
            },
            onBlock: () {
              if (slot.status.toLowerCase() == 'available') {
                context.read<AppointmentActionCubit>().blockAvailableSlot(
                  slot.slotId,
                );
              }
            },
          );
        },
      ),
    );
  }
}
