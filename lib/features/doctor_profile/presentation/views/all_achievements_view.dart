import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/functions/confirm_delete.dart';
import 'package:graduation_project/features/doctor_profile/domain/entities/achievement_profile_entity.dart';
import 'package:graduation_project/features/doctor_profile/presentation/manager/doctor_real_profile_cubit.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/edit_achievements_sheet.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/achievement_tile.dart';

class AllAchievementsView extends StatelessWidget {
  const AllAchievementsView({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<DoctorRealProfileCubit>();

    // ✅ استخدم cachedProfile بدل state
    final achievements =
        cubit.cachedProfile?.achievements ?? <AchievementProfileEntity>[];
    return Scaffold(
      backgroundColor: const Color(0xfffaf0ff),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "All Achievements",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body:
          achievements.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.emoji_events_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No achievements yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6A80DA), Color(0xFF754EA6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.emoji_events,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'All Achievements & Awards',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${achievements.length} ${achievements.length == 1 ? "achievement" : "achievements"}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...achievements.map((achievement) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: AchievementTile(
                          achievement: achievement,
                          showActions: true,
                          onEdit:
                              () => _showEditAchievementSheet(
                                context,
                                achievement,
                              ),
                          onDelete:
                              () =>
                                  _showDeleteConfirmation(context, achievement),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
    );
  }

  void _showEditAchievementSheet(
    BuildContext context,
    AchievementProfileEntity achievement,
  ) {
    // ✅ احفظ الـ cubit قبل فتح الـ bottom sheet
    final cubit = context.read<DoctorRealProfileCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (_) => BlocProvider.value(
            value: cubit, // ✅ مرر الـ cubit المحفوظ مباشرة
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
      await cubit.deleteAchievement(achievementId: achievement.achievementId!);
    });
  }
}

// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:graduation_project/features/doctor_profile/domain/entities/achievement_profile_entity.dart';
// import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/achievement_tile.dart';

// class AllAchievementsView extends StatelessWidget {
//   final List<AchievementProfileEntity> achievements;

//   const AllAchievementsView({super.key, required this.achievements});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xfffaf0ff),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
//           onPressed: () => context.pop(),
//         ),
//         title: const Text(
//           "All Achievements",
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//       ),
//       body:
//           achievements.isEmpty
//               ? const Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.emoji_events_outlined,
//                       size: 80,
//                       color: Colors.grey,
//                     ),
//                     SizedBox(height: 16),
//                     Text(
//                       'No achievements yet',
//                       style: TextStyle(
//                         fontSize: 18,
//                         color: Colors.grey,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               )
//               : SingleChildScrollView(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         gradient: const LinearGradient(
//                           colors: [Color(0xFF6A80DA), Color(0xFF754EA6)],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(10),
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.2),
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: const Icon(
//                               Icons.emoji_events,
//                               color: Colors.white,
//                               size: 28,
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Text(
//                                   'All Achievements & Awards',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   '${achievements.length} ${achievements.length == 1 ? "achievement" : "achievements"}',
//                                   style: TextStyle(
//                                     color: Colors.white.withOpacity(0.9),
//                                     fontSize: 13,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     ...achievements.asMap().entries.map((entry) {
//                       final achievement = entry.value;
//                       return Column(
//                         children: [
//                           AchievementTile(
//                             title: achievement.title,
//                             description: achievement.description ?? "",
//                             imageUrl: achievement.imageUrl,
//                           ),
//                           if (entry.key < achievements.length - 1)
//                             const SizedBox(height: 15),
//                         ],
//                       );
//                     }),
//                   ],
//                 ),
//               ),
//     );
//   }
// }
