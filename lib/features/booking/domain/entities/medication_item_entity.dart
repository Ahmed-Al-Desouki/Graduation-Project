class MedicationItemEntity {
  final String? itemId;
  final String medicationName;
  final String dosage;
  final String frequency;
  final String duration;
  final int quantity;
  final String? instructions;

  final int reminderFrequencyType;
  final List<int>? reminderWeeklyDays;
  final List<String>? reminderDailyDoseTimes;
  final int? reminderIntervalHours;
  final DateTime reminderStartDate;
  final DateTime? reminderEndDate;
  final String? reminderFirstDoseTime;

  MedicationItemEntity({
    this.itemId,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.quantity,
    this.instructions,
    required this.reminderFrequencyType,
    this.reminderWeeklyDays,
    this.reminderDailyDoseTimes,
    this.reminderIntervalHours,
    required this.reminderStartDate,
    this.reminderEndDate,
    this.reminderFirstDoseTime,
  });

  MedicationItemEntity copyWith({
    String? itemId,
    String? medicationName,
    String? dosage,
    String? frequency,
    String? duration,
    int? quantity,
    String? instructions,
    int? reminderFrequencyType,
    List<int>? reminderWeeklyDays,
    List<String>? reminderDailyDoseTimes,
    int? reminderIntervalHours,
    DateTime? reminderStartDate,
    DateTime? reminderEndDate,
    String? reminderFirstDoseTime,
  }) {
    return MedicationItemEntity(
      itemId: itemId ?? this.itemId,
      medicationName: medicationName ?? this.medicationName,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      duration: duration ?? this.duration,
      quantity: quantity ?? this.quantity,
      instructions: instructions ?? this.instructions,
      reminderFrequencyType:
          reminderFrequencyType ?? this.reminderFrequencyType,
      reminderWeeklyDays: reminderWeeklyDays ?? this.reminderWeeklyDays,
      reminderDailyDoseTimes:
          reminderDailyDoseTimes ?? this.reminderDailyDoseTimes,
      reminderIntervalHours:
          reminderIntervalHours ?? this.reminderIntervalHours,
      reminderStartDate: reminderStartDate ?? this.reminderStartDate,
      reminderEndDate: reminderEndDate ?? this.reminderEndDate,
      reminderFirstDoseTime:
          reminderFirstDoseTime ?? this.reminderFirstDoseTime,
    );
  }
}
