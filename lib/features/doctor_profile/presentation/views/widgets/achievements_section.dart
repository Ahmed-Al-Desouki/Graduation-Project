import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/features/doctor_profile/domain/entities/achievement_profile_entity.dart';
import 'package:graduation_project/features/doctor_profile/presentation/manager/doctor_real_profile_cubit.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/achievement_tile.dart';

class AchievementsSection extends StatelessWidget {
  final List<AchievementProfileEntity> achievements;
  const AchievementsSection({super.key, required this.achievements});

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
                  if (achievements.length > 3)
                    TextButton(
                      onPressed: () {
                        AppRouter.router.push(
                          AppRouter.kAllAchievements,
                          extra: {
                            'cubit': context.read<DoctorRealProfileCubit>(),
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
                    // TextButton(
                    //   onPressed: () {
                    //     AppRouter.router.push(
                    //       AppRouter.kAllAchievements,
                    //       extra: achievements,
                    //     );
                    //   },
                    //   child: const Text(
                    //     "View All",
                    //     style: TextStyle(
                    //       color: Color(0xFF2563EB),
                    //       fontWeight: FontWeight.bold,
                    //     ),
                    //   ),
                    // ),
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

              // Preview → بدون Edit/Delete
              ...displayAchievements.map((achievement) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: AchievementTile(
                    achievement: achievement,
                    showActions: false,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:graduation_project/core/utils/app_router.dart';
// import 'package:graduation_project/features/doctor_profile/domain/entities/achievement_profile_entity.dart';
// import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/achievement_tile.dart';

// class AchievementsSection extends StatelessWidget {
//   final List<AchievementProfileEntity> achievements;
//   const AchievementsSection({super.key, required this.achievements});

//   @override
//   Widget build(BuildContext context) {
//     final displayAchievements =
//         achievements.length > 3 ? achievements.sublist(0, 3) : achievements;

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Card(
//         color: Colors.white,
//         elevation: 2,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "Achievements & Awards",
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   if (achievements.length > 3)
//                     TextButton(
//                       onPressed: () {
//                         AppRouter.router.push(
//                           AppRouter.kAllAchievements,
//                           extra:
//                               achievements, // ✅ نمرر الـ achievements كـ extra
//                         );
//                       },
//                       child: const Text(
//                         "View All",
//                         style: TextStyle(
//                           color: Color(0xFF2563EB),
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               if (achievements.isEmpty)
//                 const Center(
//                   child: Padding(
//                     padding: EdgeInsets.all(20),
//                     child: Text(
//                       'No achievements added yet',
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                   ),
//                 ),
//               ...displayAchievements.asMap().entries.map((entry) {
//                 final achievement = entry.value;
//                 return Column(
//                   children: [
//                     AchievementTile(
//                       title: achievement.title,
//                       description: achievement.description ?? "",
//                       imageUrl: achievement.imageUrl,
//                     ),
//                     if (entry.key < displayAchievements.length - 1)
//                       const SizedBox(height: 15),
//                   ],
//                 );
//               }),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
