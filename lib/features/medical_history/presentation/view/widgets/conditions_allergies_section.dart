import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/medical_history/domain/models/health_item_model.dart';
import 'package:graduation_project/features/medical_history/domain/models/patient_profile_model.dart';
import 'package:graduation_project/features/medical_history/presentation/manager/patient_profile_cubit/patient_profile_cubit.dart';
import 'health_item_card.dart';
import 'dotted_add_button.dart';

class ConditionsAllergiesSection extends StatefulWidget {
  final PatientProfileModel profile;
  const ConditionsAllergiesSection({super.key, required this.profile});

  @override
  State<ConditionsAllergiesSection> createState() =>
      _ConditionsAllergiesSectionState();
}

class _ConditionsAllergiesSectionState
    extends State<ConditionsAllergiesSection> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    final conditions =
        widget.profile.chronicConditions
            .map((e) => HealthItem(name: e, type: HealthType.condition))
            .toList();

    final allergies =
        widget.profile.allergies
            .map((e) => HealthItem(name: e, type: HealthType.allergy))
            .toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE4E6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFF43F5E),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: const Text(
                        "Conditions & Allergies",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => setState(() => _isEditing = !_isEditing),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _isEditing ? Colors.red : const Color(0xFF84CC16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _isEditing ? "Done" : "Manage",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          _buildSectionHeader(
            "Chronic Conditions",
            Icons.favorite,
            const Color(0xFFF43F5E),
          ),
          const SizedBox(height: 12),
          ...conditions.map(
            (item) => HealthItemCard(
              item: item,
              isEditing: _isEditing,
              onDelete:
                  () => _updateList(
                    item.name,
                    HealthType.condition,
                    isDelete: true,
                  ),
            ),
          ),
          if (conditions.isEmpty)
            _buildEmptyState("No chronic conditions added."),

          const SizedBox(height: 24),

          _buildSectionHeader(
            "Allergies",
            Icons.pan_tool_rounded,
            const Color(0xFF8B5CF6),
          ),
          const SizedBox(height: 12),
          ...allergies.map(
            (item) => HealthItemCard(
              item: item,
              isEditing: _isEditing,
              onDelete:
                  () => _updateList(
                    item.name,
                    HealthType.allergy,
                    isDelete: true,
                  ),
            ),
          ),
          if (allergies.isEmpty) _buildEmptyState("No allergies added."),

          const SizedBox(height: 24),

          Opacity(
            opacity: _isEditing ? 0.5 : 1.0,
            child: IgnorePointer(
              ignoring: _isEditing,
              child: DottedAddButton(
                onTap: _showAddTypeDialog,
                text: "Add New Condition or Allergy",
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateList(String itemName, HealthType type, {bool isDelete = false}) {
    List<String> currentList;

    if (type == HealthType.condition) {
      currentList = List.from(widget.profile.chronicConditions);
    } else {
      currentList = List.from(widget.profile.allergies);
    }

    if (isDelete) {
      currentList.remove(itemName);
    } else {
      currentList.add(itemName);
    }

    Map<String, dynamic> updateBody = {
      "dateOfBirth": widget.profile.dateOfBirth,
      "gender": widget.profile.gender,
      "bloodType": widget.profile.bloodType ?? "string",
      "height": widget.profile.height,
      "weight": widget.profile.weight,
      "currentLocation": widget.profile.currentLocation ?? "string",

      "chronicConditions":
          type == HealthType.condition
              ? currentList
              : widget.profile.chronicConditions,
      "allergies":
          type == HealthType.allergy ? currentList : widget.profile.allergies,
    };

    context.read<PatientProfileCubit>().updateProfileInfo(updateBody);
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 12),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 14,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  void _showAddTypeDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "What would you like to add?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildDialogOption(
                "Chronic Condition",
                Icons.favorite_outline,
                Colors.red,
                () {
                  Navigator.pop(context);
                  _showNameInputDialog(HealthType.condition);
                },
              ),
              const SizedBox(height: 12),
              _buildDialogOption(
                "Allergy",
                Icons.pan_tool_outlined,
                Colors.purple,
                () {
                  Navigator.pop(context);
                  _showNameInputDialog(HealthType.allergy);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDialogOption(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showNameInputDialog(HealthType type) {
    TextEditingController nameController = TextEditingController();
    String typeName = type == HealthType.condition ? "Condition" : "Allergy";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text("Add $typeName"),
          content: TextField(
            controller: nameController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: "Enter $typeName name",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  _updateList(nameController.text, type, isDelete: false);
                  Navigator.pop(context);
                }
              },
              child: const Text("Add", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
