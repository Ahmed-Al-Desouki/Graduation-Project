import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/features/booking/domain/entities/slot_entity.dart';
import 'package:graduation_project/features/chat/domain/entities/chat_entity.dart';
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
    return (name.isNotEmpty) ? name : "Doctor";
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

  void _showBookingDialog(BuildContext context, SlotEntity slot) {
    final reasonController = TextEditingController();
    bool grantAccess = true;
    String selectedPaymentMethod = 'Card';

    final appointmentCubit = context.read<AppointmentActionCubit>();

    showDialog(
      context: context,
      builder:
          (dialogContext) => BlocProvider.value(
            value: appointmentCubit,
            child: StatefulBuilder(
              builder:
                  (context, setDialogState) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    title: Row(
                      children: [
                        const Icon(
                          Icons.verified_outlined,
                          color: Colors.green,
                        ),
                        SizedBox(width: 10.w),
                        const Text("Confirm Booking"),
                      ],
                    ),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDialogInfoRow(
                            Icons.person_outline,
                            "Doctor",
                            "Dr. ${widget.doctorName}",
                          ),
                          _buildDialogInfoRow(
                            Icons.access_time,
                            "Time",
                            slot.startTime,
                          ),
                          _buildDialogInfoRow(
                            Icons.payments_outlined,
                            "Fees",
                            "${widget.consultationFee} EGP",
                            isPrice: true,
                          ),

                          const Divider(height: 30),

                          const Text(
                            "Reason for visit",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          TextField(
                            controller: reasonController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: "Enter symptoms...",
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            "Select Payment Method",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Wrap(
                            spacing: 8.w,
                            runSpacing: 8.h,
                            children:
                                paymentMethods.map((method) {
                                  final isSelected =
                                      selectedPaymentMethod == method['id'];
                                  return InkWell(
                                    onTap:
                                        () => setDialogState(
                                          () =>
                                              selectedPaymentMethod =
                                                  method['id'],
                                        ),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12.w,
                                        vertical: 8.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            isSelected
                                                ? const Color(
                                                  0xFF9333EA,
                                                ).withValues(alpha: 0.1)
                                                : Colors.white,
                                        borderRadius: BorderRadius.circular(
                                          10.r,
                                        ),
                                        border: Border.all(
                                          color:
                                              isSelected
                                                  ? const Color(0xFF9333EA)
                                                  : Colors.grey.shade300,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            method['icon'],
                                            size: 16.sp,
                                            color:
                                                isSelected
                                                    ? const Color(0xFF9333EA)
                                                    : Colors.grey,
                                          ),
                                          SizedBox(width: 6.w),
                                          Text(
                                            method['name'],
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color:
                                                  isSelected
                                                      ? const Color(0xFF9333EA)
                                                      : Colors.black87,
                                              fontWeight:
                                                  isSelected
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),

                          const SizedBox(height: 20),

                          Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF9333EA,
                              ).withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.history_edu,
                                  color: Color(0xFF9333EA),
                                  size: 20,
                                ),
                                SizedBox(width: 10.w),
                                const Expanded(
                                  child: Text(
                                    "Share Medical History",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Switch(
                                  value: grantAccess,
                                  activeThumbColor: const Color(0xFF9333EA),
                                  onChanged:
                                      (val) => setDialogState(
                                        () => grantAccess = val,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9333EA),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 12.h,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          context.read<AppointmentActionCubit>().bookAndPay(
                            slotId: slot.slotId,
                            reason: reasonController.text,
                            grantAccess: grantAccess,
                            paymentMethod: selectedPaymentMethod,
                          );
                        },
                        child: const Text(
                          "Confirm & Pay",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
            ),
          ),
    );
  }

  Widget _buildDialogInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isPrice = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: Colors.grey),
          SizedBox(width: 8.w),
          Text(
            "$label: ",
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isPrice ? Colors.blue : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    log(" Current User ID: ${getIt<SessionManager>().userId}");
    log(" Current User Name: ${getIt<SessionManager>().userName}");
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

  final List<Map<String, dynamic>> paymentMethods = [
    {'id': 'Card', 'name': 'Credit Card', 'icon': Icons.credit_card},
    {
      'id': 'VodafoneCash',
      'name': 'Vodafone Cash',
      'icon': Icons.account_balance_wallet,
    },
    {
      'id': 'EtisalatCash',
      'name': 'Etisalat Cash',
      'icon': Icons.account_balance_wallet_outlined,
    },
    {'id': 'OrangeCash', 'name': 'Orange Cash', 'icon': Icons.wallet},
    {'id': 'WePay', 'name': 'WE Pay', 'icon': Icons.payments},
    {'id': 'Valu', 'name': 'Valu', 'icon': Icons.install_mobile},
  ];

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
              // final bool? isSuccess = await context.push<bool>(
              //   AppRouter.kPaymentWebView,
              //   extra: state.url,
              // );
              final dynamic result = await context.push(
                AppRouter.kPaymentWebView,
                extra: state.url,
              );

              // if (isSuccess == true) {

              //   context.push(
              //     AppRouter.kBookingSuccess,
              //     extra: state.bookingData,
              //   );
              // }
              if (result is String) {
                // final String appointmentId = result;
                final data = state.bookingData;

                final String doctorId = data['doctorId'].toString();
                final patientId = getIt<SessionManager>().userId;
                final patientName = getIt<SessionManager>().userName;

                final String unifiedChatId = "doc_${doctorId}_pat_$patientId";

                context.read<AppointmentActionCubit>().createFirebaseChat(
                  ChatEntity(
                    chatId: unifiedChatId,
                    doctorId: data['doctorId'].toString(),
                    patientId: patientId,
                    doctorName: data['doctorName'] ?? 'Doctor',
                    patientName: patientName,
                    isActive: true,
                    lastMessage: 'Consultation started',
                    lastMessageTime: DateTime.now(),
                  ),
                );

                context.push(AppRouter.kBookingSuccess, extra: data);
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
                          expandedHeight: 65.0,
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
                          // actions: [
                          //   if (!widget.isPatientView)
                          //     IconButton(
                          //       onPressed:
                          //           () =>
                          //               context.push(AppRouter.kScheduleSetup),
                          //       icon: const Icon(
                          //         Icons.settings,
                          //         color: Colors.blue,
                          //         size: 24,
                          //       ),
                          //     ),
                          //   const SizedBox(width: 8),
                          // ],
                          actions: [
                            if (!widget.isPatientView)
                              PopupMenuButton<String>(
                                padding: EdgeInsets.zero,
                                icon: const Icon(
                                  Icons.more_vert,
                                  color: Colors.blue,
                                  size: 24,
                                ),
                                onSelected: (value) {
                                  if (value == 'agenda') {
                                    context.push(AppRouter.kAppointmentsCenter);
                                  } else if (value == 'setup') {
                                    context.push(AppRouter.kScheduleSetup);
                                  }
                                },
                                itemBuilder:
                                    (context) => [
                                      const PopupMenuItem(
                                        value: 'agenda',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.view_agenda_outlined,
                                              color: Colors.blue,
                                              size: 20,
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              "Agenda View",
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'setup',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.settings_outlined,
                                              color: Colors.grey,
                                              size: 20,
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              "Schedule Settings",
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                              ),
                            const SizedBox(width: 8),
                          ],
                        ),
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
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
                                              // extra: {
                                              //   'appointmentId':
                                              //       slot.appointmentId,
                                              //   'patientName': slot.patientName,
                                              //   'status': slot.status,
                                              //   'patientNote': slot.patientNote,
                                              // },
                                              extra: {
                                                'appointmentId':
                                                    slot.appointmentId,
                                                'patientId': null,
                                                'patientName': slot.patientName,
                                                'doctorName':
                                                    getIt<SessionManager>()
                                                        .userName,
                                                'status': slot.status,
                                                'patientNote': slot.patientNote,
                                                'isReadOnly': false,
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
                                                  originalId:
                                                      _activeFollowUpId!,
                                                  slotId: slot.slotId,
                                                  instructions:
                                                      "Routine follow-up",
                                                ),
                                        onCancelByDoctor: () {
                                          final appointmentCubit =
                                              context
                                                  .read<
                                                    AppointmentActionCubit
                                                  >();

                                          showDialog(
                                            context: context,
                                            builder: (dialogContext) {
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
        _activeFollowUpId != null ? Colors.orange : const Color(0xFF9333EA);
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
