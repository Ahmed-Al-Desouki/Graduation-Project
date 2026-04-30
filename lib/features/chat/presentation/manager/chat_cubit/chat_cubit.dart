import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:graduation_project/features/chat/domain/entities/chat_entity.dart';
import 'package:graduation_project/features/chat/domain/use_cases/get_my_chat_use_case.dart';
import 'package:meta/meta.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final GetMyChatsUseCase getMyChatsUseCase;
  StreamSubscription? _chatsSubscription;
  List<ChatEntity> _allChats = []; // القائمة الأصلية للفلترة

  ChatCubit(this.getMyChatsUseCase) : super(ChatInitial());

  void getMyChats(String userId, bool isDoctor) {
    emit(ChatLoading());
    _chatsSubscription?.cancel();

    // بنسمع للـ Stream بتاع الفايربيز
    _chatsSubscription = getMyChatsUseCase(userId, isDoctor).listen((chats) {
      _allChats = chats;
      emit(ChatSuccess(chats));
    }, onError: (error) => emit(ChatFailure(error.toString())));
  }

  int getTotalUnreadCount(List<ChatEntity> chats) {
    return chats.fold(0, (total, chat) => total + chat.unreadCount);
  }

  void filterChats(String query) {
    if (query.isEmpty) {
      emit(ChatSuccess(_allChats));
    } else {
      final filteredList =
          _allChats
              .where(
                (chat) =>
                    chat.doctorName.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ||
                    chat.patientName.toLowerCase().contains(
                      query.toLowerCase(),
                    ),
              )
              .toList();
      emit(ChatSuccess(filteredList));
    }
  }

  @override
  Future<void> close() {
    _chatsSubscription?.cancel();
    return super.close();
  }
}
