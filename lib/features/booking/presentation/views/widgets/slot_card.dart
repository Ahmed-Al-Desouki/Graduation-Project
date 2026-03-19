// import 'package:flutter/material.dart';
// import '../../../domain/entities/slot_entity.dart';

// class SlotCard extends StatelessWidget {
//   final SlotEntity slot;
//   final VoidCallback? onConfirm;
//   final VoidCallback? onCancelByDoctor; // ✅ ميثود جديدة لكنسلة الدكتور

//   final VoidCallback? onDetails;
//   final VoidCallback? onDelete;
//   final VoidCallback? onBlock; // ✅ ميثود جديدة للبلوك
//   final bool isFollowUpMode; // ✅ لتحديد وضع المتابعة
//   final VoidCallback? onBookFollowUp; // ✅ ميثود جديدة لحجز المتابعة
//   // ✅ الإضافات الجديدة للمريض
//   final bool isPatientView;
//   final VoidCallback? onBook;

//   const SlotCard({
//     super.key,
//     required this.slot,
//     this.onConfirm,
//     this.onCancelByDoctor, // ✅ ميثود جديدة لكنسلة الدكتور
//     this.onDetails,
//     this.onDelete,
//     this.onBlock,
//     this.isFollowUpMode = false,
//     this.onBookFollowUp,
//     this.isPatientView = false, // الافتراضي دكتور
//     this.onBook,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       elevation: 0,
//       color: _getSlotColor().withOpacity(0.1), // لون خفيف حسب الحالة
//       child: ListTile(
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         leading: _buildTimeLeading(),
//         title: _buildTitle(),
//         subtitle:
//             (slot.patientName != null && !isPatientView)
//                 ? Text("Patient: ${slot.patientName}")
//                 : null,
//         trailing: _buildActions(),
//       ),
//     );
//   }

//   // تحديد اللون بناءً على الحالة
//   Color _getSlotColor() {
//     switch (slot.status.toLowerCase()) {
//       case 'available':
//         return Colors.green;
//       case 'pending':
//         return Colors.orange;
//       case 'booked':
//         return Colors.blue;
//       case 'inprogress':
//         return Colors.purple;
//       case 'blocked': // حالة الحظر
//       case 'cancelled': // حالة الإلغاء من الطبيب
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }

//   Widget _buildTimeLeading() {
//     // تفكيك الوقت (مثلاً لو جاي 14:30 يحوله لـ 02:30 PM)
//     final timeParts = slot.startTime.split(':');
//     int hour = int.parse(timeParts[0]);
//     String minute = timeParts[1];
//     String period = hour >= 12 ? "PM" : "AM";

//     // تحويل الساعة لنظام 12 ساعة
//     int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
//     String formattedHour = displayHour.toString().padLeft(2, '0');

//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Text(
//           "$formattedHour:$minute",
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//             color: Color(0xFF2D3142),
//           ),
//         ),
//         Text(
//           period,
//           style: const TextStyle(
//             fontSize: 10,
//             fontWeight: FontWeight.w600,
//             color: Colors.grey,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTitle() {
//     String status = slot.status.toLowerCase();

//     // ✅ لو مريض بيشوف المواعيد المحجوزة، تظهر له كلمة "Reserved" بس
//     if (isPatientView) {
//       if (status == 'available') {
//         return const Text(
//           "Available Slot",
//           style: TextStyle(fontWeight: FontWeight.bold),
//         );
//       }
//       return const Text(
//         "Reserved",
//         style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
//       );
//     }

//     String title = slot.status.toUpperCase();
//     if (slot.patientName != null) title = slot.patientName!;
//     return Text(title, style: const TextStyle(fontWeight: FontWeight.bold));
//   }

//   Widget _buildActions() {
//     final String status = slot.status.toLowerCase();

//     if (isPatientView) {
//       if (status == 'available') {
//         return ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.green,
//             foregroundColor: Colors.white,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(8),
//             ),
//           ),
//           onPressed: onBook,
//           child: const Text(
//             "Book Now",
//             style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
//           ),
//         );
//       }
//       return const SizedBox(); // مفيش أكشن للمريض على المواعيد المحجوزة
//     }

//     // 1. حالات "نهاية الطريق" - أحمر وبدون أكشنز
//     if (status == 'cancelled' || status == 'blocked') {
//       return const Padding(
//         padding: EdgeInsets.only(right: 8.0),
//         child: Text(
//           "No Actions",
//           style: TextStyle(
//             color: Colors.red,
//             fontSize: 12,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       );
//     }

//     // ✅ لو في وضع متابعة والسلوت متاح، اظهر زرار "Book Follow-up" فقط
//     if (isFollowUpMode && status == 'available') {
//       return ElevatedButton(
//         style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
//         onPressed: onBookFollowUp,
//         child: const Text(
//           "Book",
//           style: TextStyle(fontSize: 12, color: Colors.white),
//         ),
//       );
//     }

//     switch (status) {
//       case 'available':
//         // 2. سلوت فاضي - يقدر يمسحه أو يقفله
//         return Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             IconButton(
//               icon: const Icon(
//                 Icons.delete_forever,
//                 color: Colors.red,
//                 size: 22,
//               ),
//               onPressed: onDelete,
//               tooltip: 'Delete Slot',
//             ),
//             IconButton(
//               icon: const Icon(Icons.block, color: Colors.orange, size: 22),
//               onPressed: onBlock,
//               tooltip: 'Block Slot',
//             ),
//           ],
//         );

//       case 'booked':
//       case 'confirmed':
//       case 'pending': // دمجناهم كلهم في أكشن واحد
//       case 'completed':
//         // 3. موعد محجوز - زرار "التفاصيل" هو البطل هنا
//         // return Row(
//         //   mainAxisSize: MainAxisSize.min,
//         //   children: [
//         //     ElevatedButton(
//         //       style: ElevatedButton.styleFrom(
//         //         backgroundColor: Colors.blue,
//         //         foregroundColor: Colors.white,
//         //         padding: const EdgeInsets.symmetric(horizontal: 16),
//         //         shape: RoundedRectangleBorder(
//         //           borderRadius: BorderRadius.circular(8),
//         //         ),
//         //       ),
//         //       onPressed: onDetails, // هنا هيروح لصفحة الـ Details
//         //       child: const Text(
//         //         "Details",
//         //         style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
//         //       ),
//         //     ),
//         //     const SizedBox(width: 4),
//         //     IconButton(
//         //       icon: const Icon(
//         //         Icons.cancel_outlined,
//         //         color: Colors.redAccent,
//         //         size: 22,
//         //       ),
//         //       onPressed: onCancelByDoctor,
//         //       //  () {
//         //       //   // نداء ميثود كنسلة الدكتور (اللي بتبلوك الموعد)
//         //       //   context.read<AppointmentActionCubit>().doctorCancel(
//         //       //     slot.appointmentId!,
//         //       //     "Doctor Request",
//         //       //   );
//         //       // },
//         //       tooltip: 'Cancel Appointment',
//         //     ),
//         //   ],
//         // );
//         return Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor:
//                     status == 'completed'
//                         ? Colors.grey
//                         : Colors.blue, // لون مختلف للتمييز
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               onPressed: onDetails,
//               child: Text(
//                 status == 'completed' ? "View Report" : "Details", // نص مختلف
//                 style: const TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             if (status != 'completed') ...[
//               // ✅ لا تظهر زرار الكنسلة للمواعيد المنتهية
//               const SizedBox(width: 4),
//               IconButton(
//                 icon: const Icon(
//                   Icons.cancel_outlined,
//                   color: Colors.redAccent,
//                   size: 22,
//                 ),
//                 onPressed: onCancelByDoctor,
//                 tooltip: 'Cancel Appointment',
//               ),
//             ],
//           ],
//         );

//       case 'inprogress':
//         // 4. الدكتور شغال حالياً
//         return Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           decoration: BoxDecoration(
//             color: Colors.purple.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(color: Colors.purple),
//           ),
//           child: const Text(
//             "LIVE",
//             style: TextStyle(
//               color: Colors.purple,
//               fontWeight: FontWeight.bold,
//               fontSize: 10,
//             ),
//           ),
//         );

//       default:
//         return const Icon(Icons.check_circle, color: Colors.grey);
//     }
//   }
// }

// import 'package:flutter/material.dart';
// import '../../../domain/entities/slot_entity.dart';

// class SlotCard extends StatelessWidget {
//   final SlotEntity slot;
//   final bool isPatientView;
//   final bool isFollowUpMode;
//   final VoidCallback? onBook;
//   final VoidCallback? onDetails;
//   final VoidCallback? onDelete;
//   final VoidCallback? onBlock;
//   final VoidCallback? onCancelByDoctor;
//   final VoidCallback? onBookFollowUp;

//   const SlotCard({
//     super.key,
//     required this.slot,
//     this.isPatientView = false,
//     this.isFollowUpMode = false,
//     this.onBook,
//     this.onDetails,
//     this.onDelete,
//     this.onBlock,
//     this.onCancelByDoctor,
//     this.onBookFollowUp,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // 💡 تعريف المتغيرات واستخدامها لمنع الـ Warnings وتسهيل القراءة
//     final String status = slot.status.toLowerCase();
//     final bool isAvailable = status == 'available';
//     final bool isBooked = status == 'booked';
//     final bool isCompleted = status == 'completed';
//     final bool isBlocked = status == 'blocked';
//     final bool isCancelled = status == 'cancelled';

//     final Color statusColor = _getStatusColor(status);

//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//         border: Border.all(color: statusColor.withOpacity(0.1), width: 1.5),
//       ),
//       child: IntrinsicHeight(
//         child: Row(
//           children: [
//             // 1️⃣ وقت الموعد (على الشمال)
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     _formatOnlyTime(slot.startTime),
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w900,
//                       fontSize: 18,
//                       color: Color(0xFF1E293B),
//                     ),
//                   ),
//                   Text(
//                     _getAmPm(slot.startTime),
//                     style: TextStyle(
//                       color: Colors.grey.shade500,
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // 2️⃣ الخط الفاصل الملون بيمثل الحالة
//             Container(
//               width: 4,
//               margin: const EdgeInsets.symmetric(vertical: 12),
//               decoration: BoxDecoration(
//                 color: statusColor,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),

//             const SizedBox(width: 16),

//             // 3️⃣ بيانات الموعد (الوسط)
//             Expanded(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     _getTitle(isAvailable),
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 15,
//                       color: Color(0xFF1E293B),
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 4),
//                   _buildStatusBadge(statusColor, status),
//                 ],
//               ),
//             ),

//             // 4️⃣ الأزرار والأكشنز (على اليمين)
//             _buildActions(
//               isAvailable: isAvailable,
//               isBooked: isBooked,
//               isCompleted: isCompleted,
//               isBlocked: isBlocked,
//               isCancelled: isCancelled,
//             ),
//             const SizedBox(width: 8),
//           ],
//         ),
//       ),
//     );
//   }

//   // --- Widgets Helpers ---

//   String _getTitle(bool isAvailable) {
//     if (isPatientView) {
//       return isAvailable ? "Available Slot" : "Reserved";
//     }
//     return slot.patientName ?? "No Patient Assigned";
//   }

//   Widget _buildStatusBadge(Color color, String statusText) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Text(
//         statusText.toUpperCase(),
//         style: TextStyle(
//           color: color,
//           fontSize: 10,
//           fontWeight: FontWeight.w800,
//           letterSpacing: 0.5,
//         ),
//       ),
//     );
//   }

//   Widget _buildActions({
//     required bool isAvailable,
//     required bool isBooked,
//     required bool isCompleted,
//     required bool isBlocked,
//     required bool isCancelled,
//   }) {
//     // حالة المريض
//     if (isPatientView) {
//       return isAvailable
//           ? ElevatedButton(
//             onPressed: onBook,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF10B981),
//               foregroundColor: Colors.white,
//               elevation: 0,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//             ),
//             child: const Text(
//               "Book",
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//           )
//           : const SizedBox();
//     }

//     // حالة الدكتور
//     if (isCancelled || isBlocked) {
//       return const Padding(
//         padding: EdgeInsets.only(right: 8.0),
//         child: Text(
//           "No Actions",
//           style: TextStyle(
//             color: Colors.grey,
//             fontSize: 11,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       );
//     }

//     if (isFollowUpMode && isAvailable) {
//       return IconButton(
//         onPressed: onBookFollowUp,
//         icon: const Icon(Icons.add_task, color: Colors.orange),
//       );
//     }

//     if (isAvailable) {
//       return Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           IconButton(
//             onPressed: onBlock,
//             icon: Icon(
//               Icons.block_flipped,
//               color: Colors.grey.shade400,
//               size: 22,
//             ),
//             tooltip: "Block",
//           ),
//           IconButton(
//             onPressed: onDelete,
//             icon: const Icon(
//               Icons.delete_outline,
//               color: Color(0xFFEF4444),
//               size: 22,
//             ),
//             tooltip: "Delete",
//           ),
//         ],
//       );
//     }

//     if (isBooked || isCompleted) {
//       return IconButton(
//         onPressed: onDetails,
//         icon: const Icon(
//           Icons.arrow_forward_ios,
//           color: Color(0xFF3B82F6),
//           size: 18,
//         ),
//       );
//     }

//     return const SizedBox();
//   }

//   // --- Logic Helpers ---

//   Color _getStatusColor(String status) {
//     switch (status) {
//       case 'available':
//         return const Color(0xFF10B981); // Emerald Green
//       case 'booked':
//         return const Color(0xFF3B82F6); // Bright Blue
//       case 'completed':
//         return const Color(0xFF8B5CF6); // Soft Purple
//       case 'blocked':
//         return const Color(0xFF94A3B8); // Slate Grey
//       case 'cancelled':
//         return const Color(0xFFEF4444); // Red
//       default:
//         return Colors.orange;
//     }
//   }

//   String _formatOnlyTime(String time) {
//     try {
//       final parts = time.split(':');
//       int hour = int.parse(parts[0]);
//       int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
//       return "${displayHour.toString().padLeft(2, '0')}:${parts[1]}";
//     } catch (e) {
//       return time;
//     }
//   }

//   String _getAmPm(String time) {
//     try {
//       return int.parse(time.split(':')[0]) >= 12 ? "PM" : "AM";
//     } catch (e) {
//       return "";
//     }
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:graduation_project/core/utils/helper/service_locator.dart';
// import 'package:graduation_project/core/utils/helper/session_manager.dart';
// import '../../../domain/entities/slot_entity.dart';

// class SlotCard extends StatelessWidget {
//   final SlotEntity slot;
//   final bool isPatientView;
//   final bool isFollowUpMode;
//   final VoidCallback? onBook;
//   final VoidCallback? onDetails;
//   final VoidCallback? onDelete;
//   final VoidCallback? onBlock;
//   final VoidCallback? onCancelByDoctor; // للدكتور
//   final VoidCallback? onCancelByPatient; // للمريض
//   final VoidCallback? onBookFollowUp;

//   const SlotCard({
//     super.key,
//     required this.slot,
//     this.isPatientView = false,
//     this.isFollowUpMode = false,
//     this.onBook,
//     this.onDetails,
//     this.onDelete,
//     this.onBlock,
//     this.onCancelByDoctor,
//     this.onCancelByPatient,
//     this.onBookFollowUp,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final String status = slot.status.toLowerCase();
//     final bool isAvailable = status == 'available';
//     final bool isBooked = status == 'booked' || status == 'confirmed';
//     final bool isCompleted = status == 'completed';
//     final bool isBlocked = status == 'blocked';

//     final Color statusColor = _getStatusColor(status);

//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//         border: Border.all(color: statusColor.withOpacity(0.1), width: 1.5),
//       ),
//       child: IntrinsicHeight(
//         child: Row(
//           children: [
//             _buildTimeLeading(),
//             _buildStatusIndicator(statusColor),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     _getTitle(isAvailable),
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 15,
//                       color: Color(0xFF1E293B),
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 4),
//                   _buildStatusBadge(statusColor, status),
//                 ],
//               ),
//             ),
//             // ✅ هنا الأكشنز اللي كانت ناقصة
//             _buildActions(
//               isAvailable: isAvailable,
//               isBooked: isBooked,
//               isCompleted: isCompleted,
//               isBlocked: isBlocked,
//             ),
//             const SizedBox(width: 10),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildActions({
//     required bool isAvailable,
//     required bool isBooked,
//     required bool isCompleted,
//     required bool isBlocked,
//   }) {
//     // 1️⃣ لو مريض بيشوف الكارت
//     if (isPatientView) {
//       if (isAvailable) {
//         return ElevatedButton(
//           onPressed: onBook,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: const Color(0xFF10B981),
//             foregroundColor: Colors.white,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//           child: const Text("Book"),
//         );
//       }
//       // ✅ لو المريض حاجز المعاد ده، يظهر له تفاصيل وإلغاء
//       if (isBooked) {
//         return Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             IconButton(
//               onPressed: onDetails,
//               icon: const Icon(Icons.info_outline, color: Colors.blue),
//             ),
//             IconButton(
//               onPressed: onCancelByPatient,
//               icon: const Icon(Icons.cancel_outlined, color: Colors.red),
//             ),
//           ],
//         );
//       }
//       return const SizedBox();
//     }

//     // 2️⃣ لو دكتور بيشوف الكارت
//     if (isAvailable) {
//       if (isFollowUpMode) {
//         return IconButton(
//           onPressed: onBookFollowUp,
//           icon: const Icon(Icons.add_task, color: Colors.orange),
//         );
//       }
//       return Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           IconButton(
//             onPressed: onBlock,
//             icon: const Icon(Icons.block, color: Colors.grey),
//           ),
//           IconButton(
//             onPressed: onDelete,
//             icon: const Icon(Icons.delete_outline, color: Colors.red),
//           ),
//         ],
//       );
//     }

//     if (isBooked) {
//       return Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           IconButton(
//             onPressed: onDetails,
//             icon: const Icon(Icons.visibility_outlined, color: Colors.blue),
//           ),
//           IconButton(
//             onPressed: onCancelByDoctor,
//             icon: const Icon(Icons.person_remove_outlined, color: Colors.red),
//           ),
//         ],
//       );
//     }

//     if (isCompleted) {
//       return IconButton(
//         onPressed: onDetails,
//         icon: const Icon(Icons.assessment_outlined, color: Colors.purple),
//       );
//     }

//     return const SizedBox();
//   }

//   // ... (بقيه الـ helpers: _buildTimeLeading, _buildStatusIndicator, _buildStatusBadge, _getStatusColor, _formatOnlyTime, _getAmPm بنفس الكود السابق) ...
//   // ضيفهم هنا عشان الفايل يشتغل معاك كامل.

//   String _getTitle(bool isAvailable) {
//     if (isPatientView)
//       return isAvailable ? "Available Slot" : "Your Appointment";
//     return slot.patientName ?? "No Patient Assigned";
//   }
// class SlotCard extends StatelessWidget {
//   final SlotEntity slot;
//   final bool isPatientView;
//   final bool isFollowUpMode;
//   final VoidCallback? onBook;
//   final VoidCallback? onDetails;
//   final VoidCallback? onCancelByDoctor;
//   final VoidCallback? onCancelByPatient;
//   final VoidCallback? onBlock;
//   final VoidCallback? onDelete;
//   final VoidCallback? onBookFollowUp;

//   const SlotCard({
//     super.key,
//     required this.slot,
//     this.isPatientView = false,
//     this.isFollowUpMode = false,
//     this.onBook,
//     this.onDetails,
//     this.onDelete,
//     this.onBlock,
//     this.onCancelByDoctor,
//     this.onCancelByPatient,
//     this.onBookFollowUp,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final currentUserId = getIt<SessionManager>().userId;
//     final String status = slot.status.toLowerCase();
//     final bool isAvailable = status == 'available';
//     final bool isBooked = status == 'booked' || status == 'confirmed';

//     // 🛡️ فلتر الخصوصية: هل أنا صاحب الموعد؟
//     final bool isMyAppointment =
//         isPatientView && slot.patientId == currentUserId;

//     final Color statusColor = _getStatusColor(status);

//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//         border: Border.all(color: statusColor.withOpacity(0.1), width: 1.5),
//       ),
//       child: IntrinsicHeight(
//         child: Row(
//           children: [
//             _buildTimeLeading(),
//             _buildStatusIndicator(statusColor),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     _getTitle(isAvailable, isMyAppointment),
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 15,
//                       color: Color(0xFF1E293B),
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   _buildStatusBadge(statusColor, status),
//                 ],
//               ),
//             ),
//             _buildActions(
//               isAvailable: isAvailable,
//               isBooked: isBooked,
//               isMyAppointment: isMyAppointment,
//             ),
//             const SizedBox(width: 10),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildActions({
//     required bool isAvailable,
//     required bool isBooked,
//     required bool isMyAppointment,
//   }) {
//     if (isPatientView) {
//       if (isAvailable) {
//         return ElevatedButton(
//           onPressed: onBook, // 👈 لما onBook يجيله فانكشن من الأب، هينور أخضر
//           style: ElevatedButton.styleFrom(
//             backgroundColor: const Color(0xFF10B981),
//             foregroundColor: Colors.white,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//           child: const Text("Book"),
//         );
//       }

//       // ✅ الأزرار دي مش هتظهر للمريض إلا لو الموعد بتاعه هو بس
//       if (isBooked && isMyAppointment) {
//         return Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             IconButton(
//               onPressed: onDetails,
//               icon: const Icon(Icons.info_outline, color: Colors.blue),
//             ),
//             IconButton(
//               onPressed: onCancelByPatient,
//               icon: const Icon(Icons.cancel_outlined, color: Colors.red),
//             ),
//           ],
//         );
//       }
//       return const SizedBox();
//     }

//     // ... كود أكشنز الدكتور (شغال تمام) ...
//     if (isAvailable) {
//       return Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           IconButton(
//             onPressed: onBlock,
//             icon: const Icon(Icons.block, color: Colors.grey),
//           ),
//           IconButton(
//             onPressed: onDelete,
//             icon: const Icon(Icons.delete_outline, color: Colors.red),
//           ),
//         ],
//       );
//     }
//     if (isBooked) {
//       return Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           IconButton(
//             onPressed: onDetails,
//             icon: const Icon(Icons.visibility_outlined, color: Colors.blue),
//           ),
//           IconButton(
//             onPressed: onCancelByDoctor,
//             icon: const Icon(Icons.person_remove_outlined, color: Colors.red),
//           ),
//         ],
//       );
//     }
//     return const SizedBox();
//   }

//   String _getTitle(bool isAvailable, bool isMyAppointment) {
//     if (isPatientView) {
//       if (isAvailable) return "Available Slot";
//       if (isMyAppointment) return "Your Appointment";
//       return "Reserved"; // للمريض التاني
//     }
//     return slot.patientName ?? "No Patient Assigned";
//   }

//   Widget _buildTimeLeading() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             _formatOnlyTime(slot.startTime),
//             style: const TextStyle(
//               fontWeight: FontWeight.w900,
//               fontSize: 18,
//               color: Color(0xFF1E293B),
//             ),
//           ),
//           Text(
//             _getAmPm(slot.startTime),
//             style: const TextStyle(
//               color: Colors.grey,
//               fontSize: 12,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusIndicator(Color color) => Container(
//     width: 4,
//     margin: const EdgeInsets.symmetric(vertical: 12),
//     decoration: BoxDecoration(
//       color: color,
//       borderRadius: BorderRadius.circular(2),
//     ),
//   );

//   Widget _buildStatusBadge(Color color, String status) => Container(
//     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//     decoration: BoxDecoration(
//       color: color.withOpacity(0.1),
//       borderRadius: BorderRadius.circular(6),
//     ),
//     child: Text(
//       status.toUpperCase(),
//       style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900),
//     ),
//   );

//   Color _getStatusColor(String status) {
//     switch (status) {
//       case 'available':
//         return const Color(0xFF10B981);
//       case 'booked':
//       case 'confirmed':
//         return const Color(0xFF3B82F6);
//       case 'completed':
//         return Colors.purple;
//       case 'blocked':
//         return Colors.grey;
//       case 'cancelled':
//         return Colors.red;
//       default:
//         return Colors.orange;
//     }
//   }

//   String _formatOnlyTime(String time) {
//     final parts = time.split(':');
//     int hour = int.parse(parts[0]);
//     int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
//     return "${displayHour.toString().padLeft(2, '0')}:${parts[1]}";
//   }

//   String _getAmPm(String time) =>
//       int.parse(time.split(':')[0]) >= 12 ? "PM" : "AM";
// }

import 'package:flutter/material.dart';
import '../../../domain/entities/slot_entity.dart';

import 'package:flutter/material.dart';
import '../../../domain/entities/slot_entity.dart';

class SlotCard extends StatelessWidget {
  final SlotEntity slot;
  final bool isPatientView;
  final bool isFollowUpMode;
  final VoidCallback? onBook;
  final VoidCallback? onDetails;
  final VoidCallback? onCancelByDoctor;
  final VoidCallback? onCancelByPatient;
  final VoidCallback? onBlock;
  final VoidCallback? onDelete;
  final VoidCallback? onBookFollowUp;

  const SlotCard({
    super.key,
    required this.slot,
    this.isPatientView = false,
    this.isFollowUpMode = false,
    this.onBook,
    this.onDetails,
    this.onDelete,
    this.onBlock,
    this.onCancelByDoctor,
    this.onCancelByPatient,
    this.onBookFollowUp,
  });

  @override
  Widget build(BuildContext context) {
    // 🧹 تنظيف الحالة وتحضيرها للمقارنة
    final String status = slot.status.trim().toLowerCase();
    final bool isAvailable = status == 'available';
    final bool isBooked = status == 'booked' || status == 'confirmed';
    final bool isCompleted = status == 'completed';
    final bool isBlocked = status == 'blocked';
    final bool isCancelled = status == 'cancelled';

    final Color statusColor = _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: statusColor.withOpacity(0.1), width: 1.5),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // 1️⃣ عمود الوقت (02:30 PM)
            _buildTimeLeading(),

            // 2️⃣ المؤشر الملون (نفس لون الحالة)
            Container(
              width: 4,
              margin: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(width: 16),

            // 3️⃣ البيانات النصية (العنوان والـ Badge)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getTitle(status),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  _buildStatusBadge(statusColor, status),
                ],
              ),
            ),

            // 4️⃣ منطقة الأزرار (Actions)
            _buildActions(
              isAvailable: isAvailable,
              isBooked: isBooked,
              isCompleted: isCompleted,
              isBlocked: isBlocked,
              isCancelled: isCancelled,
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }

  // --- Widgets Helpers ---

  Widget _buildActions({
    required bool isAvailable,
    required bool isBooked,
    required bool isCompleted,
    required bool isBlocked,
    required bool isCancelled,
  }) {
    if (isPatientView) {
      if (isAvailable) {
        return ElevatedButton(
          onPressed: onBook, // هينور أخضر لأننا بنبعت الفانكشن من الأب دايماً
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            "Book",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      }
      return const SizedBox(); // المريض ميقدرش يعمل حاجة لو الموعد محجوز (Reserved)
    }

    // --- حالة الطبيب ---
    if (isAvailable) {
      if (isFollowUpMode) {
        return IconButton(
          onPressed: onBookFollowUp,
          icon: const Icon(Icons.add_task, color: Colors.orange),
        );
      }
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onBlock,
            icon: const Icon(Icons.block, color: Color(0xFF94A3B8), size: 22),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_outline,
              color: Color(0xFFEF4444),
              size: 22,
            ),
          ),
        ],
      );
    }

    if (isBooked || isCompleted) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onDetails,
            icon: const Icon(
              Icons.visibility_outlined,
              color: Color(0xFF3B82F6),
              size: 22,
            ),
          ),
          if (!isCompleted) // الدكتور يقدر يكنسل المحجوز بس مش المكتمل
            IconButton(
              onPressed: onCancelByDoctor,
              icon: const Icon(
                Icons.delete_outline,
                color: Color(0xFFEF4444),
                size: 22,
              ),
            ),
        ],
      );
    }

    return const SizedBox();
  }

  String _getTitle(String status) {
    if (isPatientView) {
      if (status == 'available') return "Available Slot";
      if (status == 'blocked') return "Unavailable";
      if (status == 'completed') return "Past Session";
      return "Reserved";
    }
    // للدكتور
    if (status == 'available') return "No Patient Assigned";
    if (status == 'blocked') return "Time Blocked";
    return slot.patientName ?? "Reserved Session";
  }

  Widget _buildStatusBadge(Color color, String statusText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        statusText.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'available':
        return const Color(0xFF10B981); // Emerald Green
      case 'booked':
      case 'confirmed':
        return const Color(0xFF3B82F6); // Bright Blue
      case 'completed':
        return const Color(0xFF8B5CF6); // Modern Purple
      case 'blocked':
        return const Color(0xFF94A3B8); // Slate Grey
      case 'cancelled':
        return const Color(0xFFEF4444); // Soft Red
      default:
        return Colors.orange;
    }
  }

  Widget _buildTimeLeading() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _formatOnlyTime(slot.startTime),
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: Color(0xFF1E293B),
            ),
          ),
          Text(
            _getAmPm(slot.startTime),
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatOnlyTime(String time) {
    try {
      final parts = time.split(':');
      int hour = int.parse(parts[0]);
      int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return "${displayHour.toString().padLeft(2, '0')}:${parts[1]}";
    } catch (e) {
      return time;
    }
  }

  String _getAmPm(String time) {
    try {
      return int.parse(time.split(':')[0]) >= 12 ? "PM" : "AM";
    } catch (e) {
      return "";
    }
  }
}
