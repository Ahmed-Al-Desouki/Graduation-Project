import 'package:graduation_project/core/utils/helper/api.dart';
import 'package:graduation_project/features/doctor_profile/data/data_sources/doctor_profile_remote_data_source.dart';
import 'package:graduation_project/features/doctor_profile/data/models/doctor_profile_model.dart';

class DoctorProfileRemoteDataSourceImpl
    implements DoctorProfileRemoteDataSource {
  final ApiService _apiService;

  DoctorProfileRemoteDataSourceImpl(this._apiService);

  @override
  Future<DoctorProfileModel> getDoctorProfile() async {
    final response = await _apiService.get('doctor/profile');
    return DoctorProfileModel.fromJson(response as Map<String, dynamic>);
  }
}
