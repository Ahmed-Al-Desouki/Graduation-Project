import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/functions/show_snack_bar.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:graduation_project/core/utils/helper/session_manager.dart';
import 'package:graduation_project/features/booking/presentation/manager/appointment_action_cubit/appointment_action_cubit.dart';
import 'package:graduation_project/features/booking/presentation/views/add_manual_slot_sheet.dart';
import '../manager/booking_calendar_cubit/booking_calendar_cubit.dart';
import 'widgets/doctor_calendar_widget.dart';
import 'widgets/appointment_slot_list.dart';
import 'widgets/calendar_header.dart';

class BookingCalendarView extends StatefulWidget {
  final String? followUpPatientName;
  final String? originalAppointmentId;

  const BookingCalendarView({
    super.key,
    this.followUpPatientName,
    this.originalAppointmentId,
  });

  @override
  State<BookingCalendarView> createState() => _BookingCalendarViewState();
}

class _BookingCalendarViewState extends State<BookingCalendarView> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now(); // ✅ ضيف المتغير ده عشان يثبت الشهر
  void _fetchMonthData(DateTime month) {
    final String doctorId = getIt<SessionManager>().userId;
    context.read<BookingCalendarCubit>().getMonthlyCalendar(
      doctorId,
      DateTime(month.year, month.month, 1),
      DateTime(month.year, month.month + 1, 0),
      targetDate:
          month, // عشان يفتح على أول يوم في الشهر الجديد أو اليوم المختار
    );
  }

  void _showAddManualSlotSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => BlocProvider.value(
            value:
                context
                    .read<
                      AppointmentActionCubit
                    >(), // عشان يقدر يشوف الكيوبت جوه الشيت
            child: AddManualSlotSheet(
              selectedDate: _selectedDay,
              originalAppointmentId: widget.originalAppointmentId,
            ),
          ),
    );
  }

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
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () => _showAddManualSlotSheet(context),
      //   label: const Text("Add Manual Slot"),
      //   icon: const Icon(Icons.add_alarm),
      //   backgroundColor: const Color(0xFF9333EA), // نفس لون التيم بتاعك
      // ),
      body: SafeArea(
        child: BlocListener<AppointmentActionCubit, AppointmentActionState>(
          listener: (context, state) {
            if (state is AppointmentActionSuccess) {
              // 🥳 إظهار رسالة نجاح شيك
              showSnackBar(context, state.message, Colors.green);

              // 🔄 الخطوة السحرية: عمل ريفريش للكالندر أوتوماتيك
              final now = DateTime.now();
              context.read<BookingCalendarCubit>().getMonthlyCalendar(
                getIt<SessionManager>().userId,
                DateTime(now.year, now.month, 1),
                DateTime(now.year, now.month + 1, 0),
                targetDate: _selectedDay, // ابعت اليوم المختار عشان يفضل ظاهر
              );
            } else if (state is AppointmentActionFailure) {
              // ❌ إظهار رسالة خطأ لو العملية فشلت
              showSnackBar(context, state.errMessage, Colors.red);
            }
          },
          child: BlocBuilder<BookingCalendarCubit, BookingCalendarState>(
            builder: (context, state) {
              if (state is BookingCalendarLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is BookingCalendarSuccess) {
                return Column(
                  children: [
                    if (widget.followUpPatientName != null)
                      _buildFollowUpBanner(),
                    const CalendarHeader(), // الجزء العلوي (Greeting + Settings)
                    SizedBox(height: screenHeight * 0.01),

                    // الكالندر (الجزء الأوسط)
                    // DoctorCalendarWidget(allDays: state.allDays),
                    DoctorCalendarWidget(
                      focusedDay: _focusedDay, // ✅ ابعت الـ focusedDay
                      allDays: state.allDays,
                      selectedDay: _selectedDay, // ابعت اليوم المختار
                      onDaySelected: (date) {
                        // لما يدوس على يوم
                        setState(() => _selectedDay = date);
                        // نادى الكيوبت عشان يفلتر المواعيد لليوم ده
                        context.read<BookingCalendarCubit>().selectDate(date);
                      },
                      onPageChanged: (focusedDay) {
                        // ✅ أول ما اليوزر يسحب للشهر الجاي، نجيب بياناته فوراً
                        setState(() => _focusedDay = focusedDay);
                        _fetchMonthData(focusedDay);
                      },
                    ),
                    // 3️⃣ ضيف الجزء ده هنا (Legend + Selected Date)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildLegendItem(Colors.green, "Available"),
                              _buildLegendItem(
                                const Color(0xFF9333EA),
                                "Today",
                              ), // نفس لون الـ 16 عندك
                              _buildLegendItem(Colors.orange, "Selected"),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Slots for: ${state.selectedDayTitle}", // هنخلي الكيوبت يبعت الاسم ده
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(thickness: 1, height: 32),

                    // قائمة المواعيد (الجزء السفلي)
                    Expanded(
                      child: AppointmentSlotList(
                        slots: state.selectedDaySlots,
                        // ✅ لازم نمرر القيم دي هنا عشان اللستة تشوفهم
                        isFollowUpMode: widget.originalAppointmentId != null,
                        originalAppointmentId: widget.originalAppointmentId,
                      ),
                    ),

                    _buildBottomDockedButton(context, state.selectedDayTitle),
                  ],
                );
              } else if (state is BookingCalendarFailure) {
                return Center(child: Text(state.errMessage));
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFollowUpBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: Colors.orange.withOpacity(0.2),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Booking follow-up for: ${widget.followUpPatientName}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
                fontSize: 13,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed:
                () => context.go(AppRouter.kHomeDoctor), // إلغاء وضع المتابعة
          ),
        ],
      ),
    );
  }

  Widget _buildBottomDockedButton(
    BuildContext context,
    String selectedDayTitle,
  ) {
    // ✅ حددنا اللون هنا بناءً على وضع المتابعة
    final buttonColor =
        widget.originalAppointmentId != null
            ? Colors.orange
            : const Color(0xFF9333EA);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => _showAddManualSlotSheet(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor, // ✅ اللون اتحط هنا صح
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.add_circle_outline),
        label: Text(
          widget.originalAppointmentId != null
              ? "Create Manual Follow-up"
              : "Add Manual Slot for ${selectedDayTitle.split(',')[0]}",
        ),
      ),
    );
  }

  // 4️⃣ ضيف الـ Helper Method دي في آخر الكلاس
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
