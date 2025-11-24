import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/app_images.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/app_styles.dart';
import 'package:graduation_project/core/utils/functions/show_snack_bar.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/conditions_allergies_section.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/health_profile_section.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/lab_results_section.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/past_appointments_section.dart';

class MedicalHistoryView extends StatelessWidget {
  const MedicalHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<PatientProfileCubit>()..getProfile(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        appBar: _buildAppBar(context),
        body: BlocConsumer<PatientProfileCubit, PatientProfileState>(
          buildWhen: (previous, current) {
            return current is PatientProfileSuccess ||
                (current is PatientProfileLoading &&
                    previous is! PatientProfileSuccess);
          },
          listener: (context, state) {
            if (state is PatientUpdateSuccess) {
              ShowSnackBar(context, state.message, Colors.green);
            }
            if (state is PatientUploadSuccess) {
              ShowSnackBar(context, state.message, Colors.green);
            }
            if (state is PatientDeleteSuccess) {
              ShowSnackBar(context, state.message, Colors.orange);
            }
            if (state is PatientProfileFailure) {
              ShowSnackBar(context, state.errMessage, Colors.red);
            }
            if (state is PatientUpdateFailure) {
              ShowSnackBar(context, state.errMessage, Colors.red);
            }
            if (state is PatientUploadFailure) {
              ShowSnackBar(context, state.errMessage, Colors.red);
            }
          },
          builder: (context, state) {
            if (state is PatientProfileLoading &&
                state is! PatientProfileSuccess) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is PatientProfileSuccess) {
              final profile = state.profile;
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 24.0,
                ),
                child: Column(
                  children: [
                    _buildHeaderCard(),
                    const SizedBox(height: 24),

                    HealthProfileSection(
                      profile: profile,
                      onSave: (updateMap) {
                        context.read<PatientProfileCubit>().updateProfileInfo(
                          updateMap,
                        );
                      },
                    ),

                    const SizedBox(height: 15),

                    ConditionsAllergiesSection(profile: profile),

                    const SizedBox(height: 15),

                    const PastAppointmentsSection(),

                    const SizedBox(height: 15),

                    LabResultsSection(
                      labTests: profile.labTests,
                      radiologyFiles: profile.radiologyFiles,
                      medicalHistoryId: profile.medicalHistoryID,
                    ),
                  ],
                ),
              );
            }
            if (state is PatientProfileFailure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.errMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed:
                          () =>
                              context.read<PatientProfileCubit>().getProfile(),
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('My Medical History', style: AppStyles.styleSemiBold18Dark),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          size: 20,
          color: Color(0xFF111827),
        ),
        onPressed: () => context.go(AppRouter.kHomePatient),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90E2).withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        gradient: const LinearGradient(
          colors: [Color(0xFFE3F2FD), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          SvgPicture.asset(
            Assets.imagesMedicalRecordsSvgrepoCom,
            height: 40,
            width: 40,
          ),
          const SizedBox(height: 16),
          Text('Health Profile', style: AppStyles.styleBold24Dark),
          const SizedBox(height: 6),
          Text(
            'Keep your medical records up to date.',
            style: AppStyles.styleRegular16GrayDark.copyWith(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
