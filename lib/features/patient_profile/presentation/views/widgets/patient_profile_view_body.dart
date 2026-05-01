import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/utils/functions/show_snack_bar.dart';
import 'package:graduation_project/features/patient_profile/domain/entities/patient_account_profile_entity.dart';
import 'package:graduation_project/features/patient_profile/presentation/manager/patient_account_profile_cubit.dart';
import 'package:graduation_project/features/patient_profile/presentation/views/widgets/patient_info.dart';
import 'package:graduation_project/features/patient_profile/presentation/views/widgets/patient_profile_header.dart';

class PatientProfileViewBody extends StatelessWidget {
  const PatientProfileViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PatientAccountProfileCubit, PatientAccountProfileState>(
      listener: (context, state) {
        if (state is PatientAccountProfileUpdateSuccess) {
          showSnackBar(context, state.message, Colors.green);
        } else if (state is PatientAccountProfileUpdateFailure) {
          showSnackBar(context, state.errorMessage, Colors.red);
        } else if (state is PatientAccountProfileImageUpdateSuccess) {
          showSnackBar(context, state.message, Colors.green);
        } else if (state is PatientAccountProfileImageUpdateFailure) {
          showSnackBar(context, state.errorMessage, Colors.red);
        }
      },
      builder: (context, state) {
        final cubit = context.read<PatientAccountProfileCubit>();
        final PatientAccountProfileEntity? profile =
            state is PatientAccountProfileLoaded
                ? state.profile
                : cubit.cachedProfile;

        final bool isBusy =
            state is PatientAccountProfileLoading ||
            state is PatientAccountProfileUpdateLoading ||
            state is PatientAccountProfileImageUpdateLoading;

        if (profile == null) {
          if (state is PatientAccountProfileFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.redAccent,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Unable to load profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => cubit.loadProfile(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B4E8C),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  PatientProfileHeader(profile: profile),
                  const SizedBox(height: 15),
                  PatientInfo(profile: profile),
                  const SizedBox(height: 15),
                ],
              ),
            ),
            if (isBusy)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.08),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        );
      },
    );
  }
}
