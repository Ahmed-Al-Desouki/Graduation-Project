import 'package:flutter/material.dart';
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
    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        children: [
          const DoctorProfileHeader(),
          const SizedBox(height: 15),

          _buildSection(infoKey, const InfoSection()),
          _buildSection(aboutKey, const AboutMeSection()),
          _buildSection(verificationKey, const VerificationDocumentsSection()),
          _buildSection(achievementsKey, const AchievementsSection()),
          _buildSection(hoursKey, const WorkingHoursSection()),
          _buildSection(reviewsKey, const ReviewsSection()),
          _buildSection(servicesKey, const ServicesPricingSection()),
        ],
      ),
    );
  }

  Widget _buildSection(GlobalKey key, Widget child) {
    return Column(
      children: [Container(key: key, child: child), const SizedBox(height: 15)],
    );
  }
}
