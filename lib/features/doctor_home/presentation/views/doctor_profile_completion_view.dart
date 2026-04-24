import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:graduation_project/features/doctor_home/presentation/manager/doctor_profile_cubit.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/doctor_profile_completion_view_body.dart';
import 'package:graduation_project/features/doctor_profile/domain/entities/doctor_profile_entity.dart';

class DoctorProfileCompletionView extends StatelessWidget {
  final DoctorProfileEntity? initialProfile;

  const DoctorProfileCompletionView({super.key, this.initialProfile});

  @override
  Widget build(BuildContext context) {
    final isEditing = initialProfile != null;

    return BlocProvider.value(
      value: getIt<DoctorProfileCubit>(),
      child: Scaffold(
        backgroundColor: const Color(0xfffaf0ff),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            isEditing ? 'Edit & Resubmit Profile' : 'Complete The Profile',
            style: TextStyle(
              color: const Color(0xFF1B4E8C),
              fontSize: 25.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: DoctorProfileCompletionViewBody(initialProfile: initialProfile),
      ),
    );
  }
}
