class SurgeryModel {
  final int? surgeryID;
  final int historyID;
  final String name;
  final String? date;
  final String? notes;
  final String? complications;

  SurgeryModel({
    this.surgeryID,
    required this.historyID,
    required this.name,
    this.date,
    this.notes,
    this.complications,
  });

  factory SurgeryModel.fromJson(Map<String, dynamic> json) {
    return SurgeryModel(
      surgeryID: json['surgeryID'],
      historyID: json['historyID'] ?? 0,
      name: json['name'] ?? '',
      date: json['date'],
      notes: json['notes'],
      complications: json['complications'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (surgeryID != null) 'surgeryID': surgeryID,
      'historyID': historyID,
      'name': name,
      'date': date,
      'notes': notes,
      'complications': complications,
    };
  }
}
