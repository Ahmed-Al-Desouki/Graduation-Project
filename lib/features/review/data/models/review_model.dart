class ReviewModel {
  final int doctorId;
  final int rating;
  final String comment;

  ReviewModel({
    required this.doctorId,
    required this.rating,
    required this.comment,
  });

  Map<String, dynamic> toJson() => {
    "doctorId": doctorId,
    "rating": rating,
    "comment": comment,
  };
}
