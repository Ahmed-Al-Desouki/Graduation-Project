import 'package:go_router/go_router.dart';
import 'package:graduation_project/features/auth/presentation/views/create_account_view.dart';
import 'package:graduation_project/features/auth/presentation/views/doctor_registration_view.dart';
import 'package:graduation_project/features/auth/presentation/views/login_view.dart';
import 'package:graduation_project/features/auth/presentation/views/patient_registration_view.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/forgot_password.dart';
import 'package:graduation_project/features/splash/splash_body.dart';

abstract class AppRouter {
  // static const kOnboardingView = '/onboardingView';
  static const kSplash = '/';
  static const kLogin = '/loginView';
  static const kRegisterAsPatient = '/registerAsPatient';
  static const kRegisterAsDoctor = '/registerAsDoctor';
  static const kForgotPassword = '/forgotPasswordView';
  static const kCreatAcount = '/createAcountView';
  static const kHome = '/home';

  static final router = GoRouter(
    routes: [
      GoRoute(path: kSplash, builder: (context, state) => const SplashBody()),
      GoRoute(
        path: kCreatAcount,
        builder: (context, state) => const CreateAccountView(),
      ),
      GoRoute(
        path: kRegisterAsPatient,
        builder: (context, state) => const PatientRegistrationView(),
      ),
      GoRoute(path: kLogin, builder: (context, state) => const LoginView()),
      GoRoute(
        path: kRegisterAsDoctor,
        builder: (context, state) => const DoctorRegistrationView(),
      ),
      GoRoute(
        path: kForgotPassword,
        builder: (context, state) => const ForgotPassword(),
      ),
      GoRoute(path: kHome, builder: (context, state) => const SplashBody()),
    ],
  );
}
