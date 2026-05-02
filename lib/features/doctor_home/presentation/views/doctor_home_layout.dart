import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:graduation_project/core/utils/helper/session_manager.dart';
import 'package:graduation_project/features/auth/presentation/views/chat_view.dart';
import 'package:graduation_project/features/auth/presentation/views/test_setting_view.dart';
import 'package:graduation_project/features/chat/presentation/manager/chat_cubit/chat_cubit.dart';
import 'package:graduation_project/features/doctor_home/domain/repositories/doctor_profile_repository.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/doctor_home_view.dart';
import 'package:graduation_project/features/doctor_profile/presentation/manager/doctor_real_profile_cubit.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/doctor_profile_view.dart';

class DoctorHomeLayout extends StatefulWidget {
  const DoctorHomeLayout({super.key});

  @override
  State<DoctorHomeLayout> createState() => _DoctorHomeLayoutState();
}

class _DoctorHomeLayoutState extends State<DoctorHomeLayout> {
  int _currentIndex = 0;
  late List<Widget> _screens;
  bool _isCheckingAccess = true;

  static const Color activeBlue = Color(0xFF1B4E8C);
  static const Color activeGreen = Color(0xFF4CAF50);
  static const Color inactiveGray = Colors.grey;

  @override
  void initState() {
    super.initState();
    String userId = getIt<SessionManager>().userId;

    _screens = [
      DoctorHomeView(),
      ChatView(userId: userId, isDoctor: true),
      DoctorProfileView(),
      SettingsScreen(),
    ];
    _guardDoctorAccess();
  }

  Future<void> _guardDoctorAccess() async {
    final result = await getIt<DoctorProfileRepository>().checkProfileStatus();

    if (!mounted) {
      return;
    }

    result.fold(
      (_) {
        setState(() {
          _isCheckingAccess = false;
        });
      },
      (status) {
        if (status.isApproved || status.isActive) {
          setState(() {
            _isCheckingAccess = false;
          });
          return;
        }

        AppRouter.router.go(AppRouter.kDoctorProfileGate);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAccess) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BlocProvider.value(
      value: getIt<DoctorRealProfileCubit>(),
      child: Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 5,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
            currentIndex: _currentIndex,
            selectedItemColor: activeBlue,
            unselectedItemColor: inactiveGray,
            showUnselectedLabels: true,
            onTap: (index) => setState(() => _currentIndex = index),
            items: [
              _buildNavItem(Icons.home_filled, 'Home', 0),
              _buildNavItem(Icons.chat, 'Chats', 1),
              _buildNavItem(Icons.account_circle_outlined, 'Profile', 2),
              _buildNavItem(Icons.settings, 'Settings', 3),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    IconData icon,
    String label,
    int index,
  ) {
    final isActive = _currentIndex == index;

    return BottomNavigationBarItem(
      icon: Column(
        children: [
          index == 2
              ? BlocBuilder<ChatCubit, ChatState>(
                builder: (context, state) {
                  int totalUnread = 0;
                  if (state is ChatSuccess) {
                    totalUnread = state.chats.fold(
                      0,
                      (sum, chat) => sum + chat.unreadCount,
                    );
                  }

                  return Badge(
                    label: Text(totalUnread.toString()),
                    isLabelVisible: totalUnread > 0,
                    backgroundColor: Colors.redAccent,
                    child: Icon(
                      icon,
                      color: isActive ? activeBlue : inactiveGray,
                    ),
                  );
                },
              )
              : Icon(icon, color: isActive ? activeBlue : inactiveGray),

          const SizedBox(height: 3),
          if (isActive)
            Container(
              width: 25,
              height: 3,
              decoration: BoxDecoration(
                color: activeGreen,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
      label: label,
    );
  }
}
