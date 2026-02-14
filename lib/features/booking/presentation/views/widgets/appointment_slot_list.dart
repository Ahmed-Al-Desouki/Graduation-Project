import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:graduation_project/core/utils/helper/session_manager.dart';
import 'package:graduation_project/features/booking/domain/use_cases/update_appointment_status_use_case.dart';
import '../../../domain/entities/slot_entity.dart';
import '../../manager/appointment_action_cubit/appointment_action_cubit.dart';
import '../../manager/booking_calendar_cubit/booking_calendar_cubit.dart';
import 'slot_card.dart';

class AppointmentSlotList extends StatelessWidget {
  final List<SlotEntity> slots;

  const AppointmentSlotList({super.key, required this.slots});

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

    return BlocListener<AppointmentActionCubit, AppointmentActionState>(
      listener: (context, state) {
        if (state is AppointmentActionSuccess) {
          // ✅ أول ما الأكشن ينجح (تأكيد مثلاً)، بنعمل ريفريش للكالندر فوراً
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          final doctorId = getIt<SessionManager>().userId;
          // نداء الكيوبت بتاع الكالندر لتحديث الداتا
          context.read<BookingCalendarCubit>().getMonthlyCalendar(
            doctorId,
            DateTime.now(),
            DateTime.now().add(const Duration(days: 30)),
          );
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: slots.length,
        itemBuilder: (context, index) {
          final slot = slots[index];
          return SlotCard(
            slot: slot,
            onConfirm:
                () => context.read<AppointmentActionCubit>().updateStatus(
                  slot.appointmentId!,
                  AppointmentAction.confirm,
                ),
            onStart: () {
              // هنا ممكن تودي الدكتور لصفحة تفاصيل الكشف
              context.read<AppointmentActionCubit>().updateStatus(
                slot.appointmentId!,
                AppointmentAction.start,
              );
            },
          );
        },
      ),
    );
  }
}
