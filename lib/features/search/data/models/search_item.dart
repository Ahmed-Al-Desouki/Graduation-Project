enum SearchType { doctor, specialty }

class SearchItem {
  final String title;
  final SearchType type;
  final SearchType? specialty;

  SearchItem({required this.title, required this.type, this.specialty});
}
// class SearchItem {
//   final String title;
//   final SearchType type;

//   SearchItem({required this.title, required this.type});
// }

final List<SearchItem> searchData = [
  SearchItem(title: "Dr. Sarah Johnson", type: SearchType.doctor),
  SearchItem(title: "Dr. Michael Chen", type: SearchType.doctor),
  SearchItem(title: "Dr. John Chen", type: SearchType.doctor),
  SearchItem(title: "Dr. Steve Chen", type: SearchType.doctor),
  SearchItem(title: "Dr. Mic Chen", type: SearchType.doctor),
  SearchItem(title: "Dr. Max Chen", type: SearchType.doctor),
  SearchItem(title: "Cardiologist", type: SearchType.specialty),
  SearchItem(title: "Dermatologist", type: SearchType.specialty),
  SearchItem(title: "Neurologist", type: SearchType.specialty),
];
