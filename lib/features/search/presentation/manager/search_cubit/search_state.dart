part of 'search_cubit.dart';

@immutable
sealed class SearchState {
  final String selectedSpecialty;
  final String searchQuery;

  SearchState({
    this.selectedSpecialty = 'All Specialties',
    this.searchQuery = '',
  });
}

final class SearchInitial extends SearchState {}

final class SearchLoading extends SearchState {
  SearchLoading({super.selectedSpecialty, super.searchQuery});
}

final class SearchSuccess extends SearchState {
  final List<DoctorEntity> doctors;
  final List<String> allSpecializations;
  final List<String> popularSpecialties;
  final bool isFetchingMore;
  final bool hasNextPage;
  final String? paginationErrorMessage;

  SearchSuccess({
    required this.doctors,
    required this.allSpecializations,
    required this.popularSpecialties,
    this.isFetchingMore = false,
    this.hasNextPage = false,
    super.selectedSpecialty,
    super.searchQuery,
    this.paginationErrorMessage,
  });
}

final class SearchFailure extends SearchState {
  final String errmessage;

  SearchFailure(this.errmessage, {super.selectedSpecialty, super.searchQuery});
}
