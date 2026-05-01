import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/functions/show_snack_bar.dart';
import 'package:graduation_project/features/auth/presentation/manger/auth_cubit/auth_cubit.dart';
import 'package:graduation_project/features/doctor_home/domain/entities/doctor_profile_status_entity.dart';
import 'package:graduation_project/features/doctor_home/presentation/manager/doctor_profile_cubit.dart';
import 'package:graduation_project/features/doctor_home/presentation/manager/doctor_profile_state.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/status_card.dart';
import 'package:lottie/lottie.dart';

class ProfileCompletionLoadingContent extends StatefulWidget {
  final DoctorProfileStatusEntity? status;

  const ProfileCompletionLoadingContent({super.key, required this.status});

  @override
  State<ProfileCompletionLoadingContent> createState() =>
      _ProfileCompletionLoadingContentState();
}

class _ProfileCompletionLoadingContentState
    extends State<ProfileCompletionLoadingContent> {
  DoctorProfileStatusEntity? _currentStatus;
  DoctorProfileCubit? _cubit;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.status;
    _startPolling();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cubit = context.read<DoctorProfileCubit>();
  }

  @override
  void dispose() {
    _cubit?.stopPolling();
    super.dispose();
  }

  void _startPolling() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DoctorProfileCubit>().startPolling(
        onApproved: () {
          if (mounted) AppRouter.router.go(AppRouter.kHomeDoctor);
        },
        onRejected: (status) {
          if (mounted) setState(() => _currentStatus = status);
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final effectiveStatus = _currentStatus;

    return MultiBlocListener(
      listeners: [
        BlocListener<DoctorProfileCubit, DoctorProfileState>(
          listener: (context, state) {
            if (state is DoctorProfileDataSuccess) {
              AppRouter.router.go(
                AppRouter.kDoctorProfileCompletion,
                extra: {
                  'cubit': context.read<DoctorProfileCubit>(),
                  'profile': state.profile,
                },
              );
            }
            if (state is DoctorProfileDataFailure) {
              showSnackBar(context, state.errorMessage, Colors.red);
            }
          },
        ),
        BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is LogoutSuccess) {
              context.go(AppRouter.kLogin);
            }
            if (state is LogoutFailure) {
              showSnackBar(context, state.errMessage, Colors.red);
            }
            if (state is LoginFailure) {
              showSnackBar(context, state.errMessage, Colors.red);
            }
          },
        ),
      ],
      child: BlocBuilder<DoctorProfileCubit, DoctorProfileState>(
        builder: (context, doctorState) {
          final authState = context.watch<AuthCubit>().state;
          final isFetchingProfile = doctorState is DoctorProfileDataLoading;
          final isLoggingOut = authState is LogoutLoading;
          final isRejected = effectiveStatus?.isRejected == true;

          return Scaffold(
            backgroundColor: const Color(0xfffaf0ff),
            body: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.w),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 86.w,
                        height: 86.w,
                        decoration: BoxDecoration(
                          color:
                              isRejected
                                  ? const Color(0xFFFEE2E2)
                                  : const Color(0xFFDBEAFE),
                          shape: BoxShape.circle,
                        ),
                        child:
                            isRejected
                                ? Icon(
                                  Icons.error,
                                  size: 40.sp,
                                  color: const Color(0xFFB91C1C),
                                )
                                : Lottie.asset(
                                  'assets/lottie/blue loading.json',
                                  height: 15.h,
                                ),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        isRejected
                            ? 'Profile Update Required'
                            : 'Reviewing Your Profile',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1B4E8C),
                        ),
                      ),
                      SizedBox(height: 14.h),
                      Text(
                        isRejected
                            ? 'Your profile needs changes before it can be approved. You can update the submitted information and resubmit it now.'
                            : 'Our admin team is reviewing your submitted information. You can update your profile at any time and resubmit the latest version.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF6B7280),
                          height: 1.6,
                        ),
                      ),
                      if (effectiveStatus
                              ?.missingRequiredVerificationDocuments
                              .isNotEmpty ==
                          true) ...[
                        SizedBox(height: 20.h),
                        StatusCard(
                          title: 'Missing Documents',
                          color: const Color(0xFFDBEAFE),
                          textColor: const Color(0xFF1B4E8C),
                          child: Text(
                            effectiveStatus!
                                .missingRequiredVerificationDocuments
                                .join(', '),
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: const Color(0xFF1B4E8C),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                      if (isRejected &&
                          effectiveStatus?.verificationRejectionReason
                                  ?.trim()
                                  .isNotEmpty ==
                              true) ...[
                        SizedBox(height: 20.h),
                        StatusCard(
                          title: 'Rejection Reason',
                          color: const Color(0xFFFEE2E2),
                          textColor: const Color(0xFFB91C1C),
                          child: Text(
                            effectiveStatus!.verificationRejectionReason!,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: const Color(0xFFB91C1C),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                      if (isRejected &&
                          effectiveStatus?.verificationAdminNotes
                                  ?.trim()
                                  .isNotEmpty ==
                              true) ...[
                        SizedBox(height: 16.h),
                        StatusCard(
                          title: 'Admin Notes',
                          color: const Color(0xFFFFF7ED),
                          textColor: const Color(0xFF9A3412),
                          child: Text(
                            effectiveStatus!.verificationAdminNotes!,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: const Color(0xFF9A3412),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                      SizedBox(height: 28.h),
                      SizedBox(
                        width: double.infinity,
                        height: 52.h,
                        child: ElevatedButton(
                          onPressed:
                              isFetchingProfile
                                  ? null
                                  : () =>
                                      context
                                          .read<DoctorProfileCubit>()
                                          .loadDoctorProfile(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B4E8C),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child:
                              isFetchingProfile
                                  ? SizedBox(
                                    width: 22.w,
                                    height: 22.w,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Text('Edit & Resubmit Profile'),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      SizedBox(
                        width: double.infinity,
                        height: 52.h,
                        child: OutlinedButton(
                          onPressed:
                              isLoggingOut
                                  ? null
                                  : () => context.read<AuthCubit>().logout(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFFB91C1C),
                            side: const BorderSide(color: Color(0xFFB91C1C)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child:
                              isLoggingOut
                                  ? SizedBox(
                                    width: 22.w,
                                    height: 22.w,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: Color(0xFFB91C1C),
                                    ),
                                  )
                                  : const Text('Logout'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
