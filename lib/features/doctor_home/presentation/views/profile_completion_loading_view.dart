import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:graduation_project/features/auth/presentation/manger/auth_cubit/auth_cubit.dart';
import 'package:graduation_project/features/doctor_home/domain/entities/doctor_profile_status_entity.dart';
import 'package:graduation_project/features/doctor_home/presentation/manager/doctor_profile_cubit.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/profile_completion_loading_content.dart';

class ProfileCompletionLoadingView extends StatelessWidget {
  final DoctorProfileStatusEntity? status;

  const ProfileCompletionLoadingView({super.key, this.status});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AuthCubit>()),
        BlocProvider.value(value: getIt<DoctorProfileCubit>()),
      ],
      child: ProfileCompletionLoadingContent(status: status),
    );
  }
}
