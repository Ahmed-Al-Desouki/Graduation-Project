import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:graduation_project/features/patient_profile/presentation/manager/patient_account_profile_cubit.dart';
import 'package:graduation_project/features/patient_profile/presentation/views/widgets/patient_profile_view_body.dart';

class PatientProfileView extends StatelessWidget {
  const PatientProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PatientAccountProfileCubit>()..loadProfile(),
      child: Scaffold(
        backgroundColor: const Color(0xffE8F7F2),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Profile',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: const PatientProfileViewBody(),
      ),
    );
  }
}
