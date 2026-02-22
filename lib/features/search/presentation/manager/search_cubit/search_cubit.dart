import 'dart:async';

import 'package:graduation_project/features/search/data/models/search_item.dart';

class SearchCubit {
  Timer? _debounce;

  void onQueryChanged({
    required String query,
    required Function(List<SearchItem>) onResult,
  }) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (query.trim().length < 3) {
        onResult([]);
        return;
      }

      final results =
          searchData.where((item) {
            return item.title.toLowerCase().contains(query.toLowerCase());
          }).toList();

      onResult(results);
    });
  }

  void dispose() {
    _debounce?.cancel();
  }
}
