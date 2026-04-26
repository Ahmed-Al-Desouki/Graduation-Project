import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/core/services/signalr_service.dart';
import 'package:graduation_project/features/support_tickets/data/models/ticket_message_model.dart';
import 'package:graduation_project/features/support_tickets/domain/entities/ticket_message_entity.dart';
import 'package:graduation_project/features/support_tickets/domain/use_cases/get_ticket_messages_use_case.dart';
import 'package:graduation_project/features/support_tickets/domain/use_cases/send_ticket_message_use_case.dart';
import 'package:meta/meta.dart';

part 'ticket_chat_state.dart';

// class TicketChatCubit extends Cubit<TicketChatState> {
//   final GetTicketMessagesUseCase getMessagesUseCase;
//   final SendTicketMessageUseCase sendMessageUseCase;
//   final SignalRService signalRService;
//   TicketChatCubit({
//     required this.getMessagesUseCase,
//     required this.sendMessageUseCase,
//     required this.signalRService,
//   }) : super(TicketChatInitial());

//   List<TicketMessageEntity> messages = [];
//   int chatPage = 1;
//   bool hasNextChatPage = true;

//   // جلب الرسائل القديمة من الـ API
//   // Future<void> fetchMessages(String ticketId) async {
//   //   emit(TicketChatLoading());
//   //   final result = await getMessagesUseCase(ticketId: ticketId);

//   //   result.fold((failure) => emit(TicketChatFailure(failure.errmessage)), (
//   //     paginatedEntity,
//   //   ) {
//   //     messages = paginatedEntity.messages;
//   //     emit(TicketChatSuccess(List.from(messages)));
//   //     // أول ما الرسايل تحمل، نبدأ نسمع للـ Real-time
//   //     _connectToTicketRealtime(ticketId);
//   //   });
//   // }

//   // Future<void> fetchMessages(String ticketId, {bool isLoadMore = false}) async {
//   //   if (!isLoadMore) {
//   //     chatPage = 1;
//   //     emit(TicketChatLoading());
//   //   }

//   //   final result = await getMessagesUseCase(
//   //     ticketId: ticketId,
//   //     page: chatPage, // تأكد إن الـ UseCase بيقبل الـ page
//   //   );

//   //   result.fold((failure) => emit(TicketChatFailure(failure.errmessage)), (
//   //     paginatedEntity,
//   //   ) {
//   //     if (isLoadMore) {
//   //       // بنضيف الرسائل القديمة في أول اللستة (لأن الشات بيعرض من الأحدث للأقدم)
//   //       messages.insertAll(0, paginatedEntity.messages);
//   //     } else {
//   //       messages = paginatedEntity.messages;
//   //     }

//   //     chatPage++;
//   //     hasNextChatPage = paginatedEntity.hasNextPage;
//   //     emit(
//   //       TicketChatSuccess(
//   //         List.from(messages),
//   //         newStatus:
//   //             state is TicketChatSuccess
//   //                 ? (state as TicketChatSuccess).newStatus
//   //                 : null,
//   //       ),
//   //     );
//   //   });
//   // }

//   Future<void> fetchMessages(String ticketId, {bool isLoadMore = false}) async {
//     if (!isLoadMore) {
//       chatPage = 1;
//       emit(TicketChatLoading());
//     }

//     final result = await getMessagesUseCase(ticketId: ticketId, page: chatPage);

//     result.fold((failure) => emit(TicketChatFailure(failure.errmessage)), (
//       paginatedEntity,
//     ) {
//       if (isLoadMore) {
//         messages.insertAll(0, paginatedEntity.messages);
//       } else {
//         messages = paginatedEntity.messages;
//         // 🚀 السطر السحري اللي كان ناقص: ابدأ اسمع لحظياً بعد أول تحميل
//         _connectToTicketRealtime(ticketId);
//       }

//       chatPage++;
//       hasNextChatPage = paginatedEntity.hasNextPage;
//       emit(TicketChatSuccess(List.from(messages)));
//     });
//   }

//   // إرسال رسالة جديدة
//   Future<void> sendMessage(String ticketId, String content) async {
//     final result = await sendMessageUseCase(
//       ticketId: ticketId,
//       message: content,
//     );

//     result.fold((failure) => emit(TicketChatSendFailure(failure.errmessage)), (
//       messageEntity,
//     ) {
//       // 🚀 ضيف الرسالة يدوي هنا عشان تظهر لليوزر اللي بعتها فوراً
//       if (!messages.any((m) => m.id == messageEntity.id)) {
//         messages.add(messageEntity);
//         emit(TicketChatSuccess(List.from(messages)));
//       }
//     });
//   }

//   void _connectToTicketRealtime(String ticketId) async {
//     // 1. استنى لغاية ما يتصل (نفس فكرة الداشبورد)
//     int retryCount = 0;
//     while (!signalRService.isConnected && retryCount < 5) {
//       debugPrint("⏳ Waiting for SignalR... Attempt ${retryCount + 1}");
//       await Future.delayed(const Duration(milliseconds: 1000));
//       retryCount++;
//     }

//     if (signalRService.isConnected) {
//       debugPrint("✅ Connected! Joining Group: $ticketId");

//       // 2. بلّغ السيرفر إنك عاوز رسايل التذكرة دي
//       await signalRService.invoke("JoinTicket", args: [ticketId]);

//       // 3. اسمع للـ Event الصح (ReceiveMessage)
//       // signalRService.on("ReceiveMessage", (args) {
//       //   if (args != null && args.isNotEmpty) {
//       //     final data = args[0] as Map<String, dynamic>;

//       //     // تحويل الـ JSON لـ Entity (تأكد من مطابقة الـ keys)
//       //     final newMessage = TicketMessageEntity(
//       //       id: data['id'].toString(),
//       //       content: data['content'] ?? data['message'] ?? "",
//       //       senderName: data['senderName'] ?? "",
//       //       isFromAdmin: data['isFromAdmin'] ?? false,
//       //       createdAt: DateTime.parse(
//       //         data['createdAt'] ?? DateTime.now().toString(),
//       //       ),
//       //     );

//       //     // التأكد إن الرسالة مش موجودة فعلاً (عشان ما تتكررش لو إنت اللي باعتها)
//       //     if (!messages.any((m) => m.id == newMessage.id)) {
//       //       messages.add(newMessage);
//       //       emit(TicketChatSuccess(List.from(messages)));
//       //     }
//       //   }
//       // });
//       signalRService.on("ReceiveMessage", (args) {
//         _processIncomingMessage(args);
//       });

//       signalRService.on("receiveMessage", (args) {
//         _processIncomingMessage(args);
//       });

//       // signalRService.on("UpdateTicketStatus", (args) {
//       //   if (args != null && args.isNotEmpty) {
//       //     final String newStatus =
//       //         args[0]
//       //             .toString(); // السيرفر بيبعت الحالة الجديدة (Closed / Resolved)
//       //     debugPrint("🔔 Ticket Status Updated to: $newStatus");

//       //     // بنحدث الـ Entity اللي معانا في الـ Cubit
//       //     // بنعمل Emit لحالة نجاح جديدة بس بالحالة المحدثة
//       //     if (state is TicketChatSuccess) {
//       //       // بنفترض إنك شايل الـ ticket object في الـ Success state أو بتحدث الحالة العامة
//       //       emit(
//       //         TicketChatSuccess(
//       //           List.from(messages),
//       //           newStatus:
//       //               newStatus, // لازم تضيف الحقل ده في الـ State لو مش موجود
//       //         ),
//       //       );
//       //     }
//       //   }
//       // });
//       // signalRService.on("TicketUpdated", (args) {
//       //   if (args != null && args.isNotEmpty) {
//       //     // 💡 ملاحظة: الـ args[0] غالباً هيكون Map فيها الـ status الجديد
//       //     final data = args[0] as Map<String, dynamic>;
//       //     final String newStatus = data['status'].toString();

//       //     debugPrint("🔔 Ticket Status Updated via SignalR: $newStatus");

//       //     if (state is TicketChatSuccess) {
//       //       emit(TicketChatSuccess(List.from(messages), newStatus: newStatus));
//       //     }
//       //   }
//       // });

//       // signalRService.on("TicketUpdated", (args) {
//       //   if (args != null && args.isNotEmpty) {
//       //     // ركز هنا: الباك إند ممكن يبعت الأوبجكت كامل أو الحالة بس
//       //     final data = args[0] as Map<String, dynamic>;
//       //     final String newStatus = data['status']?.toString() ?? "Open";

//       //     debugPrint("🔔 Realtime Status Change: $newStatus");
//       //     emit(TicketChatSuccess(List.from(messages), newStatus: newStatus));
//       //   }
//       // });

//       signalRService.on("TicketUpdated", (args) {
//         if (args != null && args.isNotEmpty) {
//           final data = args[0] as Map<String, dynamic>;
//           // استلام الحالة سواء كانت رقم أو نص
//           final dynamic rawStatus = data['status'];
//           String statusString;

//           if (rawStatus is int) {
//             // تحويل الرقم لنص مفهوم للـ UI بتاعك
//             switch (rawStatus) {
//               case 0:
//                 statusString = "Open";
//                 break;
//               case 1:
//                 statusString = "InProgress";
//                 break;
//               case 2:
//                 statusString = "Resolved";
//                 break;
//               case 3:
//                 statusString = "Closed";
//                 break;
//               default:
//                 statusString = "Open";
//             }
//           } else {
//             statusString = rawStatus.toString();
//           }

//           debugPrint("🔔 Ticket Status Handled: $statusString");
//           emit(TicketChatSuccess(List.from(messages), newStatus: statusString));
//         }
//       });
//     }
//   }

//   // void _processIncomingMessage(List<Object?>? args) {
//   //   // 🔥 السطر ده أهم سطر دلوقتي عشان نعرف العيب فين
//   //   debugPrint("🚨 SIGNALR DATA RECEIVED: $args");

//   //   if (args != null && args.isNotEmpty) {
//   //     try {
//   //       final data = args[0] as Map<String, dynamic>;

//   //       final newMessage = TicketMessageEntity(
//   //         id:
//   //             data['id']?.toString() ??
//   //             DateTime.now().millisecondsSinceEpoch.toString(),
//   //         content: data['content'] ?? data['message'] ?? "",
//   //         senderName: data['senderName'] ?? "System",
//   //         isFromAdmin: data['isFromAdmin'] ?? false,
//   //         createdAt: DateTime.now(), // مؤقتاً لغاية ما نظبط الـ Parsing
//   //       );

//   //       if (!messages.any((m) => m.id == newMessage.id)) {
//   //         messages.add(newMessage);
//   //         emit(TicketChatSuccess(List.from(messages)));
//   //       }
//   //     } catch (e) {
//   //       debugPrint("❌ Error parsing SignalR message: $e");
//   //     }
//   //   }
//   // }
//   // void _processIncomingMessage(List<Object?>? args) {
//   //   debugPrint("🚨 SIGNALR DATA RECEIVED: $args");

//   //   if (args != null && args.isNotEmpty) {
//   //     try {
//   //       // 1. استلم الداتا كـ Map
//   //       final data = args[0] as Map<String, dynamic>;

//   //       // 2. استخدم الموديل بتاعك عشان يعمل Parsing صح (ده الأضمن)
//   //       // لو عندك TicketMessageModel.fromJson استخدمه
//   //       final newMessageModel = TicketMessageModel.fromJson(data);

//   //       // 3. ضيف الموديل للستة (لأن الـ Cubit عندك شايل List<TicketMessageModel>)
//   //       if (!messages.any((m) => m.id == newMessageModel.id)) {
//   //         messages.add(newMessageModel);

//   //         // 4. ابعت الحالة الجديدة للـ UI
//   //         emit(
//   //           TicketChatSuccess(
//   //             List.from(messages),

//   //             newStatus: (state as TicketChatSuccess).newStatus,
//   //           ),
//   //         );
//   //         debugPrint("✅ Message Added Successfully to UI");
//   //       }
//   //     } catch (e) {
//   //       debugPrint("❌ Error parsing SignalR message: $e");

//   //       // حل احتياطي لو الـ Model فيه مشكلة في الـ Parsing يدوي:
//   //       /*
//   //     final newMessage = TicketMessageModel(
//   //       id: data['id'].toString(),
//   //       content: data['content'] ?? "",
//   //       senderName: data['senderName'] ?? "",
//   //       isFromAdmin: data['isFromAdmin'] ?? false,
//   //       createdAt: DateTime.parse(data['createdAt']),
//   //     );
//   //     messages.add(newMessage);
//   //     emit(TicketChatSuccess(List.from(messages)));
//   //     */
//   //     }
//   //   }
//   // }
//   void _processIncomingMessage(List<Object?>? args) {
//     if (args != null && args.isNotEmpty) {
//       try {
//         final data = args[0] as Map<String, dynamic>;
//         final newMessageModel = TicketMessageModel.fromJson(data);

//         if (!messages.any((m) => m.id == newMessageModel.id)) {
//           messages.add(newMessageModel);

//           // 🚀 الحل هنا: لازم نحافظ على الحالة الحالية وموقعهاش
//           String? currentStatus;
//           if (state is TicketChatSuccess) {
//             currentStatus = (state as TicketChatSuccess).newStatus;
//           }

//           emit(
//             TicketChatSuccess(List.from(messages), newStatus: currentStatus),
//           );
//         }
//       } catch (e) {
//         debugPrint("❌ Error parsing SignalR message: $e");
//       }
//     }
//   }
// }

// class TicketChatCubit extends Cubit<TicketChatState> {
//   final GetTicketMessagesUseCase getMessagesUseCase;
//   final SendTicketMessageUseCase sendMessageUseCase;
//   final SignalRService signalRService;

//   TicketChatCubit({
//     required this.getMessagesUseCase,
//     required this.sendMessageUseCase,
//     required this.signalRService,
//   }) : super(TicketChatInitial());

//   List<TicketMessageEntity> messagesList = [];
//   int chatPage = 1;
//   bool hasNextChatPage = true;

//   Future<void> fetchMessages(String ticketId, {bool isLoadMore = false}) async {
//     if (!isLoadMore) {
//       chatPage = 1;
//       emit(TicketChatLoading());
//     }

//     final result = await getMessagesUseCase(ticketId: ticketId, page: chatPage);

//     result.fold((failure) => emit(TicketChatFailure(failure.errmessage)), (
//       paginatedEntity,
//     ) {
//       if (isLoadMore) {
//         messagesList.insertAll(0, paginatedEntity.messages);
//       } else {
//         messagesList = paginatedEntity.messages;
//         _connectToTicketRealtime(ticketId);
//       }

//       chatPage++;
//       hasNextChatPage = paginatedEntity.hasNextPage;
//       _emitSuccess();
//     });
//   }

//   Future<void> sendMessage(String ticketId, String content) async {
//     final result = await sendMessageUseCase(
//       ticketId: ticketId,
//       message: content,
//     );

//     result.fold((failure) => emit(TicketChatSendFailure(failure.errmessage)), (
//       messageEntity,
//     ) {
//       // 🚀 Local Echo: تحديث فوري للمريض اللي بعت الرسالة
//       if (!messagesList.any((m) => m.id == messageEntity.id)) {
//         messagesList.add(messageEntity);
//         _emitSuccess();
//       }
//     });
//   }

//   void _connectToTicketRealtime(String ticketId) async {
//     signalRService.off("ReceiveMessage");
//     signalRService.off("TicketUpdated");

//     if (signalRService.isConnected) {
//       await signalRService.invoke("JoinTicket", args: [ticketId]);

//       // استلام رسائل جديدة
//       signalRService.on("ReceiveMessage", (args) {
//         if (isClosed) return;
//         _processIncomingMessage(args);
//       });

//       // استلام تحديثات الحالة (Closed/Resolved)
//       signalRService.on("TicketUpdated", (args) {
//         if (isClosed) return;
//         _handleStatusUpdate(args);
//       });
//     }
//   }

//   void _processIncomingMessage(List<Object?>? args) {
//     if (args != null && args.isNotEmpty) {
//       try {
//         final data = args[0] as Map<String, dynamic>;
//         final newMessage = TicketMessageModel.fromJson(data);

//         if (!messagesList.any((m) => m.id == newMessage.id)) {
//           messagesList.add(newMessage);
//           _emitSuccess();
//         }
//       } catch (e) {
//         debugPrint("❌ App SignalR Error: $e");
//       }
//     }
//   }

//   void _handleStatusUpdate(List<Object?>? args) {
//     if (args != null && args.isNotEmpty) {
//       final data = args[0] as Map<String, dynamic>;
//       final String newStatus = data['status']?.toString() ?? "Open";
//       emit(TicketChatSuccess(List.from(messagesList), newStatus: newStatus));
//     }
//   }

//   void _emitSuccess() {
//     if (!isClosed) {
//       String? currentStatus;
//       if (state is TicketChatSuccess) {
//         currentStatus = (state as TicketChatSuccess).newStatus;
//       }
//       emit(
//         TicketChatSuccess(List.from(messagesList), newStatus: currentStatus),
//       );
//     }
//   }

//   @override
//   Future<void> close() {
//     signalRService.off("ReceiveMessage");
//     signalRService.off("TicketUpdated");
//     return super.close();
//   }
// }

class TicketChatCubit extends Cubit<TicketChatState> {
  final GetTicketMessagesUseCase getMessagesUseCase;
  final SendTicketMessageUseCase sendMessageUseCase;
  final SignalRService signalRService;

  TicketChatCubit({
    required this.getMessagesUseCase,
    required this.sendMessageUseCase,
    required this.signalRService,
  }) : super(TicketChatInitial());

  List<TicketMessageEntity> messagesList = [];
  int chatPage = 1;
  bool hasNextChatPage = true;

  // 🚀 جلب الرسائل مع تشغيل الـ Real-time
  Future<void> fetchMessages(String ticketId, {bool isLoadMore = false}) async {
    if (!isLoadMore) {
      chatPage = 1;
      emit(TicketChatLoading());
    }

    final result = await getMessagesUseCase(ticketId: ticketId, page: chatPage);

    result.fold((failure) => emit(TicketChatFailure(failure.errmessage)), (
      paginatedEntity,
    ) {
      if (isLoadMore) {
        messagesList.insertAll(0, paginatedEntity.messages);
      } else {
        messagesList = paginatedEntity.messages;
        _connectToTicketRealtime(ticketId); // تشغيل الاتصال اللحظي
      }

      chatPage++;
      hasNextChatPage = paginatedEntity.hasNextPage;
      _emitSuccess();
    });
  }

  // 🚀 إرسال رسالة مع Local Echo
  Future<void> sendMessage(String ticketId, String content) async {
    final result = await sendMessageUseCase(
      ticketId: ticketId,
      message: content,
    );

    result.fold((failure) => emit(TicketChatSendFailure(failure.errmessage)), (
      messageEntity,
    ) {
      if (!messagesList.any((m) => m.id == messageEntity.id)) {
        messagesList.add(messageEntity);
        _emitSuccess();
      }
    });
  }

  void _connectToTicketRealtime(String ticketId) async {
    // تنظيف المستمعين القدامى لمنع التكرار
    signalRService.off("ReceiveMessage");
    signalRService.off("TicketUpdated");

    if (signalRService.isConnected) {
      await signalRService.invoke("JoinTicket", args: [ticketId]);

      // 1. استقبال الرسائل الجديدة
      signalRService.on("ReceiveMessage", (args) {
        if (isClosed) return;
        _processIncomingMessage(args);
      });

      // 2. استقبال تحديثات الحالة (مع الـ Mapping اللي طلبته)
      signalRService.on("TicketUpdated", (args) {
        if (isClosed) return;
        if (args != null && args.isNotEmpty) {
          final data = args[0] as Map<String, dynamic>;
          final String statusString = _mapStatusToString(data['status']);

          debugPrint("🔔 Ticket Status Updated to: $statusString");
          emit(
            TicketChatSuccess(List.from(messagesList), newStatus: statusString),
          );
        }
      });
    }
  }

  // 🚀 ميثود مساعدة لتحويل الـ int لـ String مفهوم
  String _mapStatusToString(dynamic rawStatus) {
    if (rawStatus is int) {
      switch (rawStatus) {
        case 0:
          return "Open";
        case 1:
          return "InProgress";
        case 2:
          return "Resolved";
        case 3:
          return "Closed";
        default:
          return "Open";
      }
    }
    return rawStatus?.toString() ?? "Open";
  }

  void _processIncomingMessage(List<Object?>? args) {
    if (args != null && args.isNotEmpty) {
      try {
        final data = args[0] as Map<String, dynamic>;
        final newMessage = TicketMessageModel.fromJson(data);

        if (!messagesList.any((m) => m.id == newMessage.id)) {
          messagesList.add(newMessage);
          _emitSuccess();
        }
      } catch (e) {
        debugPrint("❌ Error parsing message: $e");
      }
    }
  }

  void _emitSuccess() {
    if (!isClosed) {
      String? currentStatus;
      if (state is TicketChatSuccess) {
        currentStatus = (state as TicketChatSuccess).newStatus;
      }
      emit(
        TicketChatSuccess(List.from(messagesList), newStatus: currentStatus),
      );
    }
  }

  @override
  Future<void> close() {
    signalRService.off("ReceiveMessage");
    signalRService.off("TicketUpdated");
    return super.close();
  }
}
