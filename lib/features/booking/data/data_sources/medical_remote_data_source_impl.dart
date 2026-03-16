import 'package:graduation_project/core/utils/helper/api.dart';
import 'package:graduation_project/features/booking/data/data_sources/medical_remote_data_source.dart';
import 'package:graduation_project/features/booking/data/models/medical_record_model.dart';
import 'package:graduation_project/features/booking/data/models/medication_item_model.dart';
import 'package:graduation_project/features/booking/data/models/prescription_model.dart';

class MedicalRemoteDataSourceImpl implements MedicalRemoteDataSource {
  final ApiService _apiService;

  MedicalRemoteDataSourceImpl(this._apiService);

  @override
  Future<MedicalRecordModel> getMedicalRecord(String appointmentId) async {
    final data = await _apiService.get(
      'appointments/$appointmentId/medical-record',
    );
    return MedicalRecordModel.fromJson(data);
  }

  @override
  Future<String> createMedicalRecord(
    String appointmentId,
    MedicalRecordModel record,
  ) async {
    final data = await _apiService.post(
      'appointments/$appointmentId/medical-record',
      record.toJson(),
    );
    // السيرفر بيرجع { "message": "..." }
    return data['message'] ?? "Created Successfully";
  }

  @override
  Future<String> updateMedicalRecord(
    String appointmentId,
    MedicalRecordModel record,
  ) async {
    final data = await _apiService.put(
      'appointments/$appointmentId/medical-record',
      record.toJson(),
    );
    return data['message'] ?? "Updated Successfully";
  }

  @override
  Future<List<PrescriptionModel>> getPrescriptionByAppointment(
    String appointmentId,
  ) async {
    final data = await _apiService.get(
      'prescriptions/appointment/$appointmentId',
    );
    // بما أن الـ Get بترجع List من الروشتات
    return (data as List).map((e) => PrescriptionModel.fromJson(e)).toList();
  }

  @override
  Future<PrescriptionModel> createPrescription(
    Map<String, dynamic> prescriptionData,
  ) async {
    final data = await _apiService.post('prescriptions', prescriptionData);
    return PrescriptionModel.fromJson(data);
  }

  @override
  Future<String> addPrescriptionItemsBulk(
    String prescriptionId,
    List<MedicationItemModel> items,
  ) async {
    final data = await _apiService.post(
      'prescriptions/$prescriptionId/items/bulk',
      {'items': items.map((e) => e.toJson()).toList()},
    );
    return data['message'] ?? "Items Added Successfully";
  }
}
