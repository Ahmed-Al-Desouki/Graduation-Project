abstract class SearchRemoteDataSource {
  Future<Map<String, dynamic>> searchDoctors({
    String? query,
    String? specialization,
    double? patientLatitude,
    double? patientLongitude,
    double? radiusKm,
    int page = 1,
    int pageSize,
  });

  Future<List<String>> getSpecializations();

  Future<Map<String, dynamic>> getTopRatedDoctors({int page = 1, int pageSize});
}
