import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:graduation_project/features/booking/presentation/manager/appointment_action_cubit/appointment_action_cubit.dart';
import 'package:graduation_project/features/booking/presentation/manager/booking_calendar_cubit/booking_calendar_cubit.dart';
import 'package:graduation_project/features/booking/presentation/manager/exam_session_cubit/exam_session_cubit.dart';
import 'package:graduation_project/features/booking/presentation/manager/schedule_management_cubit/schedule_management_cubit.dart';
import 'package:graduation_project/features/booking/presentation/views/appointments_center_view.dart';
import 'package:graduation_project/features/booking/presentation/views/booking_calendar_view.dart';
import 'package:graduation_project/features/booking/presentation/views/booking_success_view.dart';
import 'package:graduation_project/features/booking/presentation/views/medical_details_view.dart';
import 'package:graduation_project/features/booking/presentation/views/payment_web_view.dart';
import 'package:graduation_project/features/booking/presentation/views/schedule_setup_view.dart';
import 'package:graduation_project/features/chat/presentation/manager/chat_details_cubit/chat_details_cubit.dart';
import 'package:graduation_project/features/chat/presentation/views/chat_details_view.dart';
import 'package:graduation_project/features/doctor_home/presentation/manager/doctor_profile_cubit.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/doctor_home_layout.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/doctor_profile_completion_view.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/profile_completion_loading_view.dart';
import 'package:graduation_project/features/doctor_profile/presentation/manager/doctor_real_profile_cubit.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/all_achievements_view.dart';
import 'package:graduation_project/features/home/presentation/manager/home_cubit/home_cubit.dart';
import 'package:graduation_project/features/medical_history/domain/models/family_history_model.dart';
import 'package:graduation_project/features/medical_history/domain/models/medical_file_model.dart';
import 'package:graduation_project/features/medical_history/domain/models/medication_model.dart';
import 'package:graduation_project/features/medical_history/domain/models/surgery_model.dart';
import 'package:graduation_project/features/medical_history/presentation/manager/medical_qr/medicalqr_cubit.dart';
import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';
import 'package:graduation_project/features/medical_history/presentation/view/all_family_history_view.dart';
import 'package:graduation_project/features/medical_history/presentation/view/all_lab_results_view.dart';
import 'package:graduation_project/features/medical_history/presentation/view/all_medications_view.dart';
import 'package:graduation_project/features/medical_history/presentation/view/all_surgeries_view.dart';
import 'package:graduation_project/features/auth/presentation/layout/patient_home_layout.dart';
import 'package:graduation_project/features/auth/presentation/manger/auth_cubit/auth_cubit.dart';
import 'package:graduation_project/features/medical_history/presentation/view/shared_history_view.dart';
import 'package:graduation_project/features/notification/presentation/notification_cubit/notification_cubit.dart';
import 'package:graduation_project/features/notification/presentation/pages/notifications_page.dart';
import 'package:graduation_project/features/reminder/presentation/manager/reminder_cubit/reminder_cubit.dart';
import 'package:graduation_project/features/auth/presentation/views/biometric_auth_view.dart';
import 'package:graduation_project/features/auth/presentation/views/create_account_view.dart';
import 'package:graduation_project/features/auth/presentation/views/doctor_registration_view.dart';
import 'package:graduation_project/features/auth/presentation/views/login_view.dart';
import 'package:graduation_project/features/auth/presentation/views/otp_screen.dart';
import 'package:graduation_project/features/auth/presentation/views/patient_registration_view.dart';
import 'package:graduation_project/features/reminder/presentation/views/add_reminder_view.dart';
import 'package:graduation_project/features/reminder/presentation/views/reminder_view.dart';
import 'package:graduation_project/features/auth/presentation/views/reset_password_view.dart';
import 'package:graduation_project/features/auth/presentation/views/reset_success_view.dart';
import 'package:graduation_project/features/auth/presentation/views/test_setting_view.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/forgot_password.dart';
import 'package:graduation_project/features/medical_history/presentation/view/medical_history_view.dart';
import 'package:graduation_project/features/reminder/presentation/views/ringing_view.dart';
import 'package:graduation_project/features/search/presentation/manager/search_cubit/search_cubit.dart';
import 'package:graduation_project/features/search/presentation/views/search_view.dart';
import 'package:graduation_project/features/splash/presentation/views/widgets/onboarding_view.dart';
import 'package:graduation_project/features/reminder/presentation/views/widgets/all_reminders_view.dart';
import 'package:graduation_project/features/splash/presentation/views/widgets/splash_body.dart';
import 'package:graduation_project/features/support_tickets/presentation/manager/tickets_cubit/tickets_cubit.dart';
import 'package:graduation_project/features/support_tickets/presentation/pages/support_chat_page.dart';
import 'package:graduation_project/features/support_tickets/presentation/pages/support_tickets_page.dart';

abstract class AppRouter {
  static const kSplash = '/';
  static const kOnboarding = '/onboarding';
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
  static const kRinging = '/ringing';
  static const kAllReminders = '/allReminders';
  static const kAddReminder = '/addReminder';
  static const kChatDetails = '/chatDetails';
  static const kDoctorSchedule = '/doctorSchedule';
  static const kScheduleSetup = '/scheduleSetup';
  static const kMedicalDetails = '/medicalDetails';
  static const kSearch = '/search';
  static const kPaymentWebView = '/paymentWebView';
  static const kAppointmentsCenter = '/appointmentsCenter';
  static const kBookingSuccess = '/bookingSuccess';
  static const kDoctorProfileCompletion = '/doctor/profile-completion';
  static const kProfileCompletionLoading = '/doctor/profile-completion/loading';
  static const kAllAchievements = '/doctor/profile/all-achievements';
  static const kTickets = '/tickets';
  static const kNotifications = '/notifications';
  static const kBookingCalendar = '/booking-calendar';
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final router = GoRouter(
    navigatorKey: navigatorKey,
    routes: [
      GoRoute(path: kSplash, builder: (context, state) => const SplashBody()),
      GoRoute(
        path: kBookingSuccess,
        builder: (context, state) {
          final bookingData = state.extra as Map<String, dynamic>? ?? {};
          return BookingSuccessView(bookingData: bookingData);
        },
      ),
      GoRoute(
        path: kNotifications,
        builder:
            (context, state) => BlocProvider.value(
              value: getIt<NotificationCubit>(),
              child: const NotificationsPage(),
            ),
      ),
      GoRoute(
        path: kAppointmentsCenter,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          // هنا هننادي الشاشة الجديدة اللي هنعملها
          return AppointmentsCenterView(
            initialAppointments: extra?['initialAppointments'],
          );
        },
      ),
      // 1. شاشة إعداد الجدول
      GoRoute(
        path: kScheduleSetup,

        builder: (context, state) {
          final Map<String, dynamic>? extra =
              state.extra as Map<String, dynamic>?;

          return BlocProvider(
            create: (context) => getIt<ScheduleManagementCubit>(),
            // 💡 بنبعت الـ extra كله للـ View عشان ميتسحلش
            child: ScheduleSetupView(isEditing: true, followUpData: extra),
          );
        },
      ),

      GoRoute(
        path: kBookingCalendar, // مثلاً '/booking-calendar'
        builder: (context, state) {
          final Map<String, dynamic>? extra =
              state.extra as Map<String, dynamic>?;

          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => getIt<BookingCalendarCubit>()),
              BlocProvider(
                create: (context) => getIt<AppointmentActionCubit>(),
              ),
            ],
            child: BookingCalendarView(
              isPatientView: extra?['isPatientView'] ?? false,
              doctorId: extra?['doctorId']?.toString(),
              doctorName: extra?['doctorName'],
              consultationFee: (extra?['consultationFee'] as num?)?.toDouble(),
              followUpPatientName: extra?['patientName'],
              originalAppointmentId: extra?['originalAppointmentId'],
            ),
          );
        },
      ),

      GoRoute(
        path: kDoctorSchedule,
        builder: (context, state) {
          final Map<String, dynamic>? extra =
              state.extra as Map<String, dynamic>?;
          final bool isPatientView = extra?['isPatientView'] ?? false;

          if (isPatientView) {
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => getIt<BookingCalendarCubit>(),
                ),
                BlocProvider(
                  create: (context) => getIt<AppointmentActionCubit>(),
                ),
              ],
              child: BookingCalendarView(
                isPatientView: true,
                doctorId: extra?['doctorId']?.toString(),
                doctorName: extra?['doctorName'],
                consultationFee:
                    (extra?['consultationFee'] as num?)?.toDouble(),
              ),
            );
          }

          // 💡 للدكتور: بنبعته دايماً للـ SetupView وهي اللي هتشيك على الـ API
          return BlocProvider(
            create: (context) => getIt<ScheduleManagementCubit>(),
            child: const ScheduleSetupView(),
          );
        },
      ),

      GoRoute(
        path: kOnboarding,
        builder: (context, state) => const OnboardingView(),
      ),

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

      GoRoute(
        path: kHomePatient,
        builder:
            (context, state) => MultiBlocProvider(
              providers: [
                // BlocProvider(
                //   create:
                //       (context) =>
                //           getIt<NotificationCubit>()..fetchNotifications(),
                // ),
                // BlocProvider(create: (context) => getIt<ReminderCubit>()),
                // BlocProvider(create: (context) => getIt<HomeCubit>()),
                BlocProvider.value(
                  value: getIt<NotificationCubit>()..fetchNotifications(),
                ),
                BlocProvider(create: (context) => getIt<ReminderCubit>()),
                BlocProvider(create: (context) => getIt<HomeCubit>()),
              ],
              child: const PatientHomeLayout(),
            ),
      ),

      GoRoute(
        path: kHomeDoctor,
        builder:
            (context, state) => MultiBlocProvider(
              providers: [
                // BlocProvider(create: (_) => getIt<DoctorProfileCubit>()),
                // BlocProvider(
                //   create:
                //       (context) =>
                //           getIt<NotificationCubit>()..fetchNotifications(),
                // ),
                BlocProvider(create: (_) => getIt<DoctorProfileCubit>()),
                // 🚀 التعديل هنا: استخدم .value عشان الـ Provider ميقفلش الكيوبت
                BlocProvider.value(
                  value: getIt<NotificationCubit>()..fetchNotifications(),
                ),
              ],
              child: const DoctorHomeLayout(),
            ),
      ),

      // GoRoute(
      //   path: kHomeDoctor,
      //   builder: (context, state) => const DoctorHomeLayout(),
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
        path: kRinging,
        builder: (context, state) {
          final extra = state.extra as Map<dynamic, dynamic>?;
          final payload = extra?.map(
            (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
          );

          return RingingView(payload: payload);
        },
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
      // GoRoute(
      //   path: kMedicalHistory,
      //   builder: (context, state) => const MedicalHistoryView(),
      // ),
      GoRoute(
        path: kMedicalHistory,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return MedicalHistoryView(
            isDoctorView: extra['isDoctorView'] ?? false,
            patientId: extra['patientId']?.toString(),
            appointmentId: extra['appointmentId']?.toString(),
          );
        },
      ),

      GoRoute(
        path: kAllSurgeries,
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>;
          return AllSurgeriesView(
            allSurgeries: extras['surgeries'] as List<SurgeryModel>,
            historyId: extras['historyId'] as int,
            cubit: extras['cubit'] as PatientProfileCubit,
            isReadOnly: extras['isReadOnly'] ?? false,
          );
        },
      ),

      GoRoute(
        path: kAllMedications,
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>?;

          if (extras == null) {
            return const MedicalHistoryView();
          }

          return BlocProvider(
            create: (context) => getIt<PatientProfileCubit>(),
            child: AllMedicationsView(
              allMedications: extras['medications'] as List<MedicationModel>,
              historyId: extras['historyId'] as int,
              cubit: extras['cubit'] as PatientProfileCubit,
              isReadOnly: extras['isReadOnly'] ?? false,
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
            isReadOnly: extras['isReadOnly'] ?? false,
          );
        },
      ),

      GoRoute(
        path: kLabResults,
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>?;

          if (extras == null) return const MedicalHistoryView();
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
            isReadOnly: extras['isReadOnly'] ?? false,
          );
        },
      ),

      GoRoute(
        path: '/share-history',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'];

          if (token == null || token.isEmpty) {
            return const Scaffold(
              body: Center(child: Text("Invalid Link: No token found")),
            );
          }

          return BlocProvider(
            create: (context) => getIt<MedicalqrCubit>(),
            child: SharedHistoryView(token: token),
          );
        },
      ),

      GoRoute(
        path: kAllReminders,
        builder: (context, state) {
          final cubit = state.extra as ReminderCubit;
          return BlocProvider.value(value: cubit, child: AllRemindersView());
        },
      ),

      GoRoute(
        path: kAddReminder,
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>;
          return BlocProvider.value(
            value: extras['cubit'] as ReminderCubit,
            child: AddReminderView(
              initialType: extras['initialType'] as String?,
            ),
          );
        },
      ),

      // GoRoute(
      //   path: kChatDetails,
      //   builder: (context, state) {
      //     final data = state.extra as Map<String, dynamic>;
      //     return BlocProvider(
      //       create: (context) => getIt<ChatDetailsCubit>(),
      //       child: ChatDetailsView(
      //         chatId: data['chatId'] as String,
      //         receiverName: data['receiverName'] as String,
      //       ),
      //     );
      //   },
      // ),
      GoRoute(
        path: kChatDetails,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return BlocProvider(
            create: (context) => getIt<ChatDetailsCubit>(),
            child: ChatDetailsView(
              chatId: data['chatId'] as String,
              receiverName: data['receiverName'] as String,
              currentUserId: data['currentUserId'] as String,
              isDoctor: data['isDoctor'] as bool,
              // 🚀 زودنا دي عشان الـ Unread Marker يشتغل
              lastReadTimestamp: data['lastReadTimestamp'] as DateTime?,
            ),
          );
        },
      ),
      GoRoute(
        path: kMedicalDetails,
        builder: (context, state) {
          // ✅ تأمين الـ extra عشان ميعملش Crash لو مبعوتش
          final extra = state.extra as Map<String, dynamic>? ?? {};

          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => getIt<ExamSessionCubit>()),
              BlocProvider(
                create: (context) => getIt<AppointmentActionCubit>(),
              ),
            ],
            child:
            // MedicalDetailsView(
            //   appointmentId: extra['appointmentId'] ?? '',
            //   patientId: extra['patientId'] ?? '',
            //   patientName: extra['patientName'] ?? 'Unknown Patient',
            //   patientNote: extra['patientNote'],
            //   // ✅ تمرير الحالة (ضروري جداً للوجيك الـ Read-only)
            //   initialStatus: extra['status'] ?? 'booked',
            //   // doctorName: getIt<SessionManager>().userName,
            //   doctorName: extra['doctorName'], // 🚨 لازم دي تتضاف هنا
            //   doctorSpecialty: "Specialist",
            // ),
            MedicalDetailsView(
              appointmentId: extra['appointmentId'] ?? '',
              patientId:
                  extra['patientId']
                      ?.toString(), // ✅ مفيش Default value هنا عشان يقبل الـ Null
              patientName: extra['patientName'] ?? 'Patient',
              doctorName: extra['doctorName'] ?? 'Doctor',
              initialStatus: extra['status'] ?? 'Pending',
              patientNote: extra['patientNote'],
              isReadOnly: extra['isReadOnly'] ?? false,
              // doctorSpecialty: extra['doctorSpecialty'] ?? 'General',
            ),
          );
        },
      ),
      GoRoute(
        path: kSearch,
        builder:
            (context, state) => BlocProvider(
              create: (context) => getIt<SearchCubit>(),
              child: const SearchView(),
            ),
      ),

      GoRoute(
        path: kPaymentWebView,
        builder: (context, state) {
          final String url = state.extra as String;
          return PaymentWebViewPage(url: url);
        },
      ),
      GoRoute(
        path: kDoctorProfileCompletion,
        builder: (context, state) => const DoctorProfileCompletionView(),
      ),

      GoRoute(
        path: AppRouter.kProfileCompletionLoading,
        builder:
            (context, state) => BlocProvider.value(
              value: getIt<DoctorProfileCubit>(),
              child: const ProfileCompletionLoadingView(),
            ),
      ),

      // في app_router.dart
      GoRoute(
        path: kAllAchievements,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final cubit = extra['cubit'] as DoctorRealProfileCubit;

          return BlocProvider.value(
            value: cubit,
            child: const AllAchievementsView(),
          );
        },
      ),
      // inside your GoRouter configuration
      GoRoute(
        path: kTickets,
        builder:
            (context, state) => BlocProvider(
              create: (context) => getIt<TicketsCubit>(),
              child: const SupportTicketsPage(),
            ),
        routes: [
          // 🚀 صفحة الشات مضافة كـ Sub-route
          // GoRoute(
          //   path: 'ticket-chat', // المسار هيكون /tickets/ticket-chat
          //   builder: (context, state) {
          //     // بنستلم الـ ticket entity اللي باعتينها من صفحة القائمة
          //     // final ticket = state.extra as TicketEntity;
          //     // return SupportChatPage(ticket: ticket);
          //     final ticketId = state.extra as String;
          //     return SupportChatPage(ticketId: ticketId);
          //   },
          // ),
          GoRoute(
            path: 'ticket-chat',
            builder: (context, state) {
              String id = "";
              String? status;

              // 🚀 بنشيك على النوع اللي مبعوث في الـ extra
              if (state.extra is Map<String, dynamic>) {
                final data = state.extra as Map<String, dynamic>;
                id = data['id'];
                status = data['status'];
              } else if (state.extra is String) {
                id = state.extra as String;
              }

              return SupportChatPage(ticketId: id, initialStatus: status);
            },
          ),
        ],
      ),
    ],
  );
}
