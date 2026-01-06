class SocialHistoryModel {
  final int? socialHistoryID;
  final int historyID;
  final String smokingStatus;
  final String? smokingDetails;
  final String alcoholUse;
  final String? drugUse;
  final String? occupation;
  final String? exercise;
  final String? notes;

  SocialHistoryModel({
    this.socialHistoryID,
    required this.historyID,
    required this.smokingStatus,
    this.smokingDetails,
    required this.alcoholUse,
    this.drugUse,
    this.occupation,
    this.exercise,
    this.notes,
  });

  factory SocialHistoryModel.fromJson(Map<String, dynamic> json) {
    return SocialHistoryModel(
      socialHistoryID: json['socialHistoryID'],
      historyID: json['historyID'] ?? 0,
      smokingStatus: json['smokingStatus'] ?? 'Unknown',
      smokingDetails: json['smokingDetails'],
      alcoholUse: json['alcoholUse'] ?? 'Unknown',
      drugUse: json['drugUse'],
      occupation: json['occupation'],
      exercise: json['exercise'],
      notes: json['notes'],
    );
  }

  // Map<String, dynamic> toJson() {
  //   return {
  //     if (socialHistoryID != null) 'socialHistoryID': socialHistoryID,
  //     'historyID': historyID,
  //     'smokingStatus': smokingStatus,
  //     'smokingDetails': smokingDetails,
  //     'alcoholUse': alcoholUse,
  //     'drugUse': drugUse,
  //     'occupation': occupation,
  //     'exercise': exercise,
  //     'notes': notes,
  //   };
  // }
  Map<String, dynamic> toJson() {
    return {
      // في حالة الـ Create لأول مرة، جرب بعت الـ ID كـ 0 أو عدم بعته نهائياً
      if (socialHistoryID != null) 'socialHistoryID': socialHistoryID,

      'historyID': historyID,
      'smokingStatus': smokingStatus,
      'smokingDetails': smokingDetails?.isEmpty == true ? null : smokingDetails,
      'alcoholUse': alcoholUse,

      // تحويل النصوص الفارغة إلى null بشكل قطعي
      'drugUse': drugUse?.isEmpty == true ? null : drugUse,
      'occupation': occupation?.isEmpty == true ? null : occupation,
      'exercise': exercise?.isEmpty == true ? null : exercise,
      'notes': notes?.isEmpty == true ? null : notes,
    };
  }
}
