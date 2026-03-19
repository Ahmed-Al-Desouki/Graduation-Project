// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:graduation_project/core/utils/app_router.dart';
// import 'package:graduation_project/core/utils/functions/show_snack_bar.dart';
// import 'package:graduation_project/core/utils/helper/service_locator.dart';
// import 'package:graduation_project/core/utils/helper/session_manager.dart';
// import 'package:graduation_project/features/booking/domain/entities/day_slots_entity.dart';
// import 'package:graduation_project/features/booking/presentation/manager/appointment_action_cubit/appointment_action_cubit.dart';
// import 'package:graduation_project/features/booking/presentation/views/add_manual_slot_sheet.dart';
// import 'package:graduation_project/features/booking/presentation/views/widgets/calendar_summary_section.dart';
// import '../manager/booking_calendar_cubit/booking_calendar_cubit.dart';
// import 'widgets/doctor_calendar_widget.dart';
// import 'widgets/appointment_slot_list.dart';
// import 'widgets/calendar_header.dart';

// // class BookingCalendarView extends StatefulWidget {
// //   final String? followUpPatientName;
// //   final String? originalAppointmentId;

// //   const BookingCalendarView({
// //     super.key,
// //     this.followUpPatientName,
// //     this.originalAppointmentId,
// //   });

// //   @override
// //   State<BookingCalendarView> createState() => _BookingCalendarViewState();
// // }

// class BookingCalendarView extends StatefulWidget {
//   final String? followUpPatientName;
//   final String? originalAppointmentId;

//   // ✅ الحقول الجديدة للمريض
//   final bool isPatientView;
//   final String? doctorId;
//   final String? doctorName;
//   final double? consultationFee;

//   const BookingCalendarView({
//     super.key,
//     this.followUpPatientName,
//     this.originalAppointmentId,
//     this.isPatientView = false, // القيمة الافتراضية دكتور
//     this.doctorId,
//     this.doctorName,
//     this.consultationFee,
//   });

//   @override
//   State<BookingCalendarView> createState() => _BookingCalendarViewState();
// }

// class _BookingCalendarViewState extends State<BookingCalendarView> {
//   DateTime _selectedDay = DateTime.now();
//   DateTime _focusedDay = DateTime.now(); // ✅ ضيف المتغير ده عشان يثبت الشهر
//   void _fetchMonthData(DateTime month) {
//     final String targetDoctorId =
//         widget.isPatientView
//             ? widget.doctorId!
//             : getIt<SessionManager>().userId;
//     context.read<BookingCalendarCubit>().getMonthlyCalendar(
//       targetDoctorId,
//       DateTime(month.year, month.month, 1),
//       DateTime(month.year, month.month + 1, 0),
//       targetDate:
//           month, // عشان يفتح على أول يوم في الشهر الجديد أو اليوم المختار
//     );
//   }

//   void _showAddManualSlotSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder:
//           (_) => BlocProvider.value(
//             value:
//                 context
//                     .read<
//                       AppointmentActionCubit
//                     >(), // عشان يقدر يشوف الكيوبت جوه الشيت
//             child: AddManualSlotSheet(
//               selectedDate: _selectedDay,
//               originalAppointmentId: widget.originalAppointmentId,
//             ),
//           ),
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     // جلب بيانات الشهر الحالي عند فتح الشاشة
//     final now = DateTime.now();
//     final String targetDoctorId =
//         widget.isPatientView
//             ? widget.doctorId!
//             : getIt<SessionManager>().userId;
//     context.read<BookingCalendarCubit>().getMonthlyCalendar(
//       targetDoctorId, // ID الدكتور
//       DateTime(now.year, now.month, 1),
//       DateTime(now.year, now.month + 1, 0),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final double screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       // floatingActionButton: FloatingActionButton.extended(
//       //   onPressed: () => _showAddManualSlotSheet(context),
//       //   label: const Text("Add Manual Slot"),
//       //   icon: const Icon(Icons.add_alarm),
//       //   backgroundColor: const Color(0xFF9333EA), // نفس لون التيم بتاعك
//       // ),
//       body: SafeArea(
//         child: BlocListener<AppointmentActionCubit, AppointmentActionState>(
//           listener: (context, state) async {
//             if (state is AppointmentActionSuccess) {
//               // 🥳 إظهار رسالة نجاح شيك
//               showSnackBar(context, state.message, Colors.green);

//               // 🔄 الخطوة السحرية: عمل ريفريش للكالندر أوتوماتيك
//               final now = DateTime.now();
//               context.read<BookingCalendarCubit>().getMonthlyCalendar(
//                 getIt<SessionManager>().userId,
//                 DateTime(_focusedDay.year, _focusedDay.month, 1),
//                 DateTime(_focusedDay.year, _focusedDay.month + 1, 0),
//                 targetDate: _selectedDay, // ابعت اليوم المختار عشان يفضل ظاهر
//               );
//             } else if (state is AppointmentActionFailure) {
//               // ❌ إظهار رسالة خطأ لو العملية فشلت
//               showSnackBar(context, state.errMessage, Colors.red);
//             }
//             if (state is PaymentNavigatedToWebView) {
//               // بنفتح الويب فيو وبنستنى النتيجة (true لو نجح، false لو كنسل)
//               final bool? isSuccess = await context.push<bool>(
//                 AppRouter.kPaymentWebView,
//                 extra: state.url,
//               );

//               if (isSuccess == true) {
//                 // 🥳 مبروك! المريض دفع
//                 showSnackBar(
//                   context,
//                   "Payment Successful! Your appointment is confirmed.",
//                   Colors.green,
//                 );

//                 // 🔄 تحديث الكالندر فوراً عشان يظهر الموعد المحجوز للمريض
//                 _fetchMonthData(_focusedDay);
//               } else {
//                 // ❌ المريض كنسل أو الدفع فشل
//                 showSnackBar(
//                   context,
//                   "Payment was not completed.",
//                   Colors.orange,
//                 );
//               }
//             }
//           },
//           child: BlocBuilder<BookingCalendarCubit, BookingCalendarState>(
//             builder: (context, state) {
//               if (state is BookingCalendarLoading) {
//                 return const Center(child: CircularProgressIndicator());
//               } else if (state is BookingCalendarSuccess) {
//                 return Column(
//                   children: [
//                     if (widget.followUpPatientName != null)
//                       _buildFollowUpBanner(),
//                     CalendarHeader(
//                       isPatientView: widget.isPatientView,
//                       doctorName: widget.doctorName,
//                     ),
//                     SizedBox(height: screenHeight * 0.01),

//                     // 2️⃣ ✅ الكروت الملخصة (أضفها هنا)
//                     if (!widget.isPatientView) // نظهرها للدكتور فقط
//                       CalendarSummarySection(allDays: state.allDays),

//                     SizedBox(height: screenHeight * 0.01),
//                     // الكالندر (الجزء الأوسط)
//                     // DoctorCalendarWidget(allDays: state.allDays),
//                     DoctorCalendarWidget(
//                       focusedDay: _focusedDay, // ✅ ابعت الـ focusedDay
//                       allDays: state.allDays,
//                       selectedDay: _selectedDay, // ابعت اليوم المختار
//                       onDaySelected: (date) {
//                         // لما يدوس على يوم
//                         setState(() => _selectedDay = date);
//                         // نادى الكيوبت عشان يفلتر المواعيد لليوم ده
//                         context.read<BookingCalendarCubit>().selectDate(date);
//                       },
//                       onPageChanged: (focusedDay) {
//                         // ✅ أول ما اليوزر يسحب للشهر الجاي، نجيب بياناته فوراً
//                         setState(() => _focusedDay = focusedDay);
//                         _fetchMonthData(focusedDay);
//                       },
//                     ),
//                     // 3️⃣ ضيف الجزء ده هنا (Legend + Selected Date)
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                       child: Column(
//                         children: [
//                           const SizedBox(height: 8),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceAround,
//                             children: [
//                               _buildLegendItem(Colors.green, "Available"),
//                               _buildLegendItem(
//                                 const Color(0xFF9333EA),
//                                 "Today",
//                               ), // نفس لون الـ 16 عندك
//                               _buildLegendItem(Colors.orange, "Selected"),
//                             ],
//                           ),
//                           const SizedBox(height: 16),
//                           Align(
//                             alignment: Alignment.centerLeft,
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   "Slots for: ${state.selectedDayTitle}",
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 18,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 // ✅ السطر الجديد لإظهار العد
//                                 Text(
//                                   "${state.selectedDaySlots.where((s) => s.status.toLowerCase() == 'available').length} Available Slots",
//                                   style: TextStyle(
//                                     color: Colors.green.shade600,
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const Divider(thickness: 1, height: 32),

//                     // قائمة المواعيد (الجزء السفلي)
//                     Expanded(
//                       child: AppointmentSlotList(
//                         slots: state.selectedDaySlots,
//                         // ✅ لازم نمرر القيم دي هنا عشان اللستة تشوفهم
//                         isFollowUpMode: widget.originalAppointmentId != null,
//                         originalAppointmentId: widget.originalAppointmentId,
//                         // ✅ الحقول الجديدة للستة
//                         isPatientView: widget.isPatientView,
//                         doctorName: widget.doctorName,
//                         consultationFee: widget.consultationFee,
//                       ),
//                     ),
//                     if (!widget.isPatientView)
//                       _buildBottomDockedButton(context, state.selectedDayTitle),
//                   ],
//                 );
//               } else if (state is BookingCalendarFailure) {
//                 return Center(child: Text(state.errMessage));
//               }
//               return const SizedBox();
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFollowUpBanner() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
//       color: Colors.orange.withOpacity(0.2),
//       child: Row(
//         children: [
//           const Icon(Icons.info_outline, color: Colors.orange, size: 20),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               "Booking follow-up for: ${widget.followUpPatientName}",
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Colors.orange,
//                 fontSize: 13,
//               ),
//             ),
//           ),
//           IconButton(
//             icon: const Icon(Icons.close, size: 18),
//             onPressed:
//                 () => context.go(AppRouter.kHomeDoctor), // إلغاء وضع المتابعة
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBottomDockedButton(
//     BuildContext context,
//     String selectedDayTitle,
//   ) {
//     // ✅ حددنا اللون هنا بناءً على وضع المتابعة
//     final buttonColor =
//         widget.originalAppointmentId != null
//             ? Colors.orange
//             : const Color(0xFF9333EA);

//     return Container(
//       padding: const EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.2),
//             spreadRadius: 1,
//             blurRadius: 5,
//             offset: const Offset(0, -3),
//           ),
//         ],
//       ),
//       child: ElevatedButton.icon(
//         onPressed: () => _showAddManualSlotSheet(context),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: buttonColor, // ✅ اللون اتحط هنا صح
//           foregroundColor: Colors.white,
//           minimumSize: const Size(double.infinity, 50),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           elevation: 0,
//         ),
//         icon: const Icon(Icons.add_circle_outline),
//         label: Text(
//           widget.originalAppointmentId != null
//               ? "Create Manual Follow-up"
//               : "Add Manual Slot for ${selectedDayTitle.split(',')[0]}",
//         ),
//       ),
//     );
//   }

//   // 4️⃣ ضيف الـ Helper Method دي في آخر الكلاس
//   Widget _buildLegendItem(Color color, String label) {
//     return Row(
//       children: [
//         Container(
//           width: 10,
//           height: 10,
//           decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//         ),
//         const SizedBox(width: 4),
//         Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
//       ],
//     );
//   }

//   // Widget _buildSummaryCard(String label, int count, Color color) {
//   //   return Expanded(
//   //     child: Container(
//   //       padding: const EdgeInsets.all(12),
//   //       decoration: BoxDecoration(
//   //         color: color.withOpacity(0.1),
//   //         borderRadius: BorderRadius.circular(16),
//   //         border: Border.all(color: color.withOpacity(0.2)),
//   //       ),
//   //       child: Column(
//   //         children: [
//   //           Text(
//   //             "$count",
//   //             style: TextStyle(
//   //               fontSize: 20,
//   //               fontWeight: FontWeight.bold,
//   //               color: color,
//   //             ),
//   //           ),
//   //           Text(
//   //             label,
//   //             style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
//   //           ),
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   // }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/functions/show_snack_bar.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:graduation_project/core/utils/helper/session_manager.dart';
import 'package:graduation_project/features/booking/presentation/manager/appointment_action_cubit/appointment_action_cubit.dart';
import 'package:graduation_project/features/booking/presentation/views/add_manual_slot_sheet.dart';
import 'package:graduation_project/features/booking/presentation/views/widgets/calendar_summary_section.dart';
import '../manager/booking_calendar_cubit/booking_calendar_cubit.dart';
import 'widgets/doctor_calendar_widget.dart';
import 'widgets/slot_card.dart';

class BookingCalendarView extends StatefulWidget {
  final String? followUpPatientName;
  final String? originalAppointmentId;
  final bool isPatientView;
  final String? doctorId;
  final String? doctorName;
  final double? consultationFee;

  const BookingCalendarView({
    super.key,
    this.followUpPatientName,
    this.originalAppointmentId,
    this.isPatientView = false,
    this.doctorId,
    this.doctorName,
    this.consultationFee,
  });

  @override
  State<BookingCalendarView> createState() => _BookingCalendarViewState();
}

class _BookingCalendarViewState extends State<BookingCalendarView> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  String? _activeFollowUpId;
  String? _activeFollowUpPatientName;

  String get _getDisplayName {
    if (widget.isPatientView) {
      return widget.doctorName ?? "Doctor";
    }
    final name = getIt<SessionManager>().userName;
    return (name != null && name.isNotEmpty) ? name : "Doctor";
  }

  void _fetchMonthData(DateTime month) {
    final String targetDoctorId =
        widget.isPatientView
            ? widget.doctorId!
            : getIt<SessionManager>().userId;
    context.read<BookingCalendarCubit>().getMonthlyCalendar(
      targetDoctorId,
      DateTime(month.year, month.month, 1),
      DateTime(month.year, month.month + 1, 0),
      targetDate: month,
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
            value: context.read<AppointmentActionCubit>(),
            child: AddManualSlotSheet(
              selectedDate: _selectedDay,
              // originalAppointmentId: widget.originalAppointmentId,
              originalAppointmentId: _activeFollowUpId,
            ),
          ),
    );
  }

  // ✅ ميثود عرض دايالوج الحجز (تم نقلها هنا لتشغيل الزرار)
  void _showBookingDialog(BuildContext context, var slot) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text("Confirm Booking"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Doctor: Dr. ${widget.doctorName}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("Time: ${slot.startTime}"),
                Text(
                  "Fees: ${widget.consultationFee} EGP",
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: reasonController,
                  decoration: InputDecoration(
                    hintText: "Reason for visit",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  context.read<AppointmentActionCubit>().createBookingAndPay(
                    slotId: slot.slotId,
                    reason: reasonController.text,
                    grantAccess: true,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Confirm & Pay"),
              ),
            ],
          ),
    );
  }

  @override
  void initState() {
    super.initState();
    print("🆔 Current User ID: ${getIt<SessionManager>().userId}");
    print("👤 Current User Name: ${getIt<SessionManager>().userName}");
    final now = DateTime.now();
    final String targetDoctorId =
        widget.isPatientView
            ? widget.doctorId!
            : getIt<SessionManager>().userId;
    context.read<BookingCalendarCubit>().getMonthlyCalendar(
      targetDoctorId,
      DateTime(now.year, now.month, 1),
      DateTime(now.year, now.month + 1, 0),
    );
    _activeFollowUpId = widget.originalAppointmentId;
    _activeFollowUpPatientName = widget.followUpPatientName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocListener<AppointmentActionCubit, AppointmentActionState>(
          listener: (context, state) async {
            if (state is AppointmentActionSuccess) {
              showSnackBar(context, state.message, Colors.green);
              if (_activeFollowUpId != null) {
                setState(() {
                  _activeFollowUpId = null;
                  _activeFollowUpPatientName = null;
                });
              }
              _fetchMonthData(_focusedDay);
            } else if (state is AppointmentActionFailure) {
              showSnackBar(context, state.errMessage, Colors.red);
            }
            if (state is PaymentNavigatedToWebView) {
              final bool? isSuccess = await context.push<bool>(
                AppRouter.kPaymentWebView,
                extra: state.url,
              );

              if (isSuccess == true) {
                showSnackBar(
                  context,
                  "Payment Successful! Your appointment is confirmed.",
                  Colors.green,
                );
                _fetchMonthData(_focusedDay);
              } else {
                showSnackBar(
                  context,
                  "Payment was not completed.",
                  Colors.orange,
                );
              }
            }
          },
          child: BlocBuilder<BookingCalendarCubit, BookingCalendarState>(
            builder: (context, state) {
              if (state is BookingCalendarLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is BookingCalendarSuccess) {
                return Stack(
                  children: [
                    CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverAppBar(
                          pinned: true,
                          expandedHeight: 65.0, // رجعناها لارتفاع منطقي
                          backgroundColor: Colors.white,
                          elevation: 0.5,
                          centerTitle: true,
                          leading: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.black,
                              size: 20,
                            ),
                            onPressed: () => context.pop(),
                          ),
                          title: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.isPatientView
                                    ? "Booking with"
                                    : "Welcome,",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                _getDisplayName,
                                style: const TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            if (!widget.isPatientView)
                              IconButton(
                                onPressed:
                                    () =>
                                        context.push(AppRouter.kScheduleSetup),
                                icon: const Icon(
                                  Icons.settings,
                                  color: Colors.blue,
                                  size: 24,
                                ),
                              ),
                            const SizedBox(width: 8),
                          ],
                        ),
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              // if (widget.followUpPatientName != null)
                              if (_activeFollowUpPatientName != null)
                                _buildFollowUpBanner(),
                              if (!widget.isPatientView) ...[
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Your Schedule",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                  ),
                                ),
                                CalendarSummarySection(allDays: state.allDays),
                              ],
                              DoctorCalendarWidget(
                                focusedDay: _focusedDay,
                                allDays: state.allDays,
                                selectedDay: _selectedDay,
                                onDaySelected: (date) {
                                  setState(() => _selectedDay = date);
                                  context
                                      .read<BookingCalendarCubit>()
                                      .selectDate(date);
                                },
                                onPageChanged: (focusedDay) {
                                  setState(() => _focusedDay = focusedDay);
                                  _fetchMonthData(focusedDay);
                                },
                              ),
                              _buildLegendSection(),
                              const Divider(
                                height: 30,
                                thickness: 1,
                                indent: 20,
                                endIndent: 20,
                              ),
                              _buildSlotsHeader(state),
                            ],
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.only(bottom: 120),
                          sliver:
                              state.selectedDaySlots.isEmpty
                                  ? SliverFillRemaining(
                                    hasScrollBody: false,
                                    child: _buildEmptyStateLottie(),
                                  )
                                  : SliverList(
                                    delegate: SliverChildBuilderDelegate((
                                      context,
                                      index,
                                    ) {
                                      final slot =
                                          state.selectedDaySlots[index];
                                      return SlotCard(
                                        slot: slot,
                                        isPatientView: widget.isPatientView,
                                        // isFollowUpMode:
                                        //     widget.originalAppointmentId !=
                                        //     null,
                                        isFollowUpMode:
                                            _activeFollowUpId != null,

                                        // ✅ الزتونة: السطر ده هو اللي هيشغل زرار الـ Book
                                        onBook:
                                            widget.isPatientView
                                                ? () => _showBookingDialog(
                                                  context,
                                                  slot,
                                                )
                                                : null,

                                        onDetails:
                                            () => context.push(
                                              AppRouter.kMedicalDetails,
                                              extra: {
                                                'appointmentId':
                                                    slot.appointmentId,
                                                'patientName': slot.patientName,
                                                'status': slot.status,
                                                'patientNote': slot.patientNote,
                                              },
                                            ),
                                        onDelete:
                                            () => context
                                                .read<AppointmentActionCubit>()
                                                .deleteAvailableSlot(
                                                  slot.slotId,
                                                ),
                                        onBlock:
                                            () => context
                                                .read<AppointmentActionCubit>()
                                                .blockAvailableSlot(
                                                  slot.slotId,
                                                ),
                                        onBookFollowUp:
                                            () => context
                                                .read<AppointmentActionCubit>()
                                                .bookFollowUp(
                                                  // originalId:
                                                  //     widget
                                                  //         .originalAppointmentId!,
                                                  originalId:
                                                      _activeFollowUpId!,
                                                  slotId: slot.slotId,
                                                  instructions:
                                                      "Routine follow-up",
                                                ),
                                        onCancelByDoctor: () {
                                          // 1️⃣ أول خطوة: خد نسخة من الكيوبت من الـ context بتاع الشاشة الأساسية
                                          final appointmentCubit =
                                              context
                                                  .read<
                                                    AppointmentActionCubit
                                                  >();

                                          showDialog(
                                            context: context,
                                            builder: (dialogContext) {
                                              // 2️⃣ ثاني خطوة: غلف الدايالوج بـ BlocProvider.value واديله النسخة اللي معانا
                                              return BlocProvider.value(
                                                value: appointmentCubit,
                                                child: AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                  ),
                                                  title: const Text(
                                                    "Cancel Appointment?",
                                                  ),
                                                  content: const Text(
                                                    "This will cancel the booking and block this slot permanently.",
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed:
                                                          () => Navigator.pop(
                                                            dialogContext,
                                                          ),
                                                      child: const Text(
                                                        "No",
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      style:
                                                          ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                Colors
                                                                    .red
                                                                    .shade50,
                                                            elevation: 0,
                                                          ),
                                                      onPressed: () {
                                                        Navigator.pop(
                                                          dialogContext,
                                                        );
                                                        // 3️⃣ استخدم النسخة اللي فوق مباشرة عشان تضمن إنها شغالة
                                                        appointmentCubit
                                                            .doctorCancel(
                                                              slot.appointmentId!,
                                                              "Doctor Request",
                                                            );
                                                      },
                                                      child: const Text(
                                                        "Yes, Cancel",
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      );
                                    }, childCount: state.selectedDaySlots.length),
                                  ),
                        ),
                      ],
                    ),
                    if (!widget.isPatientView)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: _buildBottomDockedButton(
                          context,
                          state.selectedDayTitle,
                        ),
                      ),
                  ],
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  // --- بقية الـ Widgets المساعدة ( Legend, SlotsHeader, etc.) يفضلوا زي ما هما ---
  // ...
  Widget _buildEmptyStateLottie() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(
          'assets/lottie/Not Found.json',
          width: 180,
          height: 180,
          errorBuilder:
              (context, error, stackTrace) =>
                  const Icon(Icons.event_busy, size: 80, color: Colors.grey),
        ),
        const SizedBox(height: 10),
        const Text(
          "No slots generated for this day.",
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildLegendSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          _buildLegendItem(const Color(0xFF10B981), "Available"),
          _buildLegendItem(const Color(0xFF3B82F6), "Full"),
          _buildLegendItem(const Color(0xFF94A3B8), "Blocked"),
          _buildLegendItem(const Color(0xFF9333EA), "Today"),
          _buildLegendItem(Colors.orange, "Selected"),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSlotsHeader(BookingCalendarSuccess state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Slots: ${state.selectedDayTitle.split(',')[0]}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "${state.selectedDaySlots.where((s) => s.status.toLowerCase() == 'available').length} Available",
              style: const TextStyle(
                color: Color(0xFF10B981),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomDockedButton(
    BuildContext context,
    String selectedDayTitle,
  ) {
    final buttonColor =
        // widget.originalAppointmentId != null
        _activeFollowUpId != null ? Colors.orange : const Color(0xFF9333EA);
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => _showAddManualSlotSheet(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.add_circle_outline),
        label: Text(
          // widget.originalAppointmentId != null
          _activeFollowUpId != null
              ? "Create Follow-up"
              : "Add Slot for ${selectedDayTitle.split(',')[0]}",
        ),
      ),
    );
  }

  Widget _buildFollowUpBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.orange.shade50,
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Follow-up: ${widget.followUpPatientName}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
                fontSize: 12,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: () => context.go(AppRouter.kHomeDoctor),
          ),
        ],
      ),
    );
  }
}
