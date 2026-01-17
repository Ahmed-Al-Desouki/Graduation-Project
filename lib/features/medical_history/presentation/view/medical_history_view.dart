import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/utils/functions/show_snack_bar.dart';
import 'package:graduation_project/features/medical_history/presentation/manager/medical_qr/medicalqr_cubit.dart';
import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/medical_history_app_bar.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/medical_history_main_list.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/medical_history_no_internet.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/medical_qr_dialog_content.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:graduation_project/core/utils/helper/secure_storage_helper.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'widgets/medical_history_drawer.dart';

class MedicalHistoryView extends StatefulWidget {
  const MedicalHistoryView({super.key});
  @override
  State<MedicalHistoryView> createState() => _MedicalHistoryViewState();
}

class _MedicalHistoryViewState extends State<MedicalHistoryView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final GlobalKey _drawerBtnKey = GlobalKey();
  final GlobalKey _profileKey = GlobalKey();
  final GlobalKey _familyKey = GlobalKey();
  final GlobalKey _socialKey = GlobalKey();
  final GlobalKey _conditionsKey = GlobalKey();
  final GlobalKey _appointmentsKey = GlobalKey();
  final GlobalKey _surgeriesKey = GlobalKey();
  final GlobalKey _medicationsKey = GlobalKey();
  final GlobalKey _labsKey = GlobalKey();

  final int totalSteps = 9;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<PatientProfileCubit>()..getProfile(),
        ),
        BlocProvider(create: (context) => getIt<MedicalqrCubit>()),
      ],
      child: ShowCaseWidget(
        builder:
            (context) => BlocListener<PatientProfileCubit, PatientProfileState>(
              listener: (context, state) {
                if (state is PatientUpdateSuccess) {
                  showSnackBar(context, state.message, Colors.green);
                } else if (state is PatientOperationSuccess) {
                  showSnackBar(context, state.message, Colors.green);
                } else if (state is PatientUploadSuccess) {
                  showSnackBar(context, state.message, Colors.green);
                } else if (state is PatientDeleteSuccess) {
                  showSnackBar(context, state.message, Colors.green);
                } else if (state is PatientUpdateFailure) {
                  showSnackBar(context, state.errMessage, Colors.red);
                } else if (state is PatientOperationFailure) {
                  showSnackBar(context, state.errMessage, Colors.red);
                } else if (state is PatientUploadFailure) {
                  showSnackBar(context, state.errMessage, Colors.red);
                } else if (state is PatientDeleteFailure) {
                  showSnackBar(context, state.errMessage, Colors.red);
                }
              },
              child: Scaffold(
                key: _scaffoldKey,
                backgroundColor: const Color(0xFFF3F4F6),
                endDrawer: MedicalHistoryDrawer(
                  onScrollToSection: _scrollToSection,
                  profileKey: _profileKey,
                  familyKey: _familyKey,
                  socialKey: _socialKey,
                  conditionsKey: _conditionsKey,
                  appointmentsKey: _appointmentsKey,
                  surgeriesKey: _surgeriesKey,
                  medicationsKey: _medicationsKey,
                  labsKey: _labsKey,
                ),
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(kToolbarHeight),
                  child: BlocBuilder<PatientProfileCubit, PatientProfileState>(
                    builder: (context, state) {
                      return MedicalHistoryAppBar(
                        scaffoldKey: _scaffoldKey,
                        drawerBtnKey: _drawerBtnKey,
                        totalSteps: totalSteps,
                        showQrButton:
                            state is PatientProfileSuccess && !state.isOffline,
                        onQrPressed: () {
                          if (state is PatientProfileSuccess) {
                            context.read<MedicalqrCubit>().generateQrCode(
                              state.profile.medicalHistoryID,
                            );
                            _showQrDialog(context);
                          }
                        },
                      );
                    },
                  ),
                ),
                body: _buildBlocBody(),
              ),
            ),
      ),
    );
  }

  void _scrollToSection(GlobalKey key) {
    if (_scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
      _scaffoldKey.currentState?.closeEndDrawer();
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      if (key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
          alignment: 0.5,
        );
      }
    });
  }

  void _checkAndStartShowcase(BuildContext localContext) async {
    String? userId = await SecureStorageHelper.getUserId();
    if (userId != null) {
      var box =
          Hive.isBoxOpen('settings')
              ? Hive.box('settings')
              : await Hive.openBox('settings');
      String key = 'history_tutorial_shown_$userId';

      if (!box.get(key, defaultValue: false)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (localContext.mounted) {
            ShowCaseWidget.of(localContext).startShowCase([
              _drawerBtnKey,
              _profileKey,
              _familyKey,
              _socialKey,
              _conditionsKey,
              _appointmentsKey,
              _surgeriesKey,
              _medicationsKey,
              _labsKey,
            ]);
          }
        });
        await box.put(key, true);
      }
    }
  }

  void _showQrDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: context.read<MedicalqrCubit>(),
          child: AlertDialog(
            backgroundColor: Colors.white,
            content: MedicalQrDialogContent(),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text("Close"),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBlocBody() {
    return BlocBuilder<PatientProfileCubit, PatientProfileState>(
      buildWhen: (previous, current) {
        return current is PatientProfileSuccess ||
            current is PatientProfileFailure ||
            current is PatientProfileLoading;
      },
      builder: (context, state) {
        if (state is PatientProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PatientProfileFailure) {
          if (state.errMessage.toLowerCase().contains('internet') ||
              state.errMessage.toLowerCase().contains('connection')) {
            return MedicalHistoryNoInternet(
              onRetry: () => context.read<PatientProfileCubit>().getProfile(),
            );
          }
          return Center(child: Text(state.errMessage));
        }

        if (state is PatientProfileSuccess) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _checkAndStartShowcase(context),
          );

          return MedicalHistoryMainList(
            profile: state.profile,
            isOffline: state.isOffline,
            totalSteps: totalSteps,
            profileKey: _profileKey,
            familyKey: _familyKey,
            socialKey: _socialKey,
            conditionsKey: _conditionsKey,
            appointmentsKey: _appointmentsKey,
            surgeriesKey: _surgeriesKey,
            medicationsKey: _medicationsKey,
            labsKey: _labsKey,
          );
        }
        return const SizedBox();
      },
    );
  }
}
