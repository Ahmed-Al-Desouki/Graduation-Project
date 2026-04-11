import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/features/booking/data/models/appointment_full_details_model.dart';
import 'package:graduation_project/features/booking/domain/entities/appointment_full_details_entity.dart';

// class AppointmentListItem extends StatelessWidget {
//   final AppointmentFullDetailsEntity appointment;
//   final bool isDoctor; // بنعرفه مين اللي بيتفرج
//   final VoidCallback onTap;
//   final VoidCallback? onCancel; // ميثود الإلغاء

//   const AppointmentListItem({
//     super.key,
//     required this.appointment,
//     required this.isDoctor,
//     required this.onTap,
//     this.onCancel,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: EdgeInsets.only(bottom: 12.h),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
//       elevation: 0,
//       color: Colors.white,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(16.r),
//         child: Padding(
//           padding: EdgeInsets.all(16.w),
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   CircleAvatar(
//                     radius: 25.r,
//                     backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
//                     child: Icon(
//                       Icons.person,
//                       color: const Color(0xFF2563EB),
//                       size: 24.sp,
//                     ),
//                   ),
//                   SizedBox(width: 12.w),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           // ✅ لو دكتور اظهر اسم المريض، لو مريض اظهر اسم الدكتور
//                           isDoctor
//                               ? appointment.patientName
//                               : appointment.doctorName,
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16.sp,
//                           ),
//                         ),
//                         SizedBox(height: 4.h),
//                         Text(
//                           "Consultation • ${appointment.appointmentDate.toString().split(' ')[0]}",
//                           style: TextStyle(color: Colors.grey, fontSize: 13.sp),
//                         ),
//                       ],
//                     ),
//                   ),
//                   // ليبل الحالة
//                   _buildStatusBadge(appointment.status),
//                 ],
//               ),

//               // جوه الـ AppointmentListItem
//               if (appointment.status.toLowerCase() == 'pending')
//                 Padding(
//                   padding: EdgeInsets.only(top: 10.h),
//                   child: SizedBox(
//                     width: double.infinity,
//                     child: TextButton.icon(
//                       icon: const Icon(
//                         Icons.cancel_outlined,
//                         color: Colors.red,
//                         size: 18,
//                       ),
//                       label: const Text(
//                         "Cancel Appointment",
//                         style: TextStyle(color: Colors.red),
//                       ),
//                       style: TextButton.styleFrom(
//                         backgroundColor: Colors.red.withOpacity(0.05),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10.r),
//                         ),
//                       ),
//                       onPressed: onCancel,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStatusBadge(String status) {
//     Color color = Colors.blue;
//     if (status.toLowerCase() == 'cancelled') color = Colors.red;
//     if (status.toLowerCase() == 'completed') color = Colors.green;

//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(20.r),
//       ),
//       child: Text(
//         status,
//         style: TextStyle(
//           color: color,
//           fontSize: 12.sp,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
// }

class AppointmentListItem extends StatelessWidget {
  final AppointmentFullDetailsEntity appointment;
  final bool isDoctor;
  final VoidCallback onTap;
  final VoidCallback? onCancel;
  final bool showCancelButton;

  const AppointmentListItem({
    super.key,
    required this.appointment,
    required this.isDoctor,
    required this.onTap,
    this.onCancel,
    this.showCancelButton = true,
  });

  @override
  Widget build(BuildContext context) {
    bool isCancelled = appointment.status.toLowerCase() == 'cancelled';
    bool isPending = appointment.status.toLowerCase() == 'pending';

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      elevation: 0,
      color: Colors.white,
      child: InkWell(
        onTap: onTap, // ✅ شغال لكل الحالات بما فيهم الملغي
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25.r,
                    backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      color: const Color(0xFF2563EB),
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isDoctor
                              ? appointment.patientName
                              : appointment.doctorName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "Consultation • ${appointment.appointmentDate.toString().split(' ')[0]}",
                          style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                        ),
                        Text(
                          "${appointment.startTime} - ${appointment.endTime}",
                          style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                        ),
                      ],
                    ),
                  ),
                  // ✅ الـ Badge و السهم
                  Row(
                    children: [
                      _buildStatusBadge(appointment.status),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14.sp,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                ],
              ),
              // ✅ زرار الكانسل (يظهر فقط لو مريض والحالة Pending)
              if (showCancelButton && isPending)
                Padding(
                  padding: EdgeInsets.only(top: 12.h),
                  child: SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      icon: const Icon(
                        Icons.cancel_outlined,
                        color: Colors.red,
                        size: 18,
                      ),
                      label: const Text(
                        "Cancel Appointment",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.05),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      onPressed: onCancel,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.blue;
    if (status.toLowerCase() == 'cancelled') color = Colors.red;
    if (status.toLowerCase() == 'completed') color = Colors.green;
    if (status.toLowerCase() == 'inprogress') color = Colors.orange;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
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
