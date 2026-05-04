import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/functions/show_snack_bar.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:graduation_project/core/utils/helper/session_manager.dart';
import 'package:graduation_project/features/booking/domain/entities/slot_entity.dart';
import 'package:graduation_project/features/booking/presentation/views/add_manual_slot_sheet.dart';
import 'package:graduation_project/features/chat/domain/entities/chat_entity.dart';

import 'widgets/slot_card.dart';
import 'widgets/calendar_legend_section.dart';
import 'widgets/add_slot_bottom_button.dart';
import 'widgets/follow_up_banner.dart';
import 'widgets/slots_empty_state.dart';
import 'widgets/booking_confirm_dialog.dart';
import 'widgets/doctor_calendar_widget.dart';
import 'widgets/calendar_summary_section.dart';

import '../manager/booking_calendar_cubit/booking_calendar_cubit.dart';
import '../manager/appointment_action_cubit/appointment_action_cubit.dart';

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
  String? _getDisplayName;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    final String targetDoctorId =
        widget.isPatientView
            ? widget.doctorId!
            : getIt<SessionManager>().userId;
    _getDisplayName = getIt<SessionManager>().userName;

    _fetchMonthData(DateTime.now());

    _activeFollowUpId = widget.originalAppointmentId;
    _activeFollowUpPatientName = widget.followUpPatientName;
  }

  void _fetchMonthData(DateTime month) {
    final String targetId =
        widget.isPatientView
            ? widget.doctorId!
            : getIt<SessionManager>().userId;
    context.read<BookingCalendarCubit>().getMonthlyCalendar(
      targetId,
      DateTime(month.year, month.month, 1),
      DateTime(month.year, month.month + 1, 0),
      targetDate: month,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocListener<AppointmentActionCubit, AppointmentActionState>(
          listener: _handleAppointmentActions,
          child: BlocBuilder<BookingCalendarCubit, BookingCalendarState>(
            builder: (context, state) {
              if (state is BookingCalendarLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is BookingCalendarSuccess) {
                return Stack(
                  children: [
                    _buildMainContent(state),
                    if (!widget.isPatientView) _buildBottomButton(state),
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

  void _handleAppointmentActions(
    BuildContext context,
    AppointmentActionState state,
  ) {
    if (state is AppointmentActionSuccess) {
      showSnackBar(context, state.message, Colors.green);
      _resetFollowUpMode();
      _fetchMonthData(_focusedDay);
    } else if (state is AppointmentActionFailure) {
      showSnackBar(context, state.errMessage, Colors.red);
    } else if (state is PaymentNavigatedToWebView) {
      _handlePaymentNavigation(state);
    }
  }

  void _resetFollowUpMode() {
    if (_activeFollowUpId != null) {
      setState(() {
        _activeFollowUpId = null;
        _activeFollowUpPatientName = null;
      });
    }
  }

  Future<void> _handlePaymentNavigation(PaymentNavigatedToWebView state) async {
    final dynamic result = await context.push(
      AppRouter.kPaymentWebView,
      extra: state.url,
    );
    if (result is String) {
      _createChatAndNavigateSuccess(state.bookingData);
    } else {
      showSnackBar(context, "Payment was not completed.", Colors.orange);
    }
  }

  void _createChatAndNavigateSuccess(Map<String, dynamic> data) {
    final String doctorId = data['doctorId'].toString();
    final patientId = getIt<SessionManager>().userId;

    context.read<AppointmentActionCubit>().createFirebaseChat(
      ChatEntity(
        chatId: "doc_${doctorId}_pat_$patientId",
        doctorId: doctorId,
        patientId: patientId,
        doctorName: data['doctorName'] ?? 'Doctor',
        patientName: getIt<SessionManager>().userName,
        isActive: true,
        lastMessage: 'Consultation started',
        lastMessageTime: DateTime.now(),
      ),
    );
    context.push(AppRouter.kBookingSuccess, extra: data);
  }

  Widget _buildMainContent(BookingCalendarSuccess state) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildAppBar(),
        SliverToBoxAdapter(
          child: Column(
            children: [
              if (_activeFollowUpPatientName != null)
                FollowUpBanner(
                  patientName: _activeFollowUpPatientName!,
                  onClose: () => context.go(AppRouter.kHomeDoctor),
                ),
              if (!widget.isPatientView)
                CalendarSummarySection(allDays: state.allDays),
              DoctorCalendarWidget(
                focusedDay: _focusedDay,
                allDays: state.allDays,
                selectedDay: _selectedDay,
                onDaySelected: (date) {
                  setState(() => _selectedDay = date);
                  context.read<BookingCalendarCubit>().selectDate(date);
                },
                onPageChanged: (focusedDay) {
                  setState(() => _focusedDay = focusedDay);
                  _fetchMonthData(focusedDay);
                },
              ),
              const CalendarLegendSection(),
              const Divider(height: 30, indent: 20, endIndent: 20),
              _buildSlotsHeader(state),
            ],
          ),
        ),
        _buildSlotsList(state),
      ],
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.black,
          size: 20,
        ),
        onPressed: () => context.pop(),
      ),
      title: _buildAppBarTitle(),
      centerTitle: true,
      actions: [
        if (!widget.isPatientView) _buildDoctorMenu(),
        const SizedBox(width: 8),
      ],
    );
  }
  // Widget _buildAppBar() {
  //   return SliverAppBar(
  //     pinned: true,
  //     backgroundColor: Colors.white,
  //     elevation: 0.5,
  //     leading: IconButton(
  //       icon: const Icon(
  //         Icons.arrow_back_ios_new,
  //         color: Colors.black,
  //         size: 20,
  //       ),
  //       onPressed: () {
  //         // 💡 بدلاً من pop()، بنستخدم go() للمسار الصحيح
  //         if (widget.isPatientView) {
  //           context.go(AppRouter.kHomePatient);
  //         } else {
  //           context.go(AppRouter.kHomeDoctor);
  //         }
  //       },
  //     ),
  //     title: _buildAppBarTitle(),
  //     centerTitle: true,
  //     actions: [
  //       if (!widget.isPatientView) _buildDoctorMenu(),
  //       const SizedBox(width: 8),
  //     ],
  //   );
  // }

  Widget _buildSlotsList(BookingCalendarSuccess state) {
    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 120),
      sliver:
          state.selectedDaySlots.isEmpty
              ? const SliverFillRemaining(
                hasScrollBody: false,
                child: SlotsEmptyState(),
              )
              : SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final slot = state.selectedDaySlots[index];
                  return SlotCard(
                    slot: slot,
                    isPatientView: widget.isPatientView,
                    isFollowUpMode: _activeFollowUpId != null,
                    onBook: () => _showBookingConfirmDialog(slot),
                    onDetails: () => _navigateToDetails(slot),
                    onDelete:
                        () => context
                            .read<AppointmentActionCubit>()
                            .deleteAvailableSlot(slot.slotId),
                    onBlock:
                        () => context
                            .read<AppointmentActionCubit>()
                            .blockAvailableSlot(slot.slotId),
                    unblock:
                        () => context
                            .read<AppointmentActionCubit>()
                            .restoreSlot(slot.slotId),
                    onCancelByDoctor: () => _showCancelConfirmDialog(slot),
                    onBookFollowUp: () => _bookFollowUp(slot),
                  );
                }, childCount: state.selectedDaySlots.length),
              ),
    );
  }

  void _showBookingConfirmDialog(SlotEntity slot) {
    showDialog(
      context: context,
      builder:
          (dContext) => BlocProvider.value(
            value: context.read<AppointmentActionCubit>(),
            child: BookingConfirmDialog(
              slot: slot,
              doctorName: widget.doctorName ?? "Doctor",
              consultationFee: widget.consultationFee ?? 0.0,
            ),
          ),
    );
  }

  void _navigateToDetails(SlotEntity slot) {
    context.push(
      AppRouter.kMedicalDetails,
      extra: {
        'appointmentId': slot.appointmentId,
        'patientName': slot.patientName,
        'status': slot.status,
        'patientNote': slot.patientNote,
      },
    );
  }

  void _bookFollowUp(SlotEntity slot) {
    context.read<AppointmentActionCubit>().bookFollowUp(
      originalId: _activeFollowUpId!,
      slotId: slot.slotId,
      instructions: "Routine follow-up",
    );
  }

  Widget _buildBottomButton(BookingCalendarSuccess state) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AddSlotBottomButton(
        isFollowUp: _activeFollowUpId != null,
        selectedDayTitle: state.selectedDayTitle,
        onPressed: () => _showAddManualSlotSheet(),
      ),
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

  Widget _buildAppBarTitle() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.isPatientView ? "Booking with" : "Welcome,",
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          _getDisplayName!,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorMenu() {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      icon: const Icon(Icons.more_vert, color: Colors.blue, size: 24),
      onSelected: (value) {
        if (value == 'agenda') {
          context.push(AppRouter.kAppointmentsCenter);
        } else if (value == 'setup') {
          context.push(AppRouter.kScheduleSetup, extra: {'isEditing': true});
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
                  Text("Agenda View", style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'setup',
              child: Row(
                children: [
                  Icon(Icons.settings_outlined, color: Colors.grey, size: 20),
                  SizedBox(width: 10),
                  Text("Schedule Settings", style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
    );
  }

  void _showCancelConfirmDialog(SlotEntity slot) {
    final appointmentCubit = context.read<AppointmentActionCubit>();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: appointmentCubit,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text("Cancel Appointment?"),
            content: const Text(
              "This will cancel the booking and block this slot permanently.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text("No", style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pop(dialogContext);
                  appointmentCubit.doctorCancel(
                    slot.appointmentId!,
                    "Doctor Request",
                  );
                },
                child: const Text(
                  "Yes, Cancel",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddManualSlotSheet() {
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
              originalAppointmentId: _activeFollowUpId,
            ),
          ),
    );
  }
}
