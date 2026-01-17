import 'package:bloc/bloc.dart';
import 'package:graduation_project/features/home/data/models/home_user_model.dart';
import 'package:graduation_project/features/home/domain/repos/home_repo.dart';
import 'package:meta/meta.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _homeRepository;
  HomeCubit(this._homeRepository) : super(HomeInitial());

  Future<void> getHomeUserInfo() async {
    emit(HomeLoading());
    final result = await _homeRepository.fetchHomeUserInfo();
    result.fold(
      (failure) => emit(HomeFailure(failure.errmessage)),
      (user) => emit(HomeSuccess(user)),
    );
  }
}
