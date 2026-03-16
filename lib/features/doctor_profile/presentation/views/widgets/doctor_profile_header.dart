import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/rating_row_for_header.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/stat_item_for_header.dart';

class DoctorProfileHeader extends StatelessWidget {
  const DoctorProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 30, bottom: 30),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: const LinearGradient(
          colors: [Color(0xFF6A80DA), Color(0xFF754EA6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              const CircleAvatar(
                radius: 55,
                backgroundImage: NetworkImage("https://i.pravatar.cc/300"),
              ),
              Positioned(
                bottom: 5,
                right: 5,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Text(
            "Dr. Sarah Johnson",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            "Cardiologist • 12 years experience",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 12),
          const RatingRowForHeader(),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              StatItemForHeader(value: "2.8K+", label: "Patients"),
              StatItemForHeader(value: "98%", label: "Success Rate"),
              StatItemForHeader(value: "24/7", label: "Available"),
            ],
          ),
        ],
      ),
    );
  }
}
