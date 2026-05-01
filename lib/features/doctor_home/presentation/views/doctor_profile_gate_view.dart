import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/functions/show_snack_bar.dart';
import 'package:graduation_project/features/doctor_home/presentation/manager/doctor_profile_cubit.dart';
import 'package:graduation_project/features/doctor_home/presentation/manager/doctor_profile_state.dart';

class DoctorProfileGateView extends StatefulWidget {
  const DoctorProfileGateView({super.key});

  @override
  State<DoctorProfileGateView> createState() => _DoctorProfileGateViewState();
}

class _DoctorProfileGateViewState extends State<DoctorProfileGateView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DoctorProfileCubit>().loadDoctorFlow();
    });
  }

  void _handleDoctorFlow(BuildContext context, DoctorFlowSuccess state) {
    final status = state.status;
    final cubit = context.read<DoctorProfileCubit>();

    if (status.isApproved || status.isActive) {
      AppRouter.router.go(AppRouter.kHomeDoctor);
      return;
    }

    if (!status.isProfileCompleted || status.isIncomplete) {
      AppRouter.router.go(
        AppRouter.kDoctorProfileCompletion,
        extra: {'cubit': cubit},
      );
      return;
    }

    AppRouter.router.go(
      AppRouter.kProfileCompletionLoading,
      extra: {'cubit': cubit, 'status': status},
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DoctorProfileCubit, DoctorProfileState>(
      listener: (context, state) {
        if (state is DoctorFlowSuccess) {
          _handleDoctorFlow(context, state);
        }

        if (state is DoctorFlowFailure) {
          showSnackBar(context, state.errorMessage, Colors.red);
        }
      },
      builder: (context, state) {
        final hasError = state is DoctorFlowFailure;

        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!hasError) const CircularProgressIndicator(),
                  const SizedBox(height: 24),
                  Text(
                    hasError
                        ? 'We could not load your doctor profile right now.'
                        : 'Checking your doctor profile...',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    hasError
                        ? 'Please try again. If the issue continues, log in again and retry.'
                        : 'Please wait while we route you to the correct doctor flow.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  if (hasError) ...[
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.read<DoctorProfileCubit>().loadDoctorFlow();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
