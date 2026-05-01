import 'package:graduation_project/core/utils/helper/api.dart';

class HomeWebService {
  final ApiService _apiService;

  HomeWebService(this._apiService);

  Future<Map<String, dynamic>> fetchHomeUserInfo() async {
    // 💡 الرابط الجديد اللي انت بعته
    return await _apiService.get('patient/profile');
  }
}
