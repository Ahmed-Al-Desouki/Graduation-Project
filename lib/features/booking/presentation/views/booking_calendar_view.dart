import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:graduation_project/core/utils/helper/session_manager.dart';
import '../manager/booking_calendar_cubit/booking_calendar_cubit.dart';
import 'widgets/doctor_calendar_widget.dart';
import 'widgets/appointment_slot_list.dart';
import 'widgets/calendar_header.dart';

class BookingCalendarView extends StatefulWidget {
  const BookingCalendarView({super.key});

  @override
  State<BookingCalendarView> createState() => _BookingCalendarViewState();
}

class _BookingCalendarViewState extends State<BookingCalendarView> {
  @override
  void initState() {
    super.initState();
    // جلب بيانات الشهر الحالي عند فتح الشاشة
    final now = DateTime.now();
    final String doctorId = getIt<SessionManager>().userId;
    context.read<BookingCalendarCubit>().getMonthlyCalendar(
      doctorId, // ID الدكتور
      DateTime(now.year, now.month, 1),
      DateTime(now.year, now.month + 1, 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<BookingCalendarCubit, BookingCalendarState>(
          builder: (context, state) {
            if (state is BookingCalendarLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is BookingCalendarSuccess) {
              return Column(
                children: [
                  const CalendarHeader(), // الجزء العلوي (Greeting + Settings)
                  SizedBox(height: screenHeight * 0.02),

                  // الكالندر (الجزء الأوسط)
                  DoctorCalendarWidget(allDays: state.allDays),

                  const Divider(thickness: 1, height: 32),

                  // قائمة المواعيد (الجزء السفلي)
                  Expanded(
                    child: AppointmentSlotList(slots: state.selectedDaySlots),
                  ),
                ],
              );
            } else if (state is BookingCalendarFailure) {
              return Center(child: Text(state.errMessage));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
