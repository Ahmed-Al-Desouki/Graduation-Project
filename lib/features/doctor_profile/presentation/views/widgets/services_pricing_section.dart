import 'package:flutter/material.dart';
import 'package:graduation_project/core/utils/app_images.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/service_price_item.dart';

class ServicesPricingSection extends StatelessWidget {
  const ServicesPricingSection({super.key});

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
                "Services & Pricing",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),

              ServicePriceItem(
                icon: Icons.videocam,
                iconColor: Colors.blue,
                title: "Video Consultation",
                subtitle: "30 minutes session",
                price: "\$45",
              ),
              SizedBox(height: 12),

              ServicePriceItem(
                imageAsset: Assets.imagesUserDoctor,
                iconColor: Colors.green,
                title: "In-Person Visit",
                subtitle: "Full examination",
                price: "\$80",
              ),
              SizedBox(height: 12),

              ServicePriceItem(
                imageAsset: Assets.imagesHeartRate,
                iconColor: Colors.purple,
                title: "ECG Test",
                subtitle: "Electrocardiogram",
                price: "\$120",
              ),
              SizedBox(height: 12),

              ServicePriceItem(
                imageAsset: Assets.imagesStethoscope,
                iconColor: Colors.orange,
                title: "Cardiac Screening",
                subtitle: "Comprehensive checkup",
                price: "\$200",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
