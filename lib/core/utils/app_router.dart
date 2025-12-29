import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:graduation_project/features/medical_history/domain/models/family_history_model.dart';
import 'package:graduation_project/features/medical_history/domain/models/medical_file_model.dart';
import 'package:graduation_project/features/medical_history/domain/models/medication_model.dart';
import 'package:graduation_project/features/medical_history/domain/models/surgery_model.dart';
import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';
import 'package:graduation_project/features/medical_history/presentation/view/all_family_history_view.dart';
import 'package:graduation_project/features/medical_history/presentation/view/all_lab_results_view.dart';
import 'package:graduation_project/features/medical_history/presentation/view/all_medications_view.dart';
import 'package:graduation_project/features/medical_history/presentation/view/all_surgeries_view.dart';
import 'package:graduation_project/features/auth/presentation/layout/patient_home_layout.dart';
import 'package:graduation_project/features/auth/presentation/manger/auth_cubit/auth_cubit.dart';
import 'package:graduation_project/features/reminder/presentation/manager/reminder_cubit/reminder_cubit.dart';
import 'package:graduation_project/features/auth/presentation/views/biometric_auth_view.dart';
import 'package:graduation_project/features/auth/presentation/views/create_account_view.dart';
import 'package:graduation_project/features/auth/presentation/views/doctor_home_view.dart';
import 'package:graduation_project/features/auth/presentation/views/doctor_registration_view.dart';
import 'package:graduation_project/features/auth/presentation/views/login_view.dart';
import 'package:graduation_project/features/auth/presentation/views/otp_screen.dart';
import 'package:graduation_project/features/auth/presentation/views/patient_registration_view.dart';
import 'package:graduation_project/features/reminder/presentation/views/reminder_view.dart';
import 'package:graduation_project/features/auth/presentation/views/reset_password_view.dart';
import 'package:graduation_project/features/auth/presentation/views/reset_success_view.dart';
import 'package:graduation_project/features/auth/presentation/views/test_setting_view.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/forgot_password.dart';
import 'package:graduation_project/features/medical_history/presentation/view/medical_history_view.dart';
import 'package:graduation_project/features/splash/presentation/views/widgets/splash_body.dart';

abstract class AppRouter {
  static const kSplash = '/';
  static const kLogin = '/loginView';
  static const kRegisterAsPatient = '/registerAsPatient';
  static const kRegisterAsDoctor = '/registerAsDoctor';
  static const kForgotPassword = '/forgotPasswordView';
  static const kCreatAcount = '/createAcountView';
  // static const kHome = '/home';
  static const kHomePatient = '/home/patient';
  static const kHomeDoctor = '/home/doctor';
  static const kReminder = '/reminder';
  static const kResetPassword = '/resetPassword';
  static const kResetSuccess = '/resetSuccess';
  static const kSettings = '/settings';
  static const kBiometric = '/biometric';
  static const kOtpScreen = '/otpScreen';
  static const kMedicalHistory = '/medicalHistory';
  static const kAllSurgeries = '/medicalHistory/allSurgeries';
  static const kAllMedications = '/medicalHistory/allMedications';
  static const kAllFamilyHistory = '/medicalHistory/allFamilyHistory';
  static const kLabResults = '/medicalHistory/labResults';
  // static const kMedicalHistory = '/';
  // https://nonvolitional-unstuccoed-wilfred.ngrok-free.dev/api/
  static final router = GoRouter(
    routes: [
      GoRoute(path: kSplash, builder: (context, state) => const SplashBody()),

      GoRoute(
        path: kCreatAcount,
        builder: (context, state) => const CreateAccountView(),
      ),

      GoRoute(
        path: kRegisterAsPatient,
        builder:
            (context, state) => BlocProvider(
              create: (_) => getIt<AuthCubit>(),
              child: const PatientRegistrationView(),
            ),
      ),

      GoRoute(
        path: kLogin,
        builder:
            (context, state) => BlocProvider(
              create: (_) => getIt<AuthCubit>(),
              child: const LoginView(),
            ),
      ),

      GoRoute(
        path: kRegisterAsDoctor,
        builder:
            (context, state) => BlocProvider(
              create: (_) => getIt<AuthCubit>(),
              child: const DoctorRegistrationView(),
            ),
      ),

      GoRoute(
        path: kForgotPassword,
        builder:
            (context, state) => BlocProvider(
              create: (_) => getIt<AuthCubit>(),
              child: const ForgotPassword(),
            ),
      ),

      // GoRoute(path: kHome, builder: (context, state) => const SplashBody()),
      GoRoute(
        path: kHomePatient,
        builder: (context, state) => const PatientHomeLayout(),
      ),

      GoRoute(
        path: kHomeDoctor,
        builder: (context, state) => const DoctorHomeView(),
      ),

      // GoRoute(
      //   path: kReminder,
      //   builder: (context, state) => const ReminderView(),
      // ),
      // GoRoute(
      //   path: kReminder,
      //   builder:
      //       (context, state) => BlocProvider(
      //         create:
      //             (_) => ReminderCubit(
      //               ReminderRepositoryImpl(ReminderWebService(ApiService())),
      //             )..loadReminders(),
      //         child: const ReminderView(),
      //       ),
      // ),
      GoRoute(
        path: kReminder,
        builder:
            (context, state) => BlocProvider(
              create: (_) => getIt<ReminderCubit>(),
              child: const ReminderView(),
            ),
      ),

      GoRoute(
        path: kResetPassword,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'];
          final token = state.uri.queryParameters['token'];

          return BlocProvider(
            create: (_) => getIt<AuthCubit>(),
            child: ResetPasswordView(email: email ?? '', token: token ?? ''),
          );
        },
      ),

      GoRoute(
        path: kResetSuccess,
        builder: (context, state) => const ResetSuccessView(),
      ),
      GoRoute(
        path: kSettings,
        builder: (context, state) => const SettingsScreen(),
      ),

      GoRoute(
        path: kBiometric,
        builder: (context, state) => const BiometricAuthScreen(),
      ),

      GoRoute(
        path: kOtpScreen,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          final email = data['email'] as String;
          final password = data['password'] as String;
          final mfaToken = data['mfaToken'] as String;

          return BlocProvider(
            create: (_) => getIt<AuthCubit>(),
            child: OtpScreen(
              email: email,
              password: password,
              mfaToken: mfaToken,
            ),
          );
        },
      ),
      GoRoute(
        path: kMedicalHistory,
        builder: (context, state) => const MedicalHistoryView(),
      ),

      GoRoute(
        path: kAllSurgeries,
        builder: (context, state) {
          // استقبال البيانات الممررة
          final extras = state.extra as Map<String, dynamic>;
          return AllSurgeriesView(
            allSurgeries: extras['surgeries'] as List<SurgeryModel>,
            historyId: extras['historyId'] as int,
            cubit: extras['cubit'] as PatientProfileCubit,
          );
        },
      ),

      // GoRoute(
      //   path: kAllMedications,
      //   builder: (context, state) {
      //     final extras = state.extra as Map<String, dynamic>;
      //     return AllMedicationsView(
      //       allMedications: extras['medications'] as List<MedicationModel>,
      //       historyId: extras['historyId'] as int,
      //       cubit: extras['cubit'] as PatientProfileCubit,
      //     );
      //   },
      // ),
      GoRoute(
        path: kAllMedications,
        builder: (context, state) {
          // ✅ تأمين صفحة الأدوية
          final extras = state.extra as Map<String, dynamic>?;

          if (extras == null) {
            // لو حصل ريستارت والداتا طارت، ارجع لصفحة الميدكال هيستوري الرئيسية
            return const MedicalHistoryView();
          }

          return BlocProvider(
            create: (context) => getIt<PatientProfileCubit>(),
            child: AllMedicationsView(
              allMedications: extras['medications'] as List<MedicationModel>,
              historyId: extras['historyId'] as int,
              cubit: extras['cubit'] as PatientProfileCubit,
            ),
          );
        },
      ),

      GoRoute(
        path: kAllFamilyHistory,
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>?;
          if (extras == null) return const MedicalHistoryView();

          return AllFamilyHistoryView(
            allRecords: extras['familyHistory'] as List<FamilyHistoryModel>,
            historyId: extras['historyId'] as int,
            cubit: extras['cubit'] as PatientProfileCubit,
          );
        },
      ),

      // GoRoute(
      //   path:
      //       kLabResults, // تأكد إن الاسم ده مطابق للي استخدمته في context.push
      //   builder: (context, state) {
      //     final extras = state.extra as Map<String, dynamic>?;

      //     // لو مفيش داتا، نرجعه للصفحة الرئيسية كحماية
      //     if (extras == null) return const MedicalHistoryView();

      //     return AllLabResultsView(
      //       // ✅ لازم الأسماء هنا تطابق المفاتيح (Keys) اللي بعتناها في الـ push
      //       labTests: extras['labTests'] as List<MedicalFileModel>,
      //       radiologyFiles: extras['radiologyFiles'] as List<MedicalFileModel>,
      //       historyId: extras['historyId'] as int,
      //       cubit: extras['cubit'] as PatientProfileCubit,
      //     );
      //   },
      // ),
      GoRoute(
        path: kLabResults,
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>?;

          if (extras == null) return const MedicalHistoryView();

          // ✅ تحويل آمن للبيانات (Safe Casting)
          // لأن GoRouter أحياناً بيعتبر الليست List<dynamic> ومبينفعش تتحول مباشرة لـ List<Model>
          final labTests =
              (extras['labTests'] as List)
                  .map((e) => e as MedicalFileModel)
                  .toList();

          final radiologyFiles =
              (extras['radiologyFiles'] as List)
                  .map((e) => e as MedicalFileModel)
                  .toList();

          return AllLabResultsView(
            labTests: labTests,
            radiologyFiles: radiologyFiles,
            historyId: extras['historyId'] as int,
            cubit: extras['cubit'] as PatientProfileCubit,
          );
        },
      ),
    ],
  );
}
