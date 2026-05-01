import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WaitingRoomView extends StatelessWidget {
  final bool isPatient;
  final String? patientNote;
  final VoidCallback? onStartSession;

  const WaitingRoomView({
    super.key,
    required this.isPatient,
    this.patientNote,
    this.onStartSession,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 40.h),
        _buildIcon(),
        SizedBox(height: 20.h),
        Text(
          isPatient ? "Waiting for Doctor" : "Ready to start the session?",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (isPatient)
          const Text(
            "The doctor will start the session shortly.",
            style: TextStyle(color: Colors.grey),
          ),
        SizedBox(height: 30.h),
        _buildNoteContainer(),
        if (!isPatient) ...[
          SizedBox(height: 40.h),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              minimumSize: Size(250.w, 55.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.r),
              ),
            ),
            onPressed: onStartSession,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text(
              "Start Session",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: (isPatient ? Colors.orange : Colors.blue).withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isPatient
            ? Icons.hourglass_empty_rounded
            : Icons.medical_services_outlined,
        size: 80,
        color: isPatient ? Colors.orange : Colors.blue,
      ),
    );
  }

  Widget _buildNoteContainer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology_alt,
                color: Colors.orange.shade700,
                size: 20,
              ),
              SizedBox(width: 8.w),
              Text(
                "Reason for Visit",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade900,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Text(
            patientNote?.isNotEmpty == true
                ? patientNote!
                : "No patient notes provided.",
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}
