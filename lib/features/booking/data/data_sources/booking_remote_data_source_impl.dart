import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduation_project/core/utils/helper/api.dart';
import 'package:graduation_project/features/booking/data/models/requests/day_slots_model.dart';
import 'package:graduation_project/features/chat/data/models/chat_model.dart';

import 'booking_remote_data_source.dart';

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final ApiService _apiService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  BookingRemoteDataSourceImpl(this._apiService);

  @override
  Future<String> createSchedule(
    String doctorId,
    Map<String, dynamic> body,
  ) async {
    final response = await _apiService.put(
      'doctors/$doctorId/slot-config/days/${body['dayOfWeek']}',
      body,
    );
    return response['message'] ?? "Config Updated";
  }

  @override
  Future<List<dynamic>> getActiveSchedule(String doctorId) async {
    final response = await _apiService.get('doctors/$doctorId/slot-config');
    return response as List<dynamic>;
  }

  @override
  Future<void> removeWorkingDay(String doctorId, int dayOfWeek) async {
    await _apiService.delete('doctors/$doctorId/slot-config/days/$dayOfWeek');
  }

  @override
  Future<void> addDayOff(String doctorId, Map<String, dynamic> body) async {
    await _apiService.post(
      'doctors/$doctorId/slot-config/exceptions/day-off',
      body,
    );
  }

  @override
  Future<void> addCustomHours(
    String doctorId,
    Map<String, dynamic> body,
  ) async {
    await _apiService.post(
      'doctors/$doctorId/slot-config/exceptions/custom-hours',
      body,
    );
  }

  @override
  Future<void> removeException(String doctorId, String date) async {
    await _apiService.delete('doctors/$doctorId/slot-config/exceptions/$date');
  }

  @override
  Future<Map<String, dynamic>> generateSlots(
    String doctorId,
    Map<String, dynamic> body,
  ) async {
    return await _apiService.post(
      'doctors/$doctorId/slot-config/generate',
      body,
    );
  }

  @override
  Future<List<DaySlotsModel>> getSlotsRange(
    String doctorId,
    String start,
    String end, {
    String? status,
  }) async {
    final response = await _apiService.get(
      'doctors/$doctorId/time-slots/range',
      queryParameters: {
        'startDate': start,
        'endDate': end,
        if (status != null) 'status': status,
      },
    );

    return (response['dailySlots'] as List)
        .map((e) => DaySlotsModel.fromJson(e))
        .toList();
  }

  @override
  Future<void> createManualSlot(
    String doctorId,
    Map<String, dynamic> body,
  ) async {
    await _apiService.post('doctors/$doctorId/time-slots/manual', body);
  }

  @override
  Future<void> deleteSlot(String doctorId, String slotId) async {
    await _apiService.delete('doctors/$doctorId/time-slots/$slotId');
  }

  @override
  Future<void> blockSlot(String doctorId, String slotId) async {
    await _apiService.patch('doctors/$doctorId/time-slots/$slotId/block');
  }

  @override
  Future<List<Map<String, dynamic>>> getDoctorAppointments(
    String? date,
    String? status,
  ) async {
    final response = await _apiService.get(
      'appointments/doctor-appointments',
      queryParameters: {'date': date, 'status': status},
    );
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<List<Map<String, dynamic>>> getPatientAppointments(
    String? status,
  ) async {
    final response = await _apiService.get(
      'appointments/my-appointments',
      queryParameters: {'status': status},
    );
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<void> updateAppointmentStatus(
    String appointmentId,
    String action, {
    Map<String, dynamic>? body,
  }) async {
    await _apiService.patch('appointments/$appointmentId/$action', body: body);
  }

  @override
  Future<void> bookFollowUp(
    String originalId,
    String type,
    Map<String, dynamic> body,
  ) async {
    await _apiService.post('appointments/$originalId/follow-up/$type', body);
  }

  @override
  Future<void> cancelByDoctor(
    String appointmentId,
    Map<String, dynamic>? body,
  ) async {
    await _apiService.post(
      'appointments/$appointmentId/doctor-cancel-block',
      body,
    );
  }

  @override
  Future<void> cancelByPatient(
    String appointmentId,
    Map<String, dynamic>? body,
  ) async {
    await _apiService.post('appointments/$appointmentId/cancel-patient', body);
  }

  @override
  Future<Map<String, dynamic>> bookWithPayment(
    Map<String, dynamic> body, {
    required String paymentMethod,
  }) async {
    final response = await _apiService.post(
      'appointments/book-with-payment?paymentMethod=$paymentMethod',
      body,
    );
    // log(response);
    return response;
  }

  @override
  Future<Map<String, dynamic>> getAppointmentFullDetails(
    String appointmentId,
  ) async {
    final response = await _apiService.get('appointments/$appointmentId');
    log('appointments $response');
    return response as Map<String, dynamic>;
  }

  @override
  Future<void> createChatRoom(ChatModel chatModel) async {
    await _firestore
        .collection('chats')
        .doc(chatModel.chatId)
        .set(chatModel.toFirestore(), SetOptions(merge: true));
  }

  @override
  Future<void> restoreBlockedSlots(
    String doctorId,
    List<String> slotIds,
  ) async {
    await _apiService.patch(
      'doctors/$doctorId/time-slots/restore-blocked',
      body: {'slotIds': slotIds},
    );
  }
}
