import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/features/booking/data/models/appointment_full_details_model.dart';
import 'package:graduation_project/features/booking/domain/entities/appointment_full_details_entity.dart';
import 'package:graduation_project/features/booking/presentation/manager/appointments_center_cubit/appointment_center_cubit.dart';
import 'package:graduation_project/features/booking/presentation/views/widgets/appointment_list_item.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../core/utils/helper/service_locator.dart';
import '../../../../core/utils/helper/session_manager.dart';

class AppointmentsCenterView extends StatefulWidget {
  final List<AppointmentFullDetailsEntity>? initialAppointments;
  const AppointmentsCenterView({super.key, this.initialAppointments});

  @override
  State<AppointmentsCenterView> createState() => _AppointmentsCenterViewState();
}

class _AppointmentsCenterViewState extends State<AppointmentsCenterView> {
  String? selectedStatus;
  bool isSearching = false;
  final TextEditingController searchController = TextEditingController();
  DateTime? manualSelectedDate;
  late final bool isHistoryMode;

  @override
  void initState() {
    super.initState();
    isHistoryMode = widget.initialAppointments != null;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String role = getIt<SessionManager>().userRole;
    final bool isDoctor = role.toLowerCase() == 'doctor';

    final List<String> roleBasedStatuses =
        isDoctor
            ? ['Today', 'Pending', 'InProgress', 'Completed', 'Cancelled']
            : ['Pending', 'Completed', 'Cancelled'];

    return BlocProvider(
      create: (context) {
        final cubit = getIt<AppointmentsCenterCubit>();
        if (isHistoryMode) {
          cubit.loadPreFetchedAppointments(widget.initialAppointments!);
        } else {
          final bool isDoctor =
              getIt<SessionManager>().userRole.toLowerCase() == 'doctor';
          isDoctor
              ? cubit.getDoctorAppointments()
              : cubit.getPatientAppointments();
        }
        return cubit;
      },
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: const Color(0xfffaf0ff),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0.5,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () => context.pop(),
              ),
              title:
                  isSearching
                      ? TextField(
                        controller: searchController,
                        autofocus: true,
                        style: TextStyle(fontSize: 16.sp),
                        decoration: InputDecoration(
                          hintText:
                              isDoctor
                                  ? "Search by patient name..."
                                  : "Search by doctor name...",
                          border: InputBorder.none,
                        ),
                        onChanged:
                            (query) => context
                                .read<AppointmentsCenterCubit>()
                                .searchAppointments(query),
                      )
                      : Text(
                        isHistoryMode
                            ? "Medical History Visits"
                            : "Appointments Agenda",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              actions: [
                IconButton(
                  icon: Icon(
                    isSearching ? Icons.close : Icons.search,
                    color: const Color(0xFF2563EB),
                  ),
                  onPressed: () {
                    setState(() {
                      isSearching = !isSearching;
                      if (!isSearching) {
                        searchController.clear();
                        context
                            .read<AppointmentsCenterCubit>()
                            .searchAppointments('');
                      }
                    });
                  },
                ),
                if (isDoctor && manualSelectedDate != null && !isHistoryMode)
                  IconButton(
                    icon: const Icon(
                      Icons.calendar_today_rounded,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      setState(() => manualSelectedDate = null);
                      _refreshData(context, isDoctor);
                    },
                  ),
                if (isDoctor &&
                    !isSearching &&
                    manualSelectedDate == null &&
                    !isHistoryMode)
                  IconButton(
                    icon: const Icon(
                      Icons.calendar_month,
                      color: Color(0xFF2563EB),
                    ),
                    onPressed: () => _showDatePicker(context, isDoctor),
                  ),
              ],
            ),
            body: Column(
              children: [
                if (!isHistoryMode)
                  Container(
                    height: 60.h,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      itemCount: roleBasedStatuses.length,
                      itemBuilder: (context, index) {
                        final status = roleBasedStatuses[index];
                        final isSelected = selectedStatus == status;
                        return Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: ChoiceChip(
                            label: Text(status),
                            selected: isSelected,
                            onSelected: (val) {
                              setState(() {
                                selectedStatus = val ? status : null;
                                manualSelectedDate = null;
                              });
                              _refreshData(context, isDoctor);
                            },
                            selectedColor: const Color(0xFF2563EB),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                Expanded(
                  child: BlocBuilder<
                    AppointmentsCenterCubit,
                    AppointmentsCenterState
                  >(
                    builder: (context, state) {
                      if (state is AppointmentsCenterLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is AppointmentsCenterFailure) {
                        return Center(child: Text(state.errMessage));
                      }

                      if (state is AppointmentsCenterSuccess) {
                        if (state.appointments.isEmpty) {
                          return _buildEmptyState();
                        }

                        return RefreshIndicator(
                          onRefresh:
                              () async => _refreshData(context, isDoctor),
                          child: ListView.builder(
                            padding: EdgeInsets.all(16.w),
                            itemCount: state.appointments.length,
                            itemBuilder: (context, index) {
                              final item =
                                  state.appointments[index]
                                      as AppointmentFullDetailsModel;
                              return AppointmentListItem(
                                appointment: item,
                                isDoctor:
                                    isHistoryMode
                                        ? false
                                        : (getIt<SessionManager>().userRole
                                                .toLowerCase() ==
                                            'doctor'),
                                onTap:
                                    () => context.push(
                                      AppRouter.kMedicalDetails,

                                      extra: {
                                        'appointmentId': item.appointmentId,
                                        'patientId': item.patientId.toString(),
                                        'patientName': item.patientName,
                                        'doctorName': item.doctorName,
                                        'doctorSpecialty': 'General',
                                        'status': item.status,
                                        'patientNote': item.patientNotes,
                                        'isReadOnly': isHistoryMode,
                                      },
                                    ),
                                onCancel:
                                    () => _showCancelDialog(
                                      context,
                                      item.appointmentId,
                                      isDoctor,
                                    ),
                              );
                            },
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off : Icons.calendar_today_outlined,
            size: 64.sp,
            color: Colors.grey,
          ),
          SizedBox(height: 16.h),
          Text(
            isSearching
                ? "No results for '${searchController.text}'"
                : "No appointments found.",
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(
    BuildContext context,
    String appointmentId,
    bool isDoctor,
  ) {
    final TextEditingController reasonController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              "Cancel Appointment",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Please specify the reason for cancellation:"),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: reasonController,
                    validator:
                        (val) => val!.isEmpty ? "Reason is required" : null,
                    decoration: InputDecoration(
                      hintText: "Reason...",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text("Back"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    if (isDoctor) {
                      context.read<AppointmentsCenterCubit>().doctorCancel(
                        appointmentId,
                        reasonController.text,
                      );
                    } else {
                      context
                          .read<AppointmentsCenterCubit>()
                          .cancelAppointmentByPatient(
                            appointmentId,
                            reasonController.text,
                          );
                    }

                    Navigator.pop(dialogContext);
                  }
                },
                child: const Text(
                  "Confirm Cancel",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _showDatePicker(BuildContext context, bool isDoctor) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder:
          (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: Color(0xFF2563EB)),
            ),
            child: child!,
          ),
    );

    if (pickedDate != null && mounted) {
      setState(() => manualSelectedDate = pickedDate);
      _refreshData(context, isDoctor, date: pickedDate);
    }
  }

  void _refreshData(BuildContext context, bool isDoctor, {DateTime? date}) {
    DateTime? filterDate = date ?? manualSelectedDate;
    String? filterStatus = selectedStatus;

    if (selectedStatus == 'Today') {
      filterDate = DateTime.now();
      filterStatus = null;
    }

    if (isDoctor) {
      context.read<AppointmentsCenterCubit>().getDoctorAppointments(
        status: filterStatus,
        date: filterDate,
      );
    } else {
      context.read<AppointmentsCenterCubit>().getPatientAppointments(
        status: filterStatus,
      );
    }
  }
}
