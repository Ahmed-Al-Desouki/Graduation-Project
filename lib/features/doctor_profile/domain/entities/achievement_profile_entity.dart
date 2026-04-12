class AchievementProfileEntity {
  final int achievementId;
  final String title;
  final String? description;
  final String? imageUrl;
  final DateTime? createdAt;

  AchievementProfileEntity({
    required this.achievementId,
    required this.title,
    this.description,
    this.imageUrl,
    this.createdAt,
  });
}
