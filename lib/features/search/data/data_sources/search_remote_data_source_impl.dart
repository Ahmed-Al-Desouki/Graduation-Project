import '../../../../core/utils/helper/api.dart';
import 'search_remote_data_source.dart';

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final ApiService _apiService;

  SearchRemoteDataSourceImpl(this._apiService);

  @override
  Future<Map<String, dynamic>> searchDoctors({
    String? query,
    String? specialization,
    double? patientLatitude,
    double? patientLongitude,
    double? radiusKm,
    int page = 1,
    int pageSize = 10,
  }) async {
    if (patientLatitude != null && patientLongitude != null) {
      return await _apiService.get(
        'doctors/search/nearby',
        queryParameters: {
          if (query != null && query.isNotEmpty) 'query': query,
          if (specialization != null && specialization.isNotEmpty)
            'specialization': specialization,
          'patientLatitude': patientLatitude,
          'patientLongitude': patientLongitude,
          if (radiusKm != null) 'radiusKm': radiusKm,
          'page': page,
          'pageSize': pageSize,
        },
      );
    }

    return await _apiService.get(
      'doctors/search',
      queryParameters: {
        if (query != null && query.isNotEmpty) 'query': query,
        if (specialization != null && specialization.isNotEmpty)
          'specialization': specialization,
        'page': page,
        'pageSize': pageSize,
      },
    );
  }

  @override
  Future<List<String>> getSpecializations() async {
    final response = await _apiService.get('doctors/search/specializations');

    if (response is Map && response.containsKey('specializations')) {
      final List<dynamic> specs = response['specializations'];
      return specs.map((e) => e.toString()).toList();
    } else if (response is List) {
      return response.map((e) => e.toString()).toList();
    }
    return [];
  }

  @override
  Future<Map<String, dynamic>> getTopRatedDoctors({
    int page = 1,
    int pageSize = 10,
  }) async {
    return await _apiService.get(
      'doctors/search/top-rated',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
  }
}
