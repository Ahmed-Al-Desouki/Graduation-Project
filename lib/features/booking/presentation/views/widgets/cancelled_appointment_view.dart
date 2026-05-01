import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CancelledAppointmentView extends StatelessWidget {
  final String cancelledBy;
  final String reason;

  const CancelledAppointmentView({
    super.key,
    required this.cancelledBy,
    required this.reason,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 60.h),
          Icon(
            Icons.event_busy_rounded,
            size: 100.sp,
            color: Colors.red.shade200,
          ),
          SizedBox(height: 20.h),
          const Text(
            "Appointment Cancelled",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              "This session was cancelled and no medical records were created.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          Text(
            "Cancelled By: $cancelledBy",
            style: TextStyle(fontSize: 14, color: Colors.red.shade400),
          ),
          const SizedBox(height: 8),
          Text(
            "Reason: $reason",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: Colors.red.shade300,
            ),
          ),
        ],
      ),
    );
  }
}
