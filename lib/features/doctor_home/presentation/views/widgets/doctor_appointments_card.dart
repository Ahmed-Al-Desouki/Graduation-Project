import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:graduation_project/features/booking/domain/entities/appointment_full_details_entity.dart';

// class DoctorAppointmentsCard extends StatelessWidget {
//   final String patientName;
//   final String time;
//   final String type;
//   final String image;
//   final String status;
//   final Color statusColor;
//   const DoctorAppointmentsCard({
//     super.key,
//     required this.patientName,
//     required this.time,
//     required this.type,
//     required this.image,
//     required this.status,
//     required this.statusColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 10.h),
//       padding: EdgeInsets.all(13.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.1),
//             blurRadius: 20,
//             spreadRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 33.r,
//             backgroundColor: Colors.grey.shade300,
//             child: SvgPicture.asset(
//               image,
//               height: 35.h,
//               width: 35.w,
//               colorFilter: const ColorFilter.mode(
//                 Color(0xFF754EA6),
//                 BlendMode.srcIn,
//               ),
//             ),
//           ),
//           SizedBox(width: 15.w),

//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Text(
//                       patientName,
//                       style: TextStyle(
//                         fontSize: 16.sp,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     const Spacer(),
//                     SizedBox(width: 4.w),
//                     Text(
//                       time,
//                       style: TextStyle(
//                         fontSize: 14.sp,
//                         color: Colors.black87,
//                         fontWeight: FontWeight.w900,
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 5.h),
//                 Row(
//                   children: [
//                     Text(
//                       type,
//                       style: TextStyle(
//                         fontSize: 12.sp,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                     const Spacer(),
//                     Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 8.w,
//                         vertical: 4.h,
//                       ),
//                       decoration: BoxDecoration(
//                         color: statusColor.withValues(alpha: 0.1),
//                         borderRadius: BorderRadius.circular(8.r),
//                       ),
//                       child: Text(
//                         status,
//                         style: TextStyle(
//                           color: statusColor,
//                           fontSize: 10.sp,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class DoctorAppointmentsCard extends StatelessWidget {
  final AppointmentFullDetailsEntity appointment;
  final VoidCallback onTap;

  const DoctorAppointmentsCard({
    super.key,
    required this.appointment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.only(bottom: 15.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25.r,
                backgroundColor: const Color(0xfff3e8ff),
                child: const Icon(Icons.person, color: Color(0xFF9333EA)),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.patientName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                    Text(
                      "Time: ${appointment.startTime}",
                      style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [_buildStatusBadge(appointment.status)],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'inprogress':
        color = Colors.blue;
        break;
      case 'completed':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
