import 'package:flutter/material.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/tag_chip.dart';

class AboutMeSection extends StatelessWidget {
  const AboutMeSection({super.key});

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
            children: [
              const Text(
                "About Me",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              const Text(
                "I am a board-certified cardiologist with over 12 years of experience in treating complex cardiovascular conditions. My passion lies in providing personalized, compassionate care while utilizing the latest medical technologies and evidence-based treatments.",
                style: TextStyle(color: Colors.black54, height: 1.5),
              ),
              const SizedBox(height: 12),
              const Text(
                "I specialize in interventional cardiology, including cardiac catheterization, angioplasty, and stent placement. I believe in building strong doctor-patient relationships and ensuring my patients understand their conditions and treatment options.",
                style: TextStyle(color: Colors.black54, height: 1.5),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: const [
                  TagChip(label: "Heart Disease", color: Colors.blue),
                  TagChip(label: "Hypertension", color: Colors.green),
                  TagChip(label: "Arrhythmia", color: Colors.purple),
                  TagChip(label: "Preventive Care", color: Colors.orange),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
