import 'package:flutter/material.dart';
import 'package:graduation_project/core/widgets/rating_row.dart';
import 'package:graduation_project/features/doctor_profile/domain/entities/public_doctor_profile_entity.dart';

class PublicProfileHeader extends StatelessWidget {
  final PublicDoctorProfileEntity profile;
  const PublicProfileHeader({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
        gradient: LinearGradient(
          colors: [Color(0xFF6A80DA), Color(0xFF754EA6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage:
                profile.profileImageUrl != null
                    ? NetworkImage(profile.profileImageUrl!)
                    : null,
            child:
                profile.profileImageUrl == null
                    ? const Icon(Icons.person, size: 50)
                    : null,
          ),
          const SizedBox(height: 12),
          Text(
            profile.fullName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${profile.specialization} • ${profile.yearsOfExperience} years experience',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          RatingRow(rating: profile.averageRating),
          const SizedBox(height: 5),
          Text(
            "(${profile.reviews.length} ${profile.reviews.length == 1 ? 'review' : 'reviews'})",
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
