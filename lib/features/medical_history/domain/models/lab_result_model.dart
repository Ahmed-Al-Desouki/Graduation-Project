enum RecordType { lab, radiology }

class LabResultModel {
  final String id;
  final String title;
  final String date;
  final RecordType type;
  final String? fileName;
  LabResultModel({
    required this.id,
    required this.title,
    required this.date,
    required this.type,
    this.fileName,
  });
}
