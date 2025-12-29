class FamilyHistoryModel {
  final int? familyHistoryID;
  final int historyID;
  final String condition;
  final String relative;
  final int? onsetAge;
  final String? notes;
  final bool isVerified;

  FamilyHistoryModel({
    this.familyHistoryID,
    required this.historyID,
    required this.condition,
    required this.relative,
    this.onsetAge,
    this.notes,
    required this.isVerified,
  });

  factory FamilyHistoryModel.fromJson(Map<String, dynamic> json) {
    return FamilyHistoryModel(
      familyHistoryID: json['familyHistoryID'],
      historyID: json['historyID'] ?? 0,
      condition: json['condition'] ?? '',
      relative: json['relative'] ?? '',
      onsetAge: json['onsetAge'],
      notes: json['notes'],
      isVerified: json['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (familyHistoryID != null) 'familyHistoryID': familyHistoryID,
      'historyID': historyID,
      'condition': condition,
      'relative': relative,
      'onsetAge': onsetAge,
      'notes': notes,
      'isVerified': isVerified,
    };
  }
}
