import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:graduation_project/features/search/domain/entities/doctor_entity.dart';
import 'package:graduation_project/features/search/domain/use_cases/get_specializations_use_case.dart';
import 'package:graduation_project/features/search/domain/use_cases/get_top_rated_doctors_use_case.dart';
import 'package:graduation_project/features/search/domain/use_cases/search_doctors_use_case.dart';
import 'package:meta/meta.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchDoctorsUseCase searchDoctorsUseCase;
  final GetSpecializationsUseCase getSpecializationsUseCase;
  final GetTopRatedDoctorsUseCase getTopRatedDoctorsUseCase;

  SearchCubit(
    this.searchDoctorsUseCase,
    this.getSpecializationsUseCase,
    this.getTopRatedDoctorsUseCase,
  ) : super(SearchInitial());

  String _currentQuery = '';
  String _currentSpecialty = 'All Specialties';
  List<String> _allSpecializations = [];
  final List<String> _popularSpecialties = [
    'Cardiology',
    'Dermatology',
    'Pediatrics',
    'Orthopedics',
    'Neurology',
    'Gynecology',
    'Dentistry',
  ];

  Timer? _debounceTimer;

  int _currentPage = 1;
  bool _hasNextPage = false;
  bool _isFetchingMore = false;
  List<DoctorEntity> _currentDoctors = [];

  Future<void> initialize() async {
    emit(
      SearchLoading(
        selectedSpecialty: _currentSpecialty,
        searchQuery: _currentQuery,
      ),
    );

    final specialtiesResult = await getSpecializationsUseCase();
    specialtiesResult.fold((failure) {
      _allSpecializations = ['General', ..._popularSpecialties];
    }, (specialties) => _allSpecializations = specialties);

    await _loadTopRatedDoctors();
  }

  Future<void> _loadTopRatedDoctors() async {
    _currentPage = 1;
    final result = await getTopRatedDoctorsUseCase(
      page: _currentPage,
      pageSize: 10,
    );

    result.fold(
      (failure) => emit(
        SearchFailure(
          failure.errmessage,
          selectedSpecialty: _currentSpecialty,
          searchQuery: _currentQuery,
        ),
      ),
      (response) {
        _currentDoctors = response.doctors;
        _hasNextPage = response.hasNextPage;
        emit(
          SearchSuccess(
            doctors: _currentDoctors,
            allSpecializations: _allSpecializations,
            popularSpecialties: _popularSpecialties,
            selectedSpecialty: _currentSpecialty,
            searchQuery: _currentQuery,
            hasNextPage: _hasNextPage,
          ),
        );
      },
    );
  }

  Future<void> searchByQuery(String query) async {
    _currentQuery = query;
    if (_currentQuery.isNotEmpty && _currentQuery.length < 2) return;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      await _performSearch();
    });
  }

  Future<void> searchBySpecialty(String specialty) async {
    _debounceTimer?.cancel();
    _currentSpecialty = specialty;
    await _performSearch();
  }

  Future<void> _performSearch() async {
    if (_currentQuery.isNotEmpty && _currentQuery.length < 2) {
      if (_currentSpecialty == 'All Specialties') {
        await _loadTopRatedDoctors();
      } else {
        emit(
          SearchLoading(
            selectedSpecialty: _currentSpecialty,
            searchQuery: _currentQuery,
          ),
        );
        _currentPage = 1;
        final result = await searchDoctorsUseCase(
          query: null,
          specialization: _currentSpecialty,
          page: _currentPage,
          pageSize: 10,
        );
        _handleSearchResult(result);
      }
      return;
    }

    if (_currentQuery.isEmpty && _currentSpecialty == 'All Specialties') {
      await _loadTopRatedDoctors();
      return;
    }

    emit(
      SearchLoading(
        selectedSpecialty: _currentSpecialty,
        searchQuery: _currentQuery,
      ),
    );
    _currentPage = 1;

    final queryParam = _currentQuery.isEmpty ? null : _currentQuery;
    final specializationParam =
        _currentSpecialty == 'All Specialties' ? null : _currentSpecialty;

    final result = await searchDoctorsUseCase(
      query: queryParam,
      specialization: specializationParam,
      page: _currentPage,
      pageSize: 10,
    );
    _handleSearchResult(result);
  }

  void _handleSearchResult(dynamic result) {
    result.fold(
      (failure) => emit(
        SearchFailure(
          failure.errmessage,
          selectedSpecialty: _currentSpecialty,
          searchQuery: _currentQuery,
        ),
      ),
      (response) {
        _currentDoctors = response.doctors;
        _hasNextPage = response.hasNextPage;
        emit(
          SearchSuccess(
            doctors: _currentDoctors,
            allSpecializations: _allSpecializations,
            popularSpecialties: _popularSpecialties,
            selectedSpecialty: _currentSpecialty,
            searchQuery: _currentQuery,
            hasNextPage: _hasNextPage,
          ),
        );
      },
    );
  }

  Future<void> fetchNextPage() async {
    if (!_hasNextPage || _isFetchingMore) return;

    _isFetchingMore = true;
    _currentPage++;

    emit(
      SearchSuccess(
        doctors: _currentDoctors,
        allSpecializations: _allSpecializations,
        popularSpecialties: _popularSpecialties,
        selectedSpecialty: _currentSpecialty,
        searchQuery: _currentQuery,
        isFetchingMore: true,
        hasNextPage: _hasNextPage,
      ),
    );

    final queryParam = _currentQuery.isEmpty ? null : _currentQuery;
    final specializationParam =
        _currentSpecialty == 'All Specialties' ? null : _currentSpecialty;

    dynamic result;
    if (_currentQuery.isEmpty && _currentSpecialty == 'All Specialties') {
      result = await getTopRatedDoctorsUseCase(
        page: _currentPage,
        pageSize: 10,
      );
    } else {
      result = await searchDoctorsUseCase(
        query: queryParam,
        specialization: specializationParam,
        page: _currentPage,
        pageSize: 10,
      );
    }

    result.fold(
      (failure) {
        _isFetchingMore = false;
        _currentPage--;
        emit(
          SearchSuccess(
            doctors: _currentDoctors,
            allSpecializations: _allSpecializations,
            popularSpecialties: _popularSpecialties,
            selectedSpecialty: _currentSpecialty,
            searchQuery: _currentQuery,
            isFetchingMore: false,
            hasNextPage: _hasNextPage,
            paginationErrorMessage: failure.errmessage,
          ),
        );
      },
      (response) {
        _isFetchingMore = false;
        _hasNextPage = response.hasNextPage;
        _currentDoctors.addAll(response.doctors);
        emit(
          SearchSuccess(
            doctors: _currentDoctors,
            allSpecializations: _allSpecializations,
            popularSpecialties: _popularSpecialties,
            selectedSpecialty: _currentSpecialty,
            searchQuery: _currentQuery,
            isFetchingMore: false,
            hasNextPage: _hasNextPage,
          ),
        );
      },
    );
  }

  void updateSelectedSpecialty(String specialty) =>
      searchBySpecialty(specialty);
  void updateSearchQuery(String query) => searchByQuery(query);

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
