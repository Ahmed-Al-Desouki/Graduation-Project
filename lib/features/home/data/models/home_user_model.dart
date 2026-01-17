class HomeUserModel {
  final String fullName;
  final String? imageUrl;

  HomeUserModel({required this.fullName, this.imageUrl});

  factory HomeUserModel.fromJson(Map<String, dynamic> json) {
    return HomeUserModel(
      fullName: json['fullName'] ?? 'User',
      imageUrl: json['imageUrl'],
    );
  }
}
