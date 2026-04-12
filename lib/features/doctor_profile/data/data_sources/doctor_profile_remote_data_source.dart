import '../models/doctor_profile_model.dart';

abstract class DoctorProfileRemoteDataSource {
  Future<DoctorProfileModel> getDoctorProfile();
}
