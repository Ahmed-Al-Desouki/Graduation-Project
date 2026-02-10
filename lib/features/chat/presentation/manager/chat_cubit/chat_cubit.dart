import 'package:bloc/bloc.dart';
import 'package:graduation_project/features/chat/domain/entities/chat_preview_entity.dart';
import 'package:graduation_project/features/chat/domain/use_cases/get_chat_previews_use_case.dart';
import 'package:meta/meta.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final GetChatPreviewsUseCase getChatPreviewsUseCase;

  // نفظ قائمة أصلية للفلترة بدون نداء الـ API مرة أخرى
  List<ChatPreviewEntity> _allChats = [];
  ChatCubit(this.getChatPreviewsUseCase) : super(ChatInitial());

  Future<void> getChats() async {
    emit(ChatLoading());
    final result = await getChatPreviewsUseCase();

    result.fold((failure) => emit(ChatFailure(failure.errmessage)), (chats) {
      _allChats = chats; // حفظ القائمة الأصلية
      emit(ChatSuccess(chats));
    });
  }

  void filterChats(String query) {
    if (state is ChatSuccess || _allChats.isNotEmpty) {
      if (query.isEmpty) {
        emit(ChatSuccess(_allChats));
      } else {
        final filteredList =
            _allChats
                .where(
                  (chat) => chat.receiverName.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
                )
                .toList();
        emit(ChatSuccess(filteredList));
      }
    }
  }
}
