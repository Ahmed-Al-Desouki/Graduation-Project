import 'package:flutter/material.dart';
import 'package:graduation_project/core/utils/app_images.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/info_tile.dart';

class InfoSection extends StatelessWidget {
  const InfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Doctor Information",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              InfoTile(
                icon: Icons.school,
                iconColor: Colors.blue,
                title: "Education",
                subtitle: "Harvard Medical School, MD",
              ),
              SizedBox(height: 15),
              InfoTile(
                imageAsset: Assets.imagesHospital,
                iconColor: Colors.green,
                title: "Hospital",
                subtitle: "St. Mary's Medical Center",
              ),
              SizedBox(height: 15),
              InfoTile(
                imageAsset: Assets.imagesCertificate,
                iconColor: Colors.orange,
                title: "Specializations",
                subtitle: "Interventional Cardiology",
              ),
              SizedBox(height: 15),
              InfoTile(
                icon: Icons.location_on,
                iconColor: Colors.purple,
                title: "Location",
                subtitle: "New York, NY • 2.3 miles away",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
