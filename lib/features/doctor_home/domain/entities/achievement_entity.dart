import 'dart:io';

class AchievementEntity {
  final int? achievementId;
  final String title;
  final String? description;
  final File? image;
  final DateTime? createdAt;

  AchievementEntity({
    this.achievementId,
    required this.title,
    this.description,
    this.image,
    this.createdAt,
  });
}
