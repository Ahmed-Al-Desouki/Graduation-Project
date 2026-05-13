import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/support_tickets/presentation/manager/tickets_cubit/tickets_cubit.dart';

class CreateTicketBottomSheet extends StatefulWidget {
  const CreateTicketBottomSheet({super.key});

  @override
  State<CreateTicketBottomSheet> createState() =>
      _CreateTicketBottomSheetState();
}

class _CreateTicketBottomSheetState extends State<CreateTicketBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String description = '';
  final List<String> categories = [
    'Booking',
    'Payment',
    'Technical',
    'AccountIssue',
    'Verification',
    'Other',
  ];
  final List<String> priorities = ['Low', 'Normal', 'High', 'Urgent'];
  String selectedCategory = 'Technical';
  String selectedPriority = 'Normal';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "فتح تذكرة دعم جديدة",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            TextFormField(
              decoration: const InputDecoration(
                labelText: 'العنوان',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              onChanged: (val) => title = val,
              validator: (val) => val!.isEmpty ? 'يرجى إدخال العنوان' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              decoration: const InputDecoration(
                labelText: 'الوصف التفصيلي',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              onChanged: (val) => description = val,
              validator: (val) => val!.isEmpty ? 'يرجى إدخال الوصف' : null,
            ),
            const SizedBox(height: 16),

            // Dropdowns
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(labelText: 'القسم'),
                    items:
                        categories
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (val) => setState(() => selectedCategory = val!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedPriority,
                    decoration: const InputDecoration(labelText: 'الأولوية'),
                    items:
                        priorities
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (val) => setState(() => selectedPriority = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    context.read<TicketsCubit>().createNewTicket(
                      title: title,
                      description: description,
                      category: selectedCategory,
                      priority: selectedPriority,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  "إرسال التذكرة",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
