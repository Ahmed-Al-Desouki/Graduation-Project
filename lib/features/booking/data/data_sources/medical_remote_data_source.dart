import '../models/medical_record_model.dart';
import '../models/prescription_model.dart';
import '../models/medication_item_model.dart';

abstract class MedicalRemoteDataSource {
  Future<MedicalRecordModel> getMedicalRecord(String appointmentId);
  Future<String> createMedicalRecord(
    String appointmentId,
    MedicalRecordModel record,
  );
  Future<String> updateMedicalRecord(
    String appointmentId,
    MedicalRecordModel record,
  );

  Future<List<PrescriptionModel>> getPrescriptionByAppointment(
    String appointmentId,
  );
  Future<PrescriptionModel> createPrescription(
    Map<String, dynamic> prescriptionData,
  );
  Future<String> addPrescriptionItemsBulk(
    String prescriptionId,
    List<MedicationItemModel> items,
  );

  Future<Map<String, dynamic>> getPatientProfileForDoctor(
    String pId,
    String aId,
  );
  Future<void> grantMedicalAccess(
    String appointmentId,
    Map<String, dynamic> body,
  );
}
