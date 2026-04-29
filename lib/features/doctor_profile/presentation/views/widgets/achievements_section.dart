import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/functions/confirm_delete.dart';
import 'package:graduation_project/features/doctor_profile/domain/entities/achievement_profile_entity.dart';
import 'package:graduation_project/features/doctor_profile/presentation/manager/doctor_real_profile_cubit.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/edit_achievements_sheet.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/achievement_tile.dart';

class AchievementsSection extends StatelessWidget {
  final List<AchievementProfileEntity> achievements;
  final bool showActions;
  const AchievementsSection({
    super.key,
    required this.achievements,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayAchievements =
        achievements.length > 3 ? achievements.sublist(0, 3) : achievements;

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Achievements & Awards",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (showActions
                      ? achievements.isNotEmpty
                      : achievements.length > 3)
                    TextButton(
                      onPressed: () {
                        AppRouter.router.push(
                          AppRouter.kAllAchievements,
                          extra: {
                            'cubit': context.read<DoctorRealProfileCubit>(),
                            'achievements': showActions ? null : achievements,
                            'showActions': showActions,
                          },
                        );
                      },
                      child: const Text(
                        "View All",
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              if (achievements.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'No achievements added yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),

              ...displayAchievements.map((achievement) {
                final showActionsInCard =
                    showActions && achievements.length <= 3;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: AchievementTile(
                    achievement: achievement,
                    showActions: showActionsInCard,
                    onEdit:
                        showActionsInCard
                            ? () => _showEditSheet(context, achievement)
                            : null,
                    onDelete:
                        showActionsInCard
                            ? () =>
                                _showDeleteConfirmation(context, achievement)
                            : null,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditSheet(
    BuildContext context,
    AchievementProfileEntity achievement,
  ) {
    final cubit = context.read<DoctorRealProfileCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (_) => BlocProvider.value(
            value: cubit,
            child: EditAchievementSheet(achievement: achievement),
          ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    AchievementProfileEntity achievement,
  ) {
    final cubit = context.read<DoctorRealProfileCubit>();

    confirmDelete(context, () async {
      await cubit.deleteAchievement(achievementId: achievement.achievementId);
    });
  }
}
