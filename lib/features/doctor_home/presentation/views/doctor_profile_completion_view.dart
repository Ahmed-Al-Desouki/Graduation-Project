import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/doctor_profile_completion_view_body.dart';

class DoctorProfileCompletionView extends StatefulWidget {
  const DoctorProfileCompletionView({super.key});

  @override
  State<DoctorProfileCompletionView> createState() =>
      _DoctorProfileCompletionViewState();
}

class _DoctorProfileCompletionViewState
    extends State<DoctorProfileCompletionView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffaf0ff),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Complete The Profile",
          style: TextStyle(
            color: Color(0xFF1B4E8C),
            fontSize: 25.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: DoctorProfileCompletionViewBody(),
    );
  }
}
