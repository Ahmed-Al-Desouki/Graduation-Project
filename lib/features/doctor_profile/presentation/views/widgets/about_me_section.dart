import 'package:flutter/material.dart';

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
            ],
          ),
        ),
      ),
    );
  }
}
