import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:graduation_project/features/auth/presentation/layout/patient_home_layout.dart';
import 'package:graduation_project/features/auth/presentation/manger/auth_cubit/auth_cubit.dart';
import 'package:graduation_project/features/auth/presentation/views/biometric_auth_view.dart';
import 'package:graduation_project/features/auth/presentation/views/create_account_view.dart';
import 'package:graduation_project/features/auth/presentation/views/doctor_home_view.dart';
import 'package:graduation_project/features/auth/presentation/views/doctor_registration_view.dart';
import 'package:graduation_project/features/auth/presentation/views/login_view.dart';
import 'package:graduation_project/features/auth/presentation/views/otp_screen.dart';
import 'package:graduation_project/features/auth/presentation/views/patient_registration_view.dart';
// import 'package:graduation_project/features/auth/presentation/views/reminder_view.dart';
import 'package:graduation_project/features/auth/presentation/views/reset_password_view.dart';
import 'package:graduation_project/features/auth/presentation/views/reset_success_view.dart';
import 'package:graduation_project/features/auth/presentation/views/test_setting_view.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/forgot_password.dart';
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
  static const kResetPassword = '/resetPassword';
  static const kResetSuccess = '/resetSuccess';
  static const kSettings = '/settings';
  static const kBiometric = '/biometric';
  static const kOtpScreen = '/otpScreen';

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
    ],
  );
}
