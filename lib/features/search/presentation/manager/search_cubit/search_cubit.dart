import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:graduation_project/features/search/domain/entities/doctor_entity.dart';
import 'package:graduation_project/features/search/domain/use_cases/get_specializations_use_case.dart';
import 'package:graduation_project/features/search/domain/use_cases/get_top_rated_doctors_use_case.dart';
import 'package:graduation_project/features/search/domain/use_cases/search_doctors_use_case.dart';
import 'package:meta/meta.dart';
import 'package:permission_handler/permission_handler.dart';

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
      if (state.searchType == SearchType.nearby &&
          state.patientLatitude != null) {
        await _performNearbyWithCurrentLocation();
      } else {
        await _performSearch();
      }
    });
  }

  Future<void> searchBySpecialty(String specialty) async {
    _debounceTimer?.cancel();
    _currentSpecialty = specialty;
    if (state.searchType == SearchType.nearby &&
        state.patientLatitude != null) {
      await _performNearbyWithCurrentLocation();
    } else {
      await _performSearch();
    }
  }

  Future<void> _performNearbyWithCurrentLocation() async {
    emit(
      SearchLoading(
        searchType: SearchType.nearby,
        selectedSpecialty: _currentSpecialty,
        searchQuery: _currentQuery,
        patientLatitude: state.patientLatitude,
        patientLongitude: state.patientLongitude,
        radiusKm: state.radiusKm,
      ),
    );

    final result = await searchDoctorsUseCase(
      query: _currentQuery.isEmpty ? null : _currentQuery,
      specialization:
          _currentSpecialty == 'All Specialties' ? null : _currentSpecialty,
      patientLatitude: state.patientLatitude,
      patientLongitude: state.patientLongitude,
      radiusKm: state.radiusKm,
      page: 1,
      pageSize: 10,
    );

    _handleSearchResult(
      result,
      SearchType.nearby,
      state.patientLatitude,
      state.patientLongitude,
      state.radiusKm,
    );
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
        final searchType =
            _currentQuery.isEmpty && _currentSpecialty == 'All Specialties'
                ? SearchType.topRated
                : _currentSpecialty != 'All Specialties'
                ? SearchType.bySpecialty
                : SearchType.byQuery;
        final result = await searchDoctorsUseCase(
          query: null,
          specialization: _currentSpecialty,
          page: _currentPage,
          pageSize: 10,
        );
        _handleSearchResult(result, searchType, null, null, null);
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
    final searchType =
        _currentQuery.isEmpty && _currentSpecialty == 'All Specialties'
            ? SearchType.topRated
            : _currentSpecialty != 'All Specialties'
            ? SearchType.bySpecialty
            : SearchType.byQuery;

    final result = await searchDoctorsUseCase(
      query: queryParam,
      specialization: specializationParam,
      page: _currentPage,
      pageSize: 10,
    );
    _handleSearchResult(result, searchType, null, null, null);
  }

  void _handleSearchResult(
    dynamic result,
    SearchType searchType,
    double? lat,
    double? lng,
    double? radius,
  ) {
    result.fold(
      (failure) => emit(
        SearchFailure(
          failure.errmessage,
          searchType: searchType,
          selectedSpecialty: _currentSpecialty,
          searchQuery: _currentQuery,
          patientLatitude: lat,
          patientLongitude: lng,
          radiusKm: radius,
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
            searchType: searchType,
            selectedSpecialty: _currentSpecialty,
            searchQuery: _currentQuery,
            patientLatitude: lat,
            patientLongitude: lng,
            radiusKm: radius,
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
        searchType: state.searchType,
        selectedSpecialty: _currentSpecialty,
        searchQuery: _currentQuery,
        patientLatitude: state.patientLatitude,
        patientLongitude: state.patientLongitude,
        radiusKm: state.radiusKm,
        isFetchingMore: true,
        hasNextPage: _hasNextPage,
      ),
    );

    final queryParam = _currentQuery.isEmpty ? null : _currentQuery;
    final specializationParam =
        _currentSpecialty == 'All Specialties' ? null : _currentSpecialty;

    dynamic result;
    if (state.searchType == SearchType.nearby) {
      result = await searchDoctorsUseCase(
        query: queryParam,
        specialization: specializationParam,
        patientLatitude: state.patientLatitude,
        patientLongitude: state.patientLongitude,
        radiusKm: state.radiusKm,
        page: _currentPage,
        pageSize: 10,
      );
    } else if (state.searchType == SearchType.topRated) {
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
            searchType: state.searchType,
            selectedSpecialty: _currentSpecialty,
            searchQuery: _currentQuery,
            patientLatitude: state.patientLatitude,
            patientLongitude: state.patientLongitude,
            radiusKm: state.radiusKm,
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
            searchType: state.searchType,
            selectedSpecialty: _currentSpecialty,
            searchQuery: _currentQuery,
            patientLatitude: state.patientLatitude,
            patientLongitude: state.patientLongitude,
            radiusKm: state.radiusKm,
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

  Future<bool> _requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> searchNearby({double? radiusKm}) async {
    final hasPermission = await _requestLocationPermission();
    if (!hasPermission) {
      emit(
        SearchFailure(
          'Location permission denied',
          searchType: SearchType.nearby,
          selectedSpecialty: _currentSpecialty,
          searchQuery: _currentQuery,
        ),
      );
      return;
    }

    final position = await _getCurrentLocation();
    if (position == null) {
      emit(
        SearchFailure(
          'Could not get your location',
          searchType: SearchType.nearby,
          selectedSpecialty: _currentSpecialty,
          searchQuery: _currentQuery,
        ),
      );
      return;
    }

    emit(
      SearchLoading(
        searchType: SearchType.nearby,
        selectedSpecialty: _currentSpecialty,
        searchQuery: _currentQuery,
        patientLatitude: position.latitude,
        patientLongitude: position.longitude,
        radiusKm: radiusKm,
      ),
    );

    final result = await searchDoctorsUseCase(
      query: _currentQuery.isEmpty ? null : _currentQuery,
      specialization:
          _currentSpecialty == 'All Specialties' ? null : _currentSpecialty,
      patientLatitude: position.latitude,
      patientLongitude: position.longitude,
      radiusKm: radiusKm,
      page: 1,
      pageSize: 10,
    );

    _handleSearchResult(
      result,
      SearchType.nearby,
      position.latitude,
      position.longitude,
      radiusKm,
    );
  }

  Future<void> clearNearbySearch() async {
    if (_currentQuery.isEmpty && _currentSpecialty == 'All Specialties') {
      await _loadTopRatedDoctors();
    } else {
      await _performSearch();
    }
  }
}
