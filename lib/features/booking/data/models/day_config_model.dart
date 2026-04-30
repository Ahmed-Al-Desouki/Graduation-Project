class DayConfigModel {
  final String startTime;
  final String endTime;
  final int slotDurationMinutes;
  final int bufferTimeMinutes;

  DayConfigModel({
    required this.startTime,
    required this.endTime,
    required this.slotDurationMinutes,
    required this.bufferTimeMinutes,
  });

  Map<String, dynamic> toJson() => {
    "startTime": startTime,
    "endTime": endTime,
    "slotDurationMinutes": slotDurationMinutes,
    "bufferTimeMinutes": bufferTimeMinutes,
  };

  factory DayConfigModel.fromJson(Map<String, dynamic> json) {
    return DayConfigModel(
      startTime: json['startTime'],
      endTime: json['endTime'],
      slotDurationMinutes: json['slotDurationMinutes'],
      bufferTimeMinutes: json['bufferTimeMinutes'],
    );
  }
}
