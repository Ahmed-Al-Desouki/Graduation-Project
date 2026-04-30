import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/features/chat/presentation/manager/chat_cubit/chat_cubit.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'widgets/chat_item_widget.dart';

class MessagesListView extends StatelessWidget {
  final String currentUserId;
  final bool isDoctor;

  const MessagesListView({
    super.key,
    required this.currentUserId,
    required this.isDoctor,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => getIt<ChatCubit>()..getMyChats(currentUserId, isDoctor),
      child: Builder(
        builder: (newContext) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildSearchBar(newContext),
                  Expanded(child: _buildBlocBody()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Messages",
            style: TextStyle(
              fontSize: 26.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          BlocBuilder<ChatCubit, ChatState>(
            builder: (context, state) {
              if (state is ChatSuccess) {
                final total = state.chats.fold(
                  0,
                  (sum, c) => sum + c.unreadCount,
                );
                if (total == 0) return const SizedBox();
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    "$total New",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: TextField(
        onChanged: (value) => context.read<ChatCubit>().filterChats(value),
        decoration: InputDecoration(
          hintText:
              isDoctor ? "Search for a patient..." : "Search for a doctor...",
          prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildBlocBody() {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        if (state is ChatLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF2563EB)),
          );
        } else if (state is ChatFailure) {
          return Center(
            child: Text(
              state.errMessage,
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else if (state is ChatSuccess) {
          if (state.chats.isEmpty) return _buildEmptyState();

          return ListView.separated(
            padding: EdgeInsets.only(top: 10.h, bottom: 20.h),
            itemCount: state.chats.length,
            separatorBuilder:
                (context, index) => Divider(
                  height: 1,
                  color: Colors.grey.shade50,
                  indent: 80.w,
                ),
            itemBuilder: (context, index) {
              final chat = state.chats[index];
              return ChatItemWidget(
                isDoctor: isDoctor,
                chat: chat,
                onTap: () {
                  context.push(
                    AppRouter.kChatDetails,
                    extra: {
                      'chatId': chat.chatId,
                      'receiverName':
                          isDoctor ? chat.patientName : chat.doctorName,
                      'currentUserId': currentUserId,
                      'isDoctor': isDoctor,
                      'lastReadTimestamp': chat.lastReadTimestamp,
                    },
                  );
                },
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 100.sp,
            color: Colors.blue.withValues(alpha: 0.1),
          ),
          SizedBox(height: 20.h),
          Text(
            "No conversations found",
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.blueGrey.shade300,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
