import '../../domain/entities/achievement_entity.dart';

class AchievementModel extends AchievementEntity {
  AchievementModel({
    super.achievementId,
    required super.title,
    super.description,
    super.image,
    super.createdAt,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      achievementId: json['achievementId'],
      title: json['title'],
      description: json['description'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}
