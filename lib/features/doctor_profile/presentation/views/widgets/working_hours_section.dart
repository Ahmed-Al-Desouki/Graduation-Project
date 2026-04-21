import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/utils/functions/format_time.dart';
import 'package:graduation_project/features/doctor_profile/presentation/manager/doctor_real_profile_cubit.dart';
import 'package:graduation_project/features/doctor_profile/presentation/manager/doctor_real_profile_state.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/working_hour_row.dart';

class WorkingHoursSection extends StatefulWidget {
  final int doctorId;
  const WorkingHoursSection({super.key, required this.doctorId});

  @override
  State<WorkingHoursSection> createState() => _WorkingHoursSectionState();
}

class _WorkingHoursSectionState extends State<WorkingHoursSection> {
  static const List<String> _allDays = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  @override
  void initState() {
    super.initState();
    // ✅ ننادي الـ API مرة واحدة فقط
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DoctorRealProfileCubit>().getDoctorSlotConfig(
        widget.doctorId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Working Hours",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              BlocBuilder<DoctorRealProfileCubit, DoctorRealProfileState>(
                builder: (context, state) {
                  if (state is GetSlotConfigLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (state is GetSlotConfigFailure) {
                    return Center(
                      child: Text(
                        state.errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final slots =
                      state is GetSlotConfigSuccess
                          ? state.slotConfigs
                          : context
                                  .read<DoctorRealProfileCubit>()
                                  .cachedSlots ??
                              [];

                  final slotMap = {
                    for (var slot in slots)
                      slot.dayName.toLowerCase().trim(): slot,
                  };

                  return Column(
                    children:
                        _allDays.asMap().entries.map((entry) {
                          final day = entry.value;
                          final slot = slotMap[day.toLowerCase().trim()];
                          final isLast = entry.key == _allDays.length - 1;

                          return Column(
                            children: [
                              WorkingHourRow(
                                day: day,
                                time:
                                    slot != null && slot.isActive
                                        ? '${formatTimeTo12Hour(slot.startTime)}  ->  ${formatTimeTo12Hour(slot.endTime)}'
                                        : 'Off',
                                isClosed: slot == null || !slot.isActive,
                              ),
                              if (!isLast) const SizedBox(height: 10),
                            ],
                          );
                        }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/working_hour_row.dart';

// class WorkingHoursSection extends StatelessWidget {
//   const WorkingHoursSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Card(
//         color: Colors.white,
//         elevation: 2,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: const [
//               Text(
//                 "Working Hours",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 20),

//               WorkingHourRow(
//                 day: "Sunday",
//                 time: "11:00 AM -> 7:00 PM",
//                 isClosed: false,
//               ),
//               SizedBox(height: 10),
//               WorkingHourRow(
//                 day: "Monday",
//                 time: "9:00 AM -> 6:00 PM",
//                 isClosed: false,
//               ),
//               SizedBox(height: 10),
//               WorkingHourRow(day: "Tuesday", time: "Off", isClosed: true),
//               SizedBox(height: 10),
//               WorkingHourRow(
//                 day: "Wednesday",
//                 time: "9:00 AM -> 6:00 PM",
//                 isClosed: false,
//               ),
//               SizedBox(height: 10),
//               WorkingHourRow(
//                 day: "Thursday",
//                 time: "9:00 AM -> 6:00 PM",
//                 isClosed: false,
//               ),
//               SizedBox(height: 10),
//               WorkingHourRow(
//                 day: "Friday",
//                 time: "9:00 AM -> 4:00 PM",
//                 isClosed: false,
//               ),
//               SizedBox(height: 10),
//               WorkingHourRow(day: "Saturday", time: "Off", isClosed: true),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
