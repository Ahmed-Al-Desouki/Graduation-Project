import 'package:flutter/material.dart';
import 'package:graduation_project/features/doctor_profile/domain/entities/achievement_profile_entity.dart';

class AchievementTile extends StatelessWidget {
  final AchievementProfileEntity achievement;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions; // ← المتغير الجديد

  const AchievementTile({
    super.key,
    required this.achievement,
    this.onEdit,
    this.onDelete,
    this.showActions = false, // default = false
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Icon
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.emoji_events, color: Colors.amber),
        ),
        const SizedBox(width: 15),

        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                achievement.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (achievement.description?.isNotEmpty == true) ...[
                const SizedBox(height: 4),
                Text(
                  achievement.description!,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
              if (achievement.imageUrl != null) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    achievement.imageUrl!,
                    height: 150,
                    width: 200,
                    fit: BoxFit.scaleDown,
                    errorBuilder:
                        (_, __, ___) => const Icon(
                          Icons.emoji_events,
                          color: Colors.amber,
                          size: 40,
                        ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Actions (Edit + Delete) → تظهر فقط في View All
        if (showActions && (onEdit != null || onDelete != null))
          Row(
            children: [
              if (onEdit != null)
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Color(0xFF2563EB).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.edit,
                      color: Color(0xFF2563EB),
                      size: 22,
                    ),
                    onPressed: onEdit,
                  ),
                ),
                SizedBox(width: 10),
              if (onDelete != null)
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 22),
                    onPressed: onDelete,
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

// import 'package:flutter/material.dart';

// class AchievementTile extends StatelessWidget {
//   final String title;
//   final String description;
//   final String? imageUrl; // ✅ الصورة من الـ API

//   const AchievementTile({
//     super.key,
//     required this.title,
//     required this.description,
//     this.imageUrl,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: Colors.amber.withOpacity(0.15),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(Icons.emoji_events, color: Colors.amber),
//         ),
//         const SizedBox(width: 15),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
//               const SizedBox(height: 4),
//               if (description.isNotEmpty)
//                 Text(
//                   description,
//                   style: const TextStyle(color: Colors.grey, fontSize: 13),
//                 ),
//               if (imageUrl != null) ...[
//                 const SizedBox(height: 8),
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(8),
//                   child: Image.network(
//                     imageUrl!,
//                     height: 150,
//                     width: 200,
//                     fit: BoxFit.scaleDown,
//                     errorBuilder:
//                         (_, _, _) => const Icon(
//                           Icons.emoji_events,
//                           color: Colors.amber,
//                           size: 40,
//                         ),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//         Container(
//           height: 40,
//           width: 40,
//           decoration: BoxDecoration(
//             color: Color(0xFF2563EB).withOpacity(0.15),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: IconButton(
//             icon: const Icon(Icons.edit, color: Color(0xFF2563EB), size: 22),
//             onPressed: () => {},
//           ),
//         ),

//         SizedBox(width: 10),
//         Container(
//           height: 40,
//           width: 40,
//           decoration: BoxDecoration(
//             color: Colors.red.withOpacity(0.15),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: IconButton(
//             icon: const Icon(Icons.delete, color: Colors.red, size: 22),
//             onPressed: () => {},
//           ),
//         ),
//       ],
//     );
//   }
// }
