// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:graduation_project/features/chat/presentation/manager/chat_cubit/chat_cubit.dart';
// import 'package:lottie/lottie.dart'; // بما أنك تستخدم Lottie في الأونبوردينج
// import 'widgets/chat_item_widget.dart'; // الويدجيت اللي عملناها

// class MessagesListView extends StatefulWidget {
//   const MessagesListView({super.key});

//   @override
//   State<MessagesListView> createState() => _MessagesListViewState();
// }

// class _MessagesListViewState extends State<MessagesListView> {
//   final TextEditingController _searchController = TextEditingController();
//   // هنا المفروض يكون عندك قائمة من الـ Entities اللي جاية من الـ Cubit
//   // List<ChatPreviewEntity> allChats = [];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             _buildHeader(),
//             _buildSearchBar(),
//             Expanded(
//               child:
//                   _buildChatContent(), // هنا بنقرر هنعرض إيه (قائمة ولا Empty)
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Padding(
//       padding: EdgeInsets.all(20.w),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: Text(
//           "Messages",
//           style: TextStyle(
//             fontSize: 28.sp,
//             fontWeight: FontWeight.bold,
//             color: const Color(0xFF1B4E8C),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSearchBar() {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
//       child: TextField(
//         controller: _searchController,
//         decoration: InputDecoration(
//           hintText: "Search for a doctor...",
//           prefixIcon: const Icon(Icons.search, color: Colors.grey),
//           filled: true,
//           fillColor: Colors.grey.shade100,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15.r),
//             borderSide: BorderSide.none,
//           ),
//         ),
//         onChanged: (value) {
//           // هنا بتنادي على الـ Cubit يعمل Filter للقائمة
//           context.read<ChatCubit>().filterChats(value);
//         },
//       ),
//     );
//   }

//   Widget _buildChatContent() {
//     // محاكاة لحالة القائمة الفارغة (لو الـ Cubit رجع قائمة فاضية)
//     bool isEmpty = false;

//     if (isEmpty) {
//       return _buildEmptyState();
//     }

//     return ListView.separated(
//       padding: EdgeInsets.only(top: 10.h),
//       itemCount: 10, // تجريبي
//       separatorBuilder:
//           (context, index) =>
//               Divider(height: 1, color: Colors.grey.shade100, indent: 80.w),
//       itemBuilder: (context, index) {
//         // هنا بنباصي الـ Entity للـ Item اللي عملناه
//         // return ChatItemWidget(chat: chats[index], onTap: () {});
//         return const SizedBox(); // Placeholder
//       },
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // استخدم Lottie كما في الـ Onboarding لتوحيد الـ Style
//           Lottie.asset('assets/lottie/empty_chat.json', height: 200.h),
//           SizedBox(height: 20.h),
//           Text(
//             "No conversations yet",
//             style: TextStyle(
//               fontSize: 18.sp,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey,
//             ),
//           ),
//           SizedBox(height: 10.h),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 40.w),
//             child: Text(
//               "Start a consultation with a doctor to see your messages here.",
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.grey.shade500),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/features/chat/presentation/manager/chat_cubit/chat_cubit.dart';
import 'package:lottie/lottie.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'widgets/chat_item_widget.dart';

class MessagesListView extends StatelessWidget {
  const MessagesListView({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ توفير الـ Cubit للشاشة واستدعاء جلب البيانات فوراً
    return BlocProvider(
      create: (context) => getIt<ChatCubit>()..getChats(),
      child: Builder(
        // ✅ ضيفنا Builder هنا عشان نطلع context جديد
        builder: (newContext) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildSearchBar(
                    newContext,
                  ), // ✅ بنبعت الـ newContext اللي شايف الكيوبت
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
      padding: EdgeInsets.all(20.w),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Messages",
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1B4E8C),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: TextField(
        onChanged: (value) {
          // ✅ تشغيل منطق البحث عند كل حرف يكتبه المستخدم
          context.read<ChatCubit>().filterChats(value);
        },
        decoration: InputDecoration(
          hintText: "Search for a doctor...",
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.r),
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
          return const Center(child: CircularProgressIndicator());
        } else if (state is ChatFailure) {
          return Center(child: Text(state.errMessage));
        } else if (state is ChatSuccess) {
          if (state.chats.isEmpty) {
            return _buildEmptyState();
          }
          return ListView.separated(
            padding: EdgeInsets.only(top: 10.h),
            itemCount: state.chats.length,
            separatorBuilder:
                (context, index) => Divider(
                  height: 1,
                  color: Colors.grey.shade100,
                  indent: 80.w,
                ),
            itemBuilder: (context, index) {
              // return ChatItemWidget(
              //   chat: state.chats[index],
              //   onTap: () {
              //     // هنا هنروح لشاشة الشات التفصيلية مستقبلاً
              //   },
              // );
              return ChatItemWidget(
                chat: state.chats[index],
                onTap: () {
                  // ✅ التنقل باستخدام GoRouter
                  context.push(
                    AppRouter.kChatDetails,
                    extra: {
                      'chatId': state.chats[index].id,
                      'receiverName': state.chats[index].receiverName,
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
          Lottie.asset('assets/lottie/empty_chat.json', height: 180.h),
          SizedBox(height: 20.h),
          Text(
            "No doctors found",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
