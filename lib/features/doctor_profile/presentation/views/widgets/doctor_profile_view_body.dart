import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/doctor_profile/presentation/manager/doctor_real_profile_cubit.dart';
import 'package:graduation_project/features/doctor_profile/presentation/manager/doctor_real_profile_state.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/about_me_section.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/achievements_section.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/doctor_profile_header.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/info_section.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/reviews_section.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/services_pricing_section.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/verification_documents_section.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/working_hours_section.dart';

class DoctorProfileViewBody extends StatelessWidget {
  final ScrollController scrollController;
  final GlobalKey infoKey;
  final GlobalKey aboutKey;
  final GlobalKey verificationKey;
  final GlobalKey achievementsKey;
  final GlobalKey hoursKey;
  final GlobalKey reviewsKey;
  final GlobalKey servicesKey;
  const DoctorProfileViewBody({
    super.key,
    required this.scrollController,
    required this.infoKey,
    required this.aboutKey,
    required this.verificationKey,
    required this.achievementsKey,
    required this.hoursKey,
    required this.reviewsKey,
    required this.servicesKey,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoctorRealProfileCubit, DoctorRealProfileState>(
      buildWhen:
          (previous, current) =>
              current is DoctorProfileLoading ||
              current is DoctorProfileSuccess ||
              current is DoctorProfileFailure ||
              current is DoctorProfileInitial,
      builder: (context, state) {
        if (state is DoctorProfileLoading || state is DoctorProfileInitial) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is DoctorProfileFailure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  'Failed to load profile',
                  style: TextStyle(fontSize: 18, color: Colors.red.shade400),
                ),
                const SizedBox(height: 8),
                Text(
                  state.errorMessage,
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<DoctorRealProfileCubit>().getDoctorProfile();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is DoctorProfileSuccess) {
          final profile = state.profile;
          return SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                DoctorProfileHeader(profile: profile),
                SizedBox(height: 15),
                _buildSection(
                  infoKey,
                  InfoSection(profile: profile, isEditable: true),
                ),
                _buildSection(
                  aboutKey,
                  AboutMeSection(bio: profile.bio, isEditable: true),
                ),
                _buildSection(
                  verificationKey,
                  VerificationDocumentsSection(
                    documents: profile.verificationDocuments,
                  ),
                ),
                _buildSection(
                  achievementsKey,
                  AchievementsSection(
                    achievements: profile.achievements,
                    showActions: true,
                  ),
                ),
                _buildSection(
                  hoursKey,
                  WorkingHoursSection(doctorId: profile.doctorId),
                ),
                _buildSection(
                  reviewsKey,
                  BlocBuilder<DoctorRealProfileCubit, DoctorRealProfileState>(
                    buildWhen: (previous, current) {
                      if (previous is DoctorProfileSuccess &&
                          current is DoctorProfileSuccess) {
                        return previous.profile.reviews !=
                            current.profile.reviews;
                      }
                      return current is DoctorProfileSuccess;
                    },
                    builder: (context, state) {
                      if (state is DoctorProfileSuccess) {
                        return ReviewsSection(
                          averageRating: profile.averageRating,
                          reviews: profile.reviews,
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
                _buildSection(
                  servicesKey,
                  ServicesPricingSection(
                    consultationFee: profile.consultationFee,
                    isEditable: true,
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildSection(GlobalKey key, Widget child) {
    return Column(
      children: [Container(key: key, child: child), const SizedBox(height: 15)],
    );
  }
}
