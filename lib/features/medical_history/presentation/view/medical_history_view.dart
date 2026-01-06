import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/widgets/section_showcase_wrapper.dart';
import 'package:graduation_project/core/widgets/tutorial_tooltip_widget.dart';
import 'package:graduation_project/features/medical_history/presentation/manager/medical_qr/medicalqr_cubit.dart';
import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/conditions_allergies_section.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/family_history_section.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/health_profile_section.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/lab_results_section.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/medications_section.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/past_appointments_section.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/social_history_section.dart';
import 'package:graduation_project/features/medical_history/presentation/view/widgets/surgeries_section.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:showcaseview/showcaseview.dart';
// Imports
import 'package:graduation_project/core/utils/app_images.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/app_styles.dart';
import 'package:graduation_project/core/utils/functions/show_snack_bar.dart';
import 'package:graduation_project/core/utils/helper/secure_storage_helper.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
// Sections Imports... (تأكد من وجودهم)
// New Widgets
import 'widgets/medical_history_drawer.dart'; // ✅ استدعاء الملف الجديد

class MedicalHistoryView extends StatefulWidget {
  const MedicalHistoryView({super.key});

  @override
  State<MedicalHistoryView> createState() => _MedicalHistoryViewState();
}

class _MedicalHistoryViewState extends State<MedicalHistoryView> {
  // ✅ 1. مفتاح الـ Scaffold هو الحل لفتح الدراور
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // مفاتيح الـ Showcase
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

  void _scrollToSection(GlobalKey key) {
    // إغلاق الدراور باستخدام المفتاح الصحيح
    if (_scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
      _scaffoldKey.currentState?.closeEndDrawer();
    }

    // تأخير بسيط للتأكد من إغلاق الدراور قبل السكرول
    Future.delayed(const Duration(milliseconds: 100), () {
      if (key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
          alignment: 0.5, // النص في منتصف الشاشة
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
    final medicalQrCubit = context.read<MedicalqrCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: medicalQrCubit,
          child: Builder(
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                contentPadding: const EdgeInsets.all(20),

                // 🔥 الحل هنا: نغلف الـ Column بـ SizedBox ونديله عرض ثابت (أو عرض الشاشة)
                content: SizedBox(
                  width:
                      MediaQuery.of(context).size.width *
                      0.8, // 👈 إجبار العرض على 80% من الشاشة
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Share Medical History",
                        style: AppStyles.styleBold20Dark,
                      ),
                      const SizedBox(height: 20),

                      Flexible(
                        child: SingleChildScrollView(
                          child: BlocBuilder<MedicalqrCubit, MedicalqrState>(
                            builder: (context, state) {
                              if (state is MedicalQrLoading) {
                                return const SizedBox(
                                  height: 200,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              } else if (state is MedicalQrSuccess) {
                                return Column(
                                  mainAxisSize:
                                      MainAxisSize.min, // 👈 مهمة برضه هنا
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: QrImageView(
                                        data:
                                            'https://healthcare-9dd79.web.app/share-history?token=${state.token}',
                                        // data:
                                        // 'http://localhost:64844/share-history?token=${state.token}',
                                        version: QrVersions.auto,
                                        size: 200.0,
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    const Text(
                                      "Let the doctor scan this code.\nValid for 10 minutes.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                );
                              } else if (state is MedicalQrFailure) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                  ),
                                  child: Text(
                                    state.errMessage,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                );
                              }
                              return const SizedBox(height: 200);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text("Close"),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

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
        autoPlay: false,
        enableAutoScroll: true,
        blurValue: 1,
        builder: (context) {
          return Scaffold(
            key: _scaffoldKey, // ✅ ربط المفتاح هنا ضروري جداً
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

            appBar: _buildAppBar(context),

            body: BlocConsumer<PatientProfileCubit, PatientProfileState>(
              buildWhen:
                  (prev, curr) =>
                      curr is PatientProfileSuccess ||
                      (curr is PatientProfileLoading &&
                          prev is! PatientProfileSuccess),
              listener: (context, state) {
                /* ... SnackBar logic ... */
              },
              builder: (context, state) {
                if (state is PatientProfileLoading &&
                    state is! PatientProfileSuccess) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is PatientProfileSuccess) {
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => _checkAndStartShowcase(context),
                  );
                  final profile = state.profile;

                  return SingleChildScrollView(
                    // ✅ Padding كبير تحت عشان آخر عنصر يطلع في نص الشاشة
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
                    child: Column(
                      children: [
                        _buildHeaderCard(),
                        const SizedBox(height: 24),

                        // استخدام الـ Wrapper النظيف
                        SectionShowcaseWrapper(
                          globalKey: _profileKey,
                          title: 'Health Profile',
                          description: 'Update your weight, height & info.',
                          stepIndex: 2,
                          totalSteps: totalSteps,
                          child: HealthProfileSection(
                            profile: profile,
                            onSave:
                                (m) => context
                                    .read<PatientProfileCubit>()
                                    .updateProfileInfo(m),
                          ),
                        ),
                        const SizedBox(height: 15),

                        SectionShowcaseWrapper(
                          globalKey: _familyKey,
                          title: 'Family History',
                          description: 'Record hereditary conditions.',
                          stepIndex: 3,
                          totalSteps: totalSteps,
                          child: FamilyHistorySection(
                            familyHistory: profile.familyHistory,
                            historyId: profile.medicalHistoryID,
                          ),
                        ),
                        // ... كرر نفس الـ Wrapper لباقي الأقسام (Social, Conditions, etc.)
                        // عشان الكود ميبقاش طويل في الشات، الفكرة واحدة.
                        const SizedBox(height: 15),
                        // مثال لقسم ثاني (Social History)
                        SectionShowcaseWrapper(
                          globalKey: _socialKey,
                          title: 'Social History',
                          description: 'Lifestyle habits like smoking.',
                          stepIndex: 4,
                          totalSteps: totalSteps,
                          child: SocialHistorySection(
                            socialHistory: profile.socialHistory,
                            historyId: profile.medicalHistoryID,
                          ),
                        ),

                        const SizedBox(height: 15),

                        SectionShowcaseWrapper(
                          globalKey: _conditionsKey,
                          title: 'Conditions',
                          description: 'Chronic diseases & allergies.',
                          stepIndex: 5,
                          totalSteps: totalSteps,
                          child: ConditionsAllergiesSection(profile: profile),
                        ),
                        const SizedBox(height: 15),

                        SectionShowcaseWrapper(
                          globalKey: _appointmentsKey,
                          title: 'Appointments',
                          description: 'View past doctor visits.',
                          stepIndex: 6,
                          totalSteps: totalSteps,
                          child: const PastAppointmentsSection(),
                        ),
                        const SizedBox(height: 15),

                        SectionShowcaseWrapper(
                          globalKey: _surgeriesKey,
                          title: 'Surgeries',
                          description: 'Past surgical procedures.',
                          stepIndex: 7,
                          totalSteps: totalSteps,
                          child: SurgeriesSection(
                            surgeries: profile.surgeries,
                            historyId: profile.medicalHistoryID,
                          ),
                        ),
                        const SizedBox(height: 15),

                        SectionShowcaseWrapper(
                          globalKey: _medicationsKey,
                          title: 'Medications',
                          description: 'Current active medicines.',
                          stepIndex: 8,
                          totalSteps: totalSteps,
                          child: MedicationsSection(
                            medications: [
                              ...profile.currentMedications,
                              ...profile.patientSelfMedications,
                            ],
                            historyId: profile.medicalHistoryID,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // مثال لآخر عنصر (Labs)
                        SectionShowcaseWrapper(
                          globalKey: _labsKey,
                          title: 'Lab & Radiology',
                          description: 'Upload and view test results.',
                          stepIndex: 9,
                          totalSteps: totalSteps,
                          child: LabResultsSection(
                            labTests: profile.labTests,
                            radiologyFiles: profile.radiologyFiles,
                            medicalHistoryId: profile.medicalHistoryID,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (state is PatientProfileFailure) {
                  return Center(child: Text(state.errMessage));
                }
                return const SizedBox();
              },
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('My Medical History', style: AppStyles.styleSemiBold18Dark),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          size: 20,
          color: Color(0xFF111827),
        ),
        onPressed: () => context.go(AppRouter.kHomePatient),
      ),
      actions: [
        BlocBuilder<PatientProfileCubit, PatientProfileState>(
          builder: (context, state) {
            if (state is PatientProfileSuccess) {
              return IconButton(
                icon: const Icon(
                  Icons.qr_code_2_rounded,
                  color: Color(0xFF111827),
                  size: 28,
                ),
                onPressed: () {
                  // 1. اطلب توليد الكود
                  context.read<MedicalqrCubit>().generateQrCode(
                    state.profile.medicalHistoryID,
                  );
                  // 2. افتح الديالوج
                  _showQrDialog(context);
                },
              );
            }
            return const SizedBox.shrink(); // لو لسه بيحمل منظهرش الزرار
          },
        ),

        const SizedBox(width: 8), // مسافة صغيرة
        Showcase.withWidget(
          key: _drawerBtnKey,
          // هنا ممكن نثبت الحجم لأنه زرار صغير
          height: 160,
          width: 280.w, // استخدمنا ScreenUtil
          container: TutorialTooltipWidget(
            title: 'Quick Navigation',
            description: 'Jump between sections easily.',
            currentStep: 1,
            totalSteps: totalSteps,
            onNext: () => ShowCaseWidget.of(context).next(),
            onSkip: () => ShowCaseWidget.of(context).dismiss(),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.menu_open_rounded,
              color: Color(0xFF111827),
              size: 28,
            ),
            // ✅ استخدام مفتاح السكافولد لفتح الدراور
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90E2).withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        gradient: const LinearGradient(
          colors: [Color(0xFFE3F2FD), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          SvgPicture.asset(
            Assets.imagesMedicalRecordsSvgrepoCom,
            height: 40,
            width: 40,
          ),
          const SizedBox(height: 16),
          Text('Health Profile', style: AppStyles.styleBold24Dark),
          const SizedBox(height: 6),
          Text(
            'Keep your medical records up to date.',
            style: AppStyles.styleRegular16GrayDark.copyWith(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
