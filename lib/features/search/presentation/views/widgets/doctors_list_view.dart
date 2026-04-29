import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/features/search/presentation/manager/search_cubit/search_cubit.dart';
import 'package:graduation_project/features/search/presentation/views/widgets/doctor_card.dart';
import 'package:graduation_project/features/search/presentation/views/widgets/doctor_card_loading_indicator.dart';

class DoctorsListView extends StatelessWidget {
  final SearchState state;
  const DoctorsListView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final doctors =
        state is SearchSuccess ? (state as SearchSuccess).doctors : [];
    if (state is SearchLoading && doctors.isEmpty) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        itemBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 10, left: 5, right: 5),
            child: DoctorCardLoadingIndicator(),
          );
        },
      );
    }
    if (state is SearchFailure) {
      return Center(
        child: Text(
          (state as SearchFailure).errmessage,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    if (doctors.isEmpty && state is SearchSuccess) {
      return Padding(
        padding: EdgeInsets.all(40.h),
        child: const Row(
          children: [
            Spacer(flex: 1),
            Text(
              "No doctors found",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            Spacer(flex: 1),
          ],
        ),
      );
    }

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: doctors.length,
          itemBuilder: (context, index) {
            final doctor = doctors[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
              child: DoctorCard(
                doctorId: doctor.doctorId,
                fullName: doctor.fullName,
                imageUrl: doctor.profileImageUrl ?? '',
                specialty: doctor.specialization,
                rating: doctor.averageRating,
                totalReviews: doctor.totalReviews,
                yearsOfExperience: doctor.yearsOfExperience,
                consultationFee: doctor.consultationFee,
                isActive: doctor.isActive,
              ),
            );
          },
        ),

        if (state is SearchSuccess && (state as SearchSuccess).isFetchingMore)
          const Padding(
            padding: EdgeInsets.only(bottom: 20, top: 10, left: 5, right: 5),
            child: DoctorCardLoadingIndicator(),
          ),
      ],
    );
  }
}
