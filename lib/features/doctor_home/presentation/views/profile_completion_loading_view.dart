import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/features/doctor_home/presentation/manager/doctor_profile_cubit.dart';
import 'package:graduation_project/features/doctor_home/presentation/manager/doctor_profile_state.dart';

class ProfileCompletionLoadingView extends StatefulWidget {
  const ProfileCompletionLoadingView({super.key});

  @override
  State<ProfileCompletionLoadingView> createState() =>
      _ProfileCompletionLoadingViewState();
}

class _ProfileCompletionLoadingViewState
    extends State<ProfileCompletionLoadingView> {
  @override
  void initState() {
    super.initState();
    // ✅ Start polling when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DoctorProfileCubit>().startAdminReviewPolling();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DoctorProfileCubit, DoctorProfileState>(
      listener: (context, state) {
        if (state is AdminReviewApproved) {
          // ✅ Admin Approved → Go to Home
          AppRouter.router.go(AppRouter.kHomeDoctor);
        } else if (state is AdminReviewRejected) {
          // ✅ Admin Rejected → Show Error
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Profile Review Failed'),
                  content: Text(state.errorMessage),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        AppRouter.router.go(AppRouter.kHomeDoctor);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xfffaf0ff),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ✅ Loading Animation
                SizedBox(
                  width: 100.w,
                  height: 100.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    color: const Color(0xFF1B4E8C),
                  ),
                ),
                SizedBox(height: 32.h),

                // ✅ Title
                Text(
                  'Reviewing Your Profile',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1B4E8C),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),

                // ✅ Description
                Text(
                  'Our admin team is reviewing your submitted information. This process may take up to a few minutes. You will be notified once your profile is approved.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF6B7280),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.h),

                // ✅ Info Box
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF1B4E8C).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: const Color(0xFF1B4E8C),
                        size: 24.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'You can close this app and check back later. We\'ll send you a notification when your profile is approved.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: const Color(0xFF1B4E8C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
