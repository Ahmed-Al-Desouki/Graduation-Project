import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:graduation_project/features/doctor_home/presentation/manager/doctor_profile_cubit.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/doctor_profile_completion_view_body.dart';

class DoctorProfileCompletionView extends StatelessWidget {
  const DoctorProfileCompletionView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<DoctorProfileCubit>(),
      child: Scaffold(
        backgroundColor: const Color(0xfffaf0ff),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            "Complete The Profile",
            style: TextStyle(
              color: const Color(0xFF1B4E8C),
              fontSize: 25.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: const DoctorProfileCompletionViewBody(),
      ),
    );
  }
}
