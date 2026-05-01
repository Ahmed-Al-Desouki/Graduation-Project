import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/features/doctor_profile/presentation/manager/doctor_real_profile_cubit.dart';
import 'package:graduation_project/features/doctor_profile/presentation/manager/doctor_real_profile_state.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/about_me_section.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/achievements_section.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/info_section.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/public_profile_header.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/reviews_section.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/services_pricing_section.dart';

class DoctorPublicProfileView extends StatelessWidget {
  final int doctorId;
  const DoctorPublicProfileView({super.key, required this.doctorId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoctorRealProfileCubit, DoctorRealProfileState>(
      builder: (context, state) {
        if (state is DoctorProfileLoading || state is DoctorProfileInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is DoctorProfileFailure) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is PublicDoctorProfileSuccess) {
          final profile = state.profile;
          return Scaffold(
            backgroundColor: const Color(0xfffaf0ff),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () => context.pop(),
              ),
              title: Text(
                "Profile",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  PublicProfileHeader(profile: profile),
                  const SizedBox(height: 15),

                  InfoSection(profile: profile, isEditable: false),
                  const SizedBox(height: 15),

                  AboutMeSection(bio: profile.bio, isEditable: false),
                  const SizedBox(height: 15),

                  AchievementsSection(
                    achievements: profile.achievements,
                    showActions: false,
                  ),
                  const SizedBox(height: 15),

                  ReviewsSection(
                    averageRating: profile.averageRating,
                    reviews: profile.reviews,
                  ),
                  const SizedBox(height: 15),

                  ServicesPricingSection(
                    consultationFee: profile.consultationFee,
                    isEditable: false,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        }

        return const SizedBox();
      },
    );
  }
}
