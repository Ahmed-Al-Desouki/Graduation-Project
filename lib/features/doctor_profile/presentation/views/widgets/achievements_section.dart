import 'package:flutter/material.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/achievement_tile.dart';

class AchievementsSection extends StatelessWidget {
  const AchievementsSection({super.key});

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
                "Achievements & Awards",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              AchievementTile(
                icon: Icons.emoji_events,
                color: Colors.amber,
                title: "Top Doctor 2023",
                subtitle: "New York Magazine",
              ),
              SizedBox(height: 15),
              AchievementTile(
                icon: Icons.verified,
                color: Colors.blue,
                title: "Excellence in Patient Care",
                subtitle: "American Heart Association",
              ),
              SizedBox(height: 15),
              AchievementTile(
                icon: Icons.star,
                color: Colors.green,
                title: "Research Publication Award",
                subtitle: "Journal of Cardiology",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
