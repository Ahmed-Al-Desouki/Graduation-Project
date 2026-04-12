import '../../domain/entities/achievement_profile_entity.dart';

class AchievementModel extends AchievementProfileEntity {
  AchievementModel({
    required super.achievementId,
    required super.title,
    super.description,
    super.imageUrl,
    super.createdAt,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      achievementId: json['achievementId'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}
