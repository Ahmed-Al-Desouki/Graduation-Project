import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:graduation_project/features/review/data/models/review_model.dart';
import 'package:graduation_project/features/review/domain/repos/review_repo.dart';

part 'review_state.dart';

class ReviewCubit extends Cubit<ReviewState> {
  final ReviewRepository _repository;
  ReviewCubit(this._repository) : super(ReviewInitial());
  Future<void> submitReview({
    required int doctorId,
    required int rating,
    required String comment,
  }) async {
    emit(ReviewLoading());
    final result = await _repository.postReview(
      ReviewModel(doctorId: doctorId, rating: rating, comment: comment),
    );
    result.fold(
      (failure) => emit(ReviewFailure(failure.errmessage)),
      (success) => emit(ReviewSuccess()),
    );
  }
}
