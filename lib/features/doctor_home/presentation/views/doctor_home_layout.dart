import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:graduation_project/core/utils/helper/session_manager.dart';
import 'package:graduation_project/features/auth/presentation/views/chat_view.dart';
import 'package:graduation_project/features/auth/presentation/views/schedule_view.dart';
import 'package:graduation_project/features/auth/presentation/views/test_setting_view.dart';
import 'package:graduation_project/features/chat/presentation/manager/chat_cubit/chat_cubit.dart';
import 'package:graduation_project/features/doctor_home/presentation/manager/doctor_profile_cubit.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/doctor_home_view.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/profile_completion_dialog.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/doctor_profile_view.dart';

class DoctorHomeLayout extends StatefulWidget {
  const DoctorHomeLayout({super.key});

  @override
  State<DoctorHomeLayout> createState() => _DoctorHomeLayoutState();
}

class _DoctorHomeLayoutState extends State<DoctorHomeLayout> {
  int _currentIndex = 0;

  bool _isProfileComplete = false;
  bool _isLoadingStatus = true;

  bool _hasShownDialog = false;

  late List<Widget> _screens;

  static const Color activeBlue = Color(0xFF1B4E8C);
  static const Color activeGreen = Color(0xFF4CAF50);
  static const Color inactiveGray = Colors.grey;

  @override
  void initState() {
    super.initState();
    String userId = getIt<SessionManager>().userId;

    _screens = [
      DoctorHomeView(),
      ScheduleView(),
      ChatView(userId: userId, isDoctor: true),
      DoctorProfileView(),
      SettingsScreen(),
    ];
    _loadProfileStatus();
  }

  Future<void> _loadProfileStatus() async {
    final result =
        await getIt<DoctorProfileCubit>().repository.checkProfileStatus();

    result.fold(
      (_) {
        if (mounted) setState(() => _isLoadingStatus = false);
      },
      (data) {
        if (mounted) {
          final isActive = data['isActive'] == true;
          setState(() {
            _isProfileComplete = isActive;
            _isLoadingStatus = false;
          });

          if (!isActive && !_hasShownDialog) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showProfileCompletionDialog();
              _hasShownDialog = true;
            });
          }
        }
      },
    );
  }

  void _showProfileCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ProfileCompletionDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingStatus) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BlocProvider(
      create:
          (context) =>
              getIt<ChatCubit>()
                ..getMyChats(getIt<SessionManager>().userId, true),
      child: Scaffold(
        body: Stack(
          children: [
            _screens[_currentIndex],
            if (!_isProfileComplete)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(color: Colors.black.withValues(alpha: 0.3)),
                ),
              ),
          ],
        ),
        bottomNavigationBar:
            _isProfileComplete
                ? _buildBottomNavigationBar()
                : _buildDisabledBottomNavigationBar(),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
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
          _buildNavItem(Icons.schedule, 'Schedule', 1),
          _buildNavItem(Icons.chat, 'Chats', 2),
          _buildNavItem(Icons.account_circle_outlined, 'Profile', 3),
          _buildNavItem(Icons.settings, 'Settings', 4),
        ],
      ),
    );
  }

  Widget _buildDisabledBottomNavigationBar() {
    return Container(
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
        currentIndex: 0,
        selectedItemColor: inactiveGray,
        unselectedItemColor: inactiveGray.withValues(alpha: 0.5),
        showUnselectedLabels: true,
        onTap: null, // ✅ معطل
        items: [
          _buildDisabledNavItem(Icons.home_filled, 'Home'),
          _buildDisabledNavItem(Icons.schedule, 'Schedule'),
          _buildDisabledNavItem(Icons.chat, 'Chats'),
          _buildDisabledNavItem(Icons.account_circle_outlined, 'Profile'),
          _buildDisabledNavItem(Icons.settings, 'Settings'),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    IconData icon,
    String label,
    int index,
  ) {
    final bool isActive = _currentIndex == index;

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

  BottomNavigationBarItem _buildDisabledNavItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Column(
        children: [
          Icon(icon, color: inactiveGray.withValues(alpha: 0.5)),
          const SizedBox(height: 3),
        ],
      ),
      label: label,
    );
  }
}
