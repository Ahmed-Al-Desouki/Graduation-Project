import 'package:graduation_project/core/utils/helper/api.dart';

class ReviewWebService {
  final ApiService _apiService;

  ReviewWebService(this._apiService);

  Future<Map<String, dynamic>> postReview(Map<String, dynamic> data) async {
    return await _apiService.post('reviews', data);
  }
}
