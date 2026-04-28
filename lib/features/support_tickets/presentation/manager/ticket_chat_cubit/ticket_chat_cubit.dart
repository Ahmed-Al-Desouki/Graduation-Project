import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/core/services/signalr_service.dart';
import 'package:graduation_project/features/support_tickets/data/models/ticket_message_model.dart';
import 'package:graduation_project/features/support_tickets/domain/entities/ticket_message_entity.dart';
import 'package:graduation_project/features/support_tickets/domain/use_cases/get_ticket_messages_use_case.dart';
import 'package:graduation_project/features/support_tickets/domain/use_cases/send_ticket_message_use_case.dart';
import 'package:meta/meta.dart';

part 'ticket_chat_state.dart';

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
  String? ticketStatus;
  String? ticketTitle;

  // 🚀 جلب الرسائل مع تشغيل الـ Real-time
  // Future<void> fetchMessages(String ticketId, {bool isLoadMore = false}) async {
  //   if (!isLoadMore) {
  //     chatPage = 1;
  //     emit(TicketChatLoading());
  //   }

  //   final result = await getMessagesUseCase(ticketId: ticketId, page: chatPage);

  //   result.fold((failure) => emit(TicketChatFailure(failure.errmessage)), (
  //     paginatedEntity,
  //   ) {
  //     if (isLoadMore) {
  //       messagesList.insertAll(0, paginatedEntity.messages);
  //     } else {
  //       messagesList = paginatedEntity.messages;
  //       _connectToTicketRealtime(ticketId); // تشغيل الاتصال اللحظي
  //     }

  //     chatPage++;
  //     hasNextChatPage = paginatedEntity.hasNextPage;
  //     _emitSuccess();
  //   });
  // }

  Future<void> fetchMessages(
    String ticketId, {
    String? initialStatus,
    bool isLoadMore = false,
  }) async {
    if (!isLoadMore) {
      emit(TicketChatLoading());
      // 🎯 بنسجل الحالة اللي جاية "سلفاً" من الراوتر
      this.ticketStatus = initialStatus;
    }

    final result = await getMessagesUseCase(ticketId: ticketId, page: chatPage);

    result.fold((failure) => emit(TicketChatFailure(failure.errmessage)), (
      paginatedEntity,
    ) {
      if (!isLoadMore) {
        messagesList = paginatedEntity.messages;
        _connectToTicketRealtime(ticketId);
      } else {
        messagesList.insertAll(0, paginatedEntity.messages);
      }

      chatPage++;
      hasNextChatPage = paginatedEntity.hasNextPage;

      // 🚀 بنعمل emit للنجاح ومعاه الـ status اللي معانا من الأول
      emit(TicketChatSuccess(List.from(messagesList), newStatus: ticketStatus));
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
