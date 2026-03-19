import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/app_router.dart';

class DoctorCard extends StatelessWidget {
  final int doctorId;
  final String fullName;
  final String imageUrl;
  final String specialty;
  final String rating;
  final int totalReviews;
  final int yearsOfExperience;
  final double consultationFee;
  final bool isActive;

  const DoctorCard({
    super.key,
    required this.doctorId,
    required this.fullName,
    required this.imageUrl,
    required this.specialty,
    required this.rating,
    required this.totalReviews,
    required this.yearsOfExperience,
    required this.consultationFee,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundImage:
                        imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                    child:
                        imageUrl.isEmpty
                            ? const Icon(Icons.person, size: 30)
                            : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          specialty,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 60),
                child: Row(
                  children: [
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          Icons.star,
                          color: Colors.yellow.shade600,
                          size: 15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(rating),
                    const SizedBox(width: 4),
                    Text(
                      '($totalReviews reviews)',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 60),
                child: Row(
                  children: [
                    const Icon(Icons.school, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('$yearsOfExperience years exp.'),
                    const SizedBox(width: 4),
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    const Text('1.8 km away'),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      context.push(
                        AppRouter
                            .kDoctorSchedule, // المسار اللي إنت معرفه للكالندر
                        extra: {
                          'doctorId': doctorId.toString(),
                          'doctorName': fullName,
                          'isPatientView':
                              true, // ✅ أهم Flag عشان نخفي الترس والتحكم
                          'consultationFee': consultationFee,
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Book Now",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
