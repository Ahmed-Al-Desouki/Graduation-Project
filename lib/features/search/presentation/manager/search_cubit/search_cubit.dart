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

  // === Variables الداخلية ===
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

  // === Pagination Variables ===
  int _currentPage = 1;
  bool _hasNextPage = false;
  bool _isFetchingMore = false;
  List<DoctorEntity> _currentDoctors = []; // نحتفظ باللستة هنا عشان نضيف عليها

  // === 1. Initialize ===
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

  // === 2. Load Top Rated Doctors ===
  Future<void> _loadTopRatedDoctors() async {
    _currentPage = 1; // تصفير الصفحة عند أي بحث جديد
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

  // === 3. Search by Name (مع Debounce) ===
  Future<void> searchByQuery(String query) async {
    _currentQuery = query;
    if (_currentQuery.isNotEmpty && _currentQuery.length < 2) return;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      await _performSearch();
    });
  }

  // === 4. Search by Specialty ===
  Future<void> searchBySpecialty(String specialty) async {
    _debounceTimer?.cancel();
    _currentSpecialty = specialty;
    await _performSearch();
  }

  // === الدالة الفعلية اللي بتبعت للـ API ===
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
        _currentPage = 1; // تصفير الصفحة
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
    _currentPage = 1; // تصفير الصفحة

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

  // === 5. Pagination (Fetch Next Page) ===
  Future<void> fetchNextPage() async {
    // لو مفيش صفحات تانية أو بنحمل حالياً، لا تفعل شيء
    if (!_hasNextPage || _isFetchingMore) return;

    _isFetchingMore = true;
    _currentPage++;

    // إرسال State جديدة عشان الـ UI يعرض الـ Loader السفلي
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
        _currentPage--; // نرجع خطوة للوراء عشان المحاولة الجاية
        emit(
          SearchSuccess(
            // نحدث الـ UI لإخفاء الـ Loader
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
        _currentDoctors.addAll(
          response.doctors,
        ); // نضيف الدكاترة الجداد للستة القديمة
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

// import 'package:bloc/bloc.dart';
// import 'package:graduation_project/features/search/domain/entities/doctor_entity.dart';
// import 'package:graduation_project/features/search/domain/use_cases/get_specializations_use_case.dart';
// import 'package:graduation_project/features/search/domain/use_cases/get_top_rated_doctors_use_case.dart';
// import 'package:graduation_project/features/search/domain/use_cases/search_doctors_use_case.dart';
// import 'package:meta/meta.dart';

// part 'search_state.dart';

// class SearchCubit extends Cubit<SearchState> {
//   final SearchDoctorsUseCase searchDoctorsUseCase;
//   final GetSpecializationsUseCase getSpecializationsUseCase;
//   final GetTopRatedDoctorsUseCase getTopRatedDoctorsUseCase;

//   SearchCubit(
//     this.searchDoctorsUseCase,
//     this.getSpecializationsUseCase,
//     this.getTopRatedDoctorsUseCase,
//   ) : super(SearchInitial());

//   String _currentQuery = '';
//   String _currentSpecialty = 'All Specialties';
//   int _currentPage = 1;
//   final int _pageSize = 10;
//   List<String> _allSpecializations = [];
//   List<String> _popularSpecialties = [];

//   /// تهيئة الـ Cubit
//   Future<void> initialize() async {
//     emit(SearchLoading());

//     // جلب التخصصات
//     final specialtiesResult = await getSpecializationsUseCase();
//     specialtiesResult.fold(
//       (failure) {
//         // لو فشل، نستخدم قائمة افتراضية
//         _allSpecializations = [
//           'All Specialties',
//           'General',
//           'Cardiology',
//           'Dermatology',
//           'Pediatrics',
//           'Orthopedics',
//           'Neurology',
//           'Gynecology',
//           'Dentistry',
//         ];
//         _popularSpecialties = _allSpecializations.skip(1).take(7).toList();
//       },
//       (specialties) {
//         _allSpecializations = ['All Specialties', ...specialties];
//         _popularSpecialties = specialties.take(7).toList();
//       },
//     );

//     // جلب أفضل الدكاترة كـ default
//     await _loadTopRatedDoctors();
//   }

//   /// تحميل أفضل الدكاترة تقييماً
//   Future<void> _loadTopRatedDoctors() async {
//     final result = await getTopRatedDoctorsUseCase(
//       page: _currentPage,
//       pageSize: _pageSize,
//     );

//     result.fold(
//       (failure) => emit(SearchFailure(failure.errmessage)),
//       (response) => emit(SearchSuccess(
//         doctors: response.doctors,
//         specializations: _allSpecializations,
//         popularSpecialties: _popularSpecialties,
//         selectedSpecialty: _currentSpecialty,
//         searchQuery: _currentQuery,
//         hasNextPage: response.hasNextPage,
//         totalCount: response.totalCount,
//       )),
//     );
//   }

//   /// البحث عن الدكاترة
//   Future<void> searchDoctors({
//     String? query,
//     String? specialty,
//   }) async {
//     if (query != null) _currentQuery = query;
//     if (specialty != null) _currentSpecialty = specialty;
//     _currentPage = 1; // Reset page on new search

//     emit(SearchLoading());

//     final specializationParam =
//         _currentSpecialty == 'All Specialties' ? null : _currentSpecialty;

//     final result = await searchDoctorsUseCase(
//       query: _currentQuery.isEmpty ? null : _currentQuery,
//       specialization: specializationParam,
//       page: _currentPage,
//       pageSize: _pageSize,
//     );

//     result.fold(
//       (failure) => emit(SearchFailure(failure.errmessage)),
//       (response) => emit(SearchSuccess(
//         doctors: response.doctors,
//         specializations: _allSpecializations,
//         popularSpecialties: _popularSpecialties,
//         selectedSpecialty: _currentSpecialty,
//         searchQuery: _currentQuery,
//         hasNextPage: response.hasNextPage,
//         totalCount: response.totalCount,
//       )),
//     );
//   }

//   /// تحميل المزيد من النتائج (Pagination)
//   Future<void> loadMore() async {
//     if (state is SearchSuccess) {
//       final currentState = state as SearchSuccess;
//       if (!currentState.hasNextPage) return;

//       _currentPage++;

//       final specializationParam =
//           _currentSpecialty == 'All Specialties' ? null : _currentSpecialty;

//       final result = await searchDoctorsUseCase(
//         query: _currentQuery.isEmpty ? null : _currentQuery,
//         specialization: specializationParam,
//         page: _currentPage,
//         pageSize: _pageSize,
//       );

//       result.fold(
//         (failure) => emit(SearchFailure(failure.errmessage)),
//         (response) {
//           final allDoctors = [...currentState.doctors, ...response.doctors];
//           emit(SearchSuccess(
//             doctors: allDoctors,
//             specializations: currentState.specializations,
//             popularSpecialties: currentState.popularSpecialties,
//             selectedSpecialty: _currentSpecialty,
//             searchQuery: _currentQuery,
//             hasNextPage: response.hasNextPage,
//             totalCount: response.totalCount,
//           ));
//         },
//       );
//     }
//   }

//   /// تحديث التخصص المختار
//   void updateSelectedSpecialty(String specialty) {
//     _currentSpecialty = specialty;
//     searchDoctors(specialty: specialty);
//   }

//   /// تحديث نص البحث
//   void updateSearchQuery(String query) {
//     _currentQuery = query;
//     searchDoctors(query: query);
//   }

//   /// البحث عن تخصص داخل الـ Bottom Sheet
//   List<String> filterSpecializations(String query) {
//     return _allSpecializations
//         .where((s) => s.toLowerCase().contains(query.toLowerCase()))
//         .toList();
//   }

//   /// الحصول على كل التخصصات للـ Dropdown
//   List<String> getAllSpecializations() {
//     return _allSpecializations;
//   }
// }

// import 'dart:async';

// import 'package:graduation_project/features/search/data/models/search_item.dart';

// class SearchCubit {
//   Timer? _debounce;

//   void onQueryChanged({
//     required String query,
//     required String specialty,
//     required Function(List<SearchItem>) onResult,
//   }) {
//     if (_debounce?.isActive ?? false) _debounce!.cancel();

//     _debounce = Timer(const Duration(milliseconds: 400), () {
//       final results =
//           searchData.where((item) {
//             final matchesQuery = item.title.toLowerCase().contains(
//               query.toLowerCase(),
//             );

//             final matchesSpecialty =
//                 specialty == "All Specialties" || item.specialty == specialty;

//             return matchesQuery && matchesSpecialty;
//           }).toList();

//       onResult(results);
//     });
//   }

//   void dispose() {
//     _debounce?.cancel();
//   }
// }

// import 'dart:async';

// import 'package:graduation_project/features/search/data/models/search_item.dart';

// class SearchCubit {
//   Timer? _debounce;

//   void onQueryChanged({
//     required String query,
//     required Function(List<SearchItem>) onResult,
//   }) {
//     if (_debounce?.isActive ?? false) _debounce!.cancel();

//     _debounce = Timer(const Duration(milliseconds: 400), () {
//       if (query.trim().length < 3) {
//         onResult([]);
//         return;
//       }

//       final results =
//           searchData.where((item) {
//             return item.title.toLowerCase().contains(query.toLowerCase());
//           }).toList();

//       onResult(results);
//     });
//   }

//   void dispose() {
//     _debounce?.cancel();
//   }
// }
