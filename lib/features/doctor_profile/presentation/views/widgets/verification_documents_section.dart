import 'package:flutter/material.dart';
import 'package:graduation_project/core/utils/app_images.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/verification_documents_tile.dart';

class VerificationDocumentsSection extends StatelessWidget {
  const VerificationDocumentsSection({super.key});

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
                "Verification Documents",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),

              VerificationDocumentsTile(
                icon: Icons.description,
                color: Colors.purple,
                title: "Medical License",
                image: Assets.imagesAward,
              ),
              SizedBox(height: 15),
              VerificationDocumentsTile(
                icon: Icons.school,
                color: Colors.blue,
                title: "Graduation Certificate",
                image: Assets.imagesAward,
              ),
              SizedBox(height: 15),
              VerificationDocumentsTile(
                icon: Icons.badge,
                color: Colors.green,
                title: "National ID",
                image: Assets.imagesAward,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
