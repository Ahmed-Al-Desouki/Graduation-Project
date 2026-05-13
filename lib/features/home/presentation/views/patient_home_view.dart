import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/core/utils/functions/show_snack_bar.dart';
import 'package:graduation_project/core/utils/helper/secure_storage_helper.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:graduation_project/features/booking/presentation/manager/appointments_center_cubit/appointment_center_cubit.dart';
import 'package:graduation_project/features/home/presentation/views/widgets/next_reminder_card.dart';
import 'package:graduation_project/features/home/presentation/views/widgets/upcoming_appointments.dart';
import 'package:graduation_project/features/home/presentation/manager/home_cubit/home_cubit.dart';
import 'package:graduation_project/features/reminder/presentation/manager/reminder_cubit/reminder_cubit.dart';
import 'package:hive/hive.dart';
import 'package:showcaseview/showcaseview.dart';
import 'widgets/patient_home_header.dart';
import 'widgets/home_quick_actions_list.dart';

class PatientHomeView extends StatefulWidget {
  const PatientHomeView({super.key});

  @override
  State<PatientHomeView> createState() => _PatientHomeViewState();
}

class _PatientHomeViewState extends State<PatientHomeView> {
  final GlobalKey _notificationKey = GlobalKey();
  final GlobalKey _searchDoctorKey = GlobalKey();
  final GlobalKey _remindersKey = GlobalKey();
  final GlobalKey _historyKey = GlobalKey();

  final int totalSteps = 4;
  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
    _loadData();
  }

  void _requestNotificationPermission() {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  void _checkAndStartShowcase(BuildContext localContext) async {
    // String? userId = await SecureStorageHelper.getUserId();
    // if (userId != null) {
    var box =
        Hive.isBoxOpen('settings')
            ? Hive.box('settings')
            : await Hive.openBox('settings');
    // String key = 'home_tutorial_shown_$userId';
    String key = 'Home_global_feature_tutorial_done';

    bool isShown = box.get(key, defaultValue: false);

    if (!isShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ShowCaseWidget.of(localContext).startShowCase([
          _notificationKey,
          _searchDoctorKey,
          _remindersKey,
          _historyKey,
        ]);
      });
      await box.put(key, true);
    }
    // }
  }

  void _loadData() async {
    final patientId = await SecureStorageHelper.getUserId();
    if (mounted) {
      context.read<HomeCubit>().getHomeUserInfo();
      // context.read<AppointmentsCenterCubit>().getPatientAppointments();
      if (patientId != null) {
        context.read<ReminderCubit>().getUpcomingReminders(
          patientId: patientId,
        );
        context.read<ReminderCubit>().syncOfflineActions();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              getIt<AppointmentsCenterCubit>()..getPatientAppointments(),
      child: ShowCaseWidget(
        autoPlay: false,
        enableAutoScroll: true,
        blurValue: 1,
        builder: (context) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _checkAndStartShowcase(context);
          });

          return Scaffold(
            backgroundColor: const Color(0xffE8F7F2),
            body: MultiBlocListener(
              listeners: [
                BlocListener<HomeCubit, HomeState>(
                  listener: (context, state) {
                    if (state is HomeFailure) {
                      showSnackBar(context, state.errMessage, Colors.red);
                    }
                  },
                ),
              ],
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderSection(),
                    SizedBox(height: 20.h),

                    const UpcomingAppointments(),

                    const NextReminderCard(),
                    SizedBox(height: 30.h),
                    HomeQuickActionsList(
                      searchDoctorKey: _searchDoctorKey,
                      remindersKey: _remindersKey,
                      historyKey: _historyKey,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection() {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        String name = "User";
        String? image;

        if (state is HomeSuccess) {
          name = state.user.fullName;
          image = state.user.imageUrl;
        }

        return PatientHomeHeader(
          userName: name,
          imageUrl: image,
          notificationKey: _notificationKey,
        );
      },
    );
  }
}
