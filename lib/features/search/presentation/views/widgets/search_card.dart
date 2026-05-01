import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/utils/functions/show_snack_bar.dart';
import 'package:graduation_project/features/search/presentation/manager/search_cubit/search_cubit.dart';
import 'package:graduation_project/features/search/presentation/views/widgets/specialty_bottom_sheet_for_search.dart';
import 'package:permission_handler/permission_handler.dart';

class SearchCard extends StatefulWidget {
  final String searchQuery;
  final void Function(String) onSearchChanged;
  final String selectedSpecialty;
  final void Function(String) onSpecialtyChanged;
  final List<String> allSpecializations;

  const SearchCard({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.selectedSpecialty,
    required this.onSpecialtyChanged,
    required this.allSpecializations,
  });

  @override
  State<SearchCard> createState() => _SearchCardState();
}

class _SearchCardState extends State<SearchCard> {
  late TextEditingController controller;
  double? _selectedRadius;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(covariant SearchCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != controller.text) {
      controller.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String displaySpecialty =
        (widget.selectedSpecialty.isEmpty)
            ? "All Specialties"
            : widget.selectedSpecialty;

    return Transform.translate(
      offset: const Offset(0, -20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: widget.onSearchChanged,
                      decoration: InputDecoration(
                        hintText: "Search doctor",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _openSpecialtySheet(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            displaySpecialty.length > 10
                                ? "${displaySpecialty.substring(0, 10)}..."
                                : displaySpecialty,
                            style: const TextStyle(fontSize: 13),
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFE0E7FF),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => _showRadiusBottomSheet(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on_sharp,
                          color: Color(0xFF2563EB),
                          size: 20,
                        ),
                        SizedBox(width: 3),
                        Text(
                          _selectedRadius != null
                              ? "Near you (${_selectedRadius!.toStringAsFixed(0)} km)"
                              : "Near you",
                          style: TextStyle(
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_selectedRadius != null)
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.red.shade600,
                        size: 22,
                      ),
                      onPressed: () {
                        setState(() => _selectedRadius = null);
                        context.read<SearchCubit>().clearNearbySearch();
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openSpecialtySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => SpecialtyBottomSheetForSearch(
            allSpecializations: widget.allSpecializations,
            selectedSpecialty: widget.selectedSpecialty,
            onSelected: (value) {
              widget.onSpecialtyChanged(value);
              Navigator.pop(context);
            },
          ),
    );
  }

  void _showRadiusBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (sheetContext) => BlocProvider.value(
            value: context.read<SearchCubit>(),
            child: StatefulBuilder(
              builder:
                  (context, setState) => Container(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                      left: 16,
                      right: 16,
                      top: 16,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Search Radius",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Slider(
                          value: _selectedRadius ?? 10,
                          min: 1,
                          max: 100,
                          divisions: 9,
                          activeColor: Color(0xFF2563EB),
                          label:
                              "${(_selectedRadius ?? 10).toStringAsFixed(0)} km",
                          onChanged: (value) {
                            setState(() => _selectedRadius = value);
                          },
                        ),
                        Text(
                          "${(_selectedRadius ?? 10).toStringAsFixed(0)} km radius",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.red.shade400,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () => Navigator.pop(sheetContext),
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () async {
                                  final status =
                                      await Permission.locationWhenInUse.status;
                                  if (!status.isGranted) {
                                    final result =
                                        await Permission.locationWhenInUse
                                            .request();
                                    if (!result.isGranted) {
                                      if (mounted) {
                                        showSnackBar(
                                          context,
                                          'Location permission is required to find nearby doctors',
                                          Colors.red,
                                        );
                                      }
                                      Navigator.pop(context);
                                      return;
                                    }
                                  }
                                  Navigator.pop(sheetContext);
                                  context.read<SearchCubit>().searchNearby(
                                    radiusKm: _selectedRadius,
                                  );
                                },
                                child: const Text(
                                  "Search",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 45),
                      ],
                    ),
                  ),
            ),
          ),
    );
  }
}
