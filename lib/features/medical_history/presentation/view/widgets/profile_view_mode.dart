import 'package:flutter/material.dart';
import 'package:graduation_project/features/medical_history/domain/models/patient_profile_model.dart';
import 'info_card_widget.dart';

class ProfileViewMode extends StatelessWidget {
  final PatientProfileModel profile;

  const ProfileViewMode({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    String displayDate =
        profile.dateOfBirth != null
            ? profile.dateOfBirth!.split('T')[0]
            : "N/A";

    IconData genderIcon = Icons.person; // Default
    if (profile.gender.toLowerCase() == 'male') {
      genderIcon = Icons.male;
    } else if (profile.gender.toLowerCase() == 'female') {
      genderIcon = Icons.female;
    }

    String displayAge;
    if (profile.age == 0) {
      displayAge = "Infant"; // أو "< 1 Yr"
    } else {
      displayAge = "${profile.age} Yrs";
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: InfoCardWidget(
                label: "Gender",
                value: profile.gender,
                icon: genderIcon,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InfoCardWidget(
                label: "Age",
                value: displayAge,
                icon: Icons.cake,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InfoCardWidget(
                label: "Blood",
                value: profile.bloodType ?? "N/A",
                icon: Icons.bloodtype,
                isHighlighted: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: InfoCardWidget(
                label: "Weight",
                value: "${profile.weight} kg",
                icon: Icons.monitor_weight_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InfoCardWidget(
                label: "Height",
                value: "${profile.height} cm",
                icon: Icons.height,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildDateCard(displayDate),
      ],
    );
  }

  Widget _buildDateCard(String date) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_month, color: Colors.grey, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Birth Date",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(date, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
