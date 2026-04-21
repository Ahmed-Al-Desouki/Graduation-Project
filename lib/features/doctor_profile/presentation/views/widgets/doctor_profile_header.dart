import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/features/doctor_profile/domain/entities/doctor_profile_entity.dart';
import 'package:graduation_project/features/doctor_profile/presentation/manager/doctor_real_profile_cubit.dart';
import 'package:graduation_project/features/doctor_profile/presentation/manager/doctor_real_profile_state.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/edit_basic_info_sheet.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/rating_row_for_header.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/stat_item_for_header.dart';
import 'package:image_picker/image_picker.dart';

class DoctorProfileHeader extends StatelessWidget {
  final DoctorProfileEntity profile;
  const DoctorProfileHeader({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return BlocListener<DoctorRealProfileCubit, DoctorRealProfileState>(
      listener: (context, state) {
        print('📊 State changed: $state');
        // ✅ استمع للـ states هنا
        if (state is UpdateProfileImageLoading) {
          print('⏳ Uploading...');
          // Show loading indicator
          showDialog(
            context: context,
            barrierDismissible: false,
            builder:
                (context) => const Center(child: CircularProgressIndicator()),
          );
        } else if (state is UpdateProfileImageSuccess) {
          print('✅ Upload success!');
          // ✅ اخفي الـ loading و اعرض رسالة نجاح
          Navigator.pop(context); // اخفي الـ loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile image updated successfully'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
        } else if (state is UpdateProfileImageFailure) {
          print('❌ Upload failed: ${state.errorMessage}');
          // ✅ اخفي الـ loading و اعرض رسالة error
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.only(bottom: 10),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.r)),
          gradient: const LinearGradient(
            colors: [Color(0xFF6A80DA), Color(0xFF754EA6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    _showEditBasicInfoSheet(context, profile);
                  },
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.grey.shade400, size: 17),
                      SizedBox(width: 5),
                      Text(
                        "Edit",
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10),
              ],
            ),
            Stack(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundImage: NetworkImage(profile.profileImageUrl ?? ''),
                ),
                // ✅ زر Edit للصورة (اختياري)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => _showEditProfileImageSheet(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Color(0xFF1B4E8C),
                      ),
                    ),
                  ),
                ),
                // if (profile.isActive)
                //   Positioned(
                //     bottom: 5,
                //     right: 5,
                //     child: Container(
                //       padding: const EdgeInsets.all(6),
                //       decoration: const BoxDecoration(
                //         color: Colors.green,
                //         shape: BoxShape.circle,
                //       ),
                //       child: const Icon(
                //         Icons.check,
                //         size: 16,
                //         color: Colors.white,
                //       ),
                //     ),
                //   ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              profile.fullName, // ✅ من الـ API
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            if (profile.dateOfBirth != null)
              Text(
                profile.dateOfBirth!.toLocal().toString().split(
                  ' ',
                )[0], // ✅ من الـ API
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            if (profile.phoneNumber != null)
              Text(
                profile.phoneNumber!, // ✅ من الـ API
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            Text(
              profile.email, // ✅ من الـ API
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            Text(
              '${profile.specialization} • ${profile.yearsOfExperience} years experience', // ✅ من الـ API
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 12),
            RatingRowForHeader(rating: profile.averageRating), // ✅ من الـ API
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                StatItemForHeader(value: "2.8K+", label: "Patients"),
                StatItemForHeader(value: "98%", label: "Success Rate"),
                StatItemForHeader(value: "24/7", label: "Available"),
              ],
            ),
            const SizedBox(height: 15),
            if (profile.nationalId != null)
              Text(
                "National ID : ${profile.nationalId}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   // استخدمنا BlocConsumer عشان نجمع بين الـ Listener والـ Builder
  //   return BlocConsumer<DoctorRealProfileCubit, DoctorRealProfileState>(
  //     listenWhen:
  //         (previous, current) =>
  //             current is UpdateProfileImageLoading ||
  //             current is UpdateProfileImageSuccess ||
  //             current is UpdateProfileImageFailure,
  //     listener: (context, state) {
  //       if (state is UpdateProfileImageLoading) {
  //         showDialog(
  //           context: context,
  //           barrierDismissible: false,
  //           builder:
  //               (context) => const Center(child: CircularProgressIndicator()),
  //         );
  //       } else {
  //         // ✅ أي حالة تانية غير الـ Loading (نجاح أو فشل) اقفل الديالوج فوراً
  //         // بنستخدم Navigator.of(context).pop() مباشرة عشان تضمن إنها تقفل الـ Dialog
  //         Navigator.of(context, rootNavigator: true).pop();

  //         if (state is UpdateProfileImageSuccess) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             const SnackBar(
  //               content: Text('Profile image updated successfully'),
  //               backgroundColor: Color(0xFF10B981),
  //             ),
  //           );
  //         } else if (state is UpdateProfileImageFailure) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content: Text(state.errorMessage),
  //               backgroundColor: Colors.red,
  //             ),
  //           );
  //         }
  //       }
  //     },
  //     // listener: (context, state) {
  //     //   if (state is UpdateProfileImageLoading) {
  //     //     showDialog(
  //     //       context: context,
  //     //       barrierDismissible: false,
  //     //       builder:
  //     //           (context) => const Center(child: CircularProgressIndicator()),
  //     //     );
  //     //   } else if (state is UpdateProfileImageSuccess) {
  //     //     Navigator.pop(context); // إخفاء الـ loading
  //     //     ScaffoldMessenger.of(context).showSnackBar(
  //     //       const SnackBar(
  //     //         content: Text('Profile image updated successfully'),
  //     //         backgroundColor: Color(0xFF10B981),
  //     //       ),
  //     //     );
  //     //   } else if (state is UpdateProfileImageFailure) {
  //     //     Navigator.pop(context); // إخفاء الـ loading
  //     //     ScaffoldMessenger.of(context).showSnackBar(
  //     //       SnackBar(
  //     //         content: Text(state.errorMessage),
  //     //         backgroundColor: Colors.red,
  //     //       ),
  //     //     );
  //     //   }
  //     // },
  //     builder: (context, state) {
  //       // ✅ اللعبة هنا: بنحدد مين الـ profile اللي هنعرض بياناته
  //       // لو الحالة Success (يعني الكاش اتحدث)، خد الـ profile الجديد من الـ state
  //       // لو لسه في الأول، خد الـ profile اللي جاي في الـ constructor
  //       // DoctorProfileEntity currentProfile = profile;
  //       final cubit = context.read<DoctorRealProfileCubit>();
  //       DoctorProfileEntity currentProfile = cubit.cachedProfile ?? profile;

  //       if (state is DoctorProfileSuccess) {
  //         currentProfile = state.profile;
  //       }

  //       return Container(
  //         padding: const EdgeInsets.only(bottom: 10),
  //         width: double.infinity,
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.r)),
  //           gradient: const LinearGradient(
  //             colors: [Color(0xFF6A80DA), Color(0xFF754EA6)],
  //             begin: Alignment.topLeft,
  //             end: Alignment.bottomRight,
  //           ),
  //         ),
  //         child: Column(
  //           children: [
  //             // زر الـ Edit للبيانات الأساسية
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.end,
  //               children: [
  //                 TextButton(
  //                   onPressed:
  //                       () => _showEditBasicInfoSheet(context, currentProfile),
  //                   child: Row(
  //                     children: [
  //                       Icon(Icons.edit, color: Colors.grey.shade400, size: 17),
  //                       const SizedBox(width: 5),
  //                       Text(
  //                         "Edit",
  //                         style: TextStyle(
  //                           color: Colors.grey.shade400,
  //                           fontWeight: FontWeight.bold,
  //                           fontSize: 16,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 const SizedBox(width: 10),
  //               ],
  //             ),
  //             Stack(
  //               children: [
  //                 CircleAvatar(
  //                   radius: 55,
  //                   // ✅ استخدام currentProfile المحدث
  //                   backgroundImage: NetworkImage(
  //                     "${currentProfile.profileImageUrl!}?v=${DateTime.now().millisecondsSinceEpoch}",
  //                   ),
  //                   // تركة تقنية: الكي بيخلي Flutter يفهم إن الصورة اتغيرت حتى لو الـ URL نفسه
  //                   key: ValueKey(
  //                     "${currentProfile.profileImageUrl!}?v=${DateTime.now().millisecondsSinceEpoch}",
  //                   ),
  //                 ),
  //                 Positioned(
  //                   bottom: 0,
  //                   right: 0,
  //                   child: GestureDetector(
  //                     onTap: () => _showEditProfileImageSheet(context),
  //                     child: Container(
  //                       padding: const EdgeInsets.all(6),
  //                       decoration: const BoxDecoration(
  //                         color: Colors.white,
  //                         shape: BoxShape.circle,
  //                       ),
  //                       child: const Icon(
  //                         Icons.edit,
  //                         size: 16,
  //                         color: Color(0xFF1B4E8C),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             const SizedBox(height: 15),
  //             Text(
  //               currentProfile.fullName, // ✅ القيمة المحدثة
  //               style: const TextStyle(
  //                 color: Colors.white,
  //                 fontSize: 20,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //             const SizedBox(height: 5),
  //             if (currentProfile.phoneNumber != null)
  //               Text(
  //                 currentProfile.phoneNumber!,
  //                 style: const TextStyle(color: Colors.white70, fontSize: 14),
  //               ),
  //             Text(
  //               currentProfile.email,
  //               style: const TextStyle(color: Colors.white70, fontSize: 14),
  //             ),
  //             Text(
  //               '${currentProfile.specialization} • ${currentProfile.yearsOfExperience} years experience',
  //               style: const TextStyle(color: Colors.white70, fontSize: 14),
  //             ),
  //             const SizedBox(height: 12),
  //             RatingRowForHeader(rating: currentProfile.averageRating),
  //             const SizedBox(height: 20),
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //               children: const [
  //                 StatItemForHeader(value: "2.8K+", label: "Patients"),
  //                 StatItemForHeader(value: "98%", label: "Success Rate"),
  //                 StatItemForHeader(value: "24/7", label: "Available"),
  //               ],
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  void _showEditBasicInfoSheet(
    BuildContext context,
    DoctorProfileEntity profile,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (_) => BlocProvider.value(
            value: context.read<DoctorRealProfileCubit>(),
            child: EditBasicInfoSheet(profile: profile),
          ),
    );
  }

  void _showEditProfileImageSheet(BuildContext context) {
    // 1. بناخد نسخة من الكيوبيت من الـ context الأصلي قبل ما نفتح الشيت
    final cubit = context.read<DoctorRealProfileCubit>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      // 2. بنستخدم BlocProvider.value عشان نمرر نفس النسخة للشيت
      builder:
          (sheetContext) => BlocProvider.value(
            value: cubit,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Change Profile Picture',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B4E8C),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(
                      Icons.camera_alt,
                      color: Color(0xFF1B4E8C),
                    ),
                    title: const Text('Take Photo'),
                    onTap: () {
                      // هنا بنستخدم الـ cubit اللي خدناه فوق
                      Navigator.pop(sheetContext);
                      _pickImage(cubit, ImageSource.camera);
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.photo_library,
                      color: Color(0xFF1B4E8C),
                    ),
                    title: const Text('Choose from Gallery'),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _pickImage(cubit, ImageSource.gallery);
                    },
                  ),
                ],
              ),
            ),
          ),
    );
  }
  // void _showEditProfileImageSheet(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     backgroundColor: Colors.white,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder:
  //         (context) => Padding(
  //           padding: const EdgeInsets.all(20),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Container(
  //                 width: 40,
  //                 height: 4,
  //                 decoration: BoxDecoration(
  //                   color: Colors.grey.shade300,
  //                   borderRadius: BorderRadius.circular(10),
  //                 ),
  //               ),
  //               const SizedBox(height: 20),
  //               const Text(
  //                 'Change Profile Picture',
  //                 style: TextStyle(
  //                   fontSize: 18,
  //                   fontWeight: FontWeight.bold,
  //                   color: Color(0xFF1B4E8C),
  //                 ),
  //               ),
  //               const SizedBox(height: 20),
  //               ListTile(
  //                 leading: Container(
  //                   padding: const EdgeInsets.all(8),
  //                   decoration: BoxDecoration(
  //                     color: const Color(0xFF1B4E8C).withOpacity(0.1),
  //                     shape: BoxShape.circle,
  //                   ),
  //                   child: const Icon(
  //                     Icons.camera_alt,
  //                     color: Color(0xFF1B4E8C),
  //                   ),
  //                 ),
  //                 title: const Text(
  //                   'Take Photo',
  //                   style: TextStyle(fontWeight: FontWeight.w500),
  //                 ),
  //                 onTap: () {
  //                   final cubit = context.read<DoctorRealProfileCubit>();
  //                   Navigator.pop(context);
  //                   _pickImage(cubit, ImageSource.camera);
  //                 },
  //               ),
  //               ListTile(
  //                 leading: Container(
  //                   padding: const EdgeInsets.all(8),
  //                   decoration: BoxDecoration(
  //                     color: const Color(0xFF1B4E8C).withOpacity(0.1),
  //                     shape: BoxShape.circle,
  //                   ),
  //                   child: const Icon(
  //                     Icons.photo_library,
  //                     color: Color(0xFF1B4E8C),
  //                   ),
  //                 ),
  //                 title: const Text(
  //                   'Choose from Gallery',
  //                   style: TextStyle(fontWeight: FontWeight.w500),
  //                 ),
  //                 onTap: () {
  //                   final cubit = context.read<DoctorRealProfileCubit>();
  //                   Navigator.pop(context);
  //                   _pickImage(cubit, ImageSource.gallery);
  //                 },
  //               ),
  //             ],
  //           ),
  //         ),
  //   );
  // }

  Future<void> _pickImage(
    DoctorRealProfileCubit cubit,
    ImageSource source,
  ) async {
    print('📸 Starting image picker...');

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    print('📸 Picked file: ${pickedFile?.path}');

    if (pickedFile != null) {
      final file = File(pickedFile.path);

      final fileSize = await file.length();
      print('📸 File size: ${fileSize / 1024 / 1024} MB');

      // if (fileSize > 5 * 1024 * 1024) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //       content: Text('File size must be less than 5MB'),
      //       backgroundColor: Colors.red,
      //     ),
      //   );
      //   return;
      // }

      print('📸 Uploading profile image...');

      // ✅ الحل: استخدم getIt بدل context.read
      // final cubit = getIt<DoctorRealProfileCubit>();
      // final cubit = context.read<DoctorRealProfileCubit>();

      await cubit.updateProfileImage(file);

      print('📸 Update completed');
    } else {
      print('❌ No image selected');
    }
  }
}
