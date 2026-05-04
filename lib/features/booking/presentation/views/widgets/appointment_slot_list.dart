import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/app_router.dart';

import '../../../domain/entities/slot_entity.dart';
import '../../manager/appointment_action_cubit/appointment_action_cubit.dart';
import 'slot_card.dart';

class AppointmentSlotList extends StatelessWidget {
  final List<SlotEntity> slots;
  final bool isFollowUpMode;
  final String? originalAppointmentId;
  final bool isPatientView;
  final String? doctorName;
  final double? consultationFee;

  const AppointmentSlotList({
    super.key,
    required this.slots,
    this.isFollowUpMode = false,
    this.originalAppointmentId,
    this.isPatientView = false,
    this.doctorName,
    this.consultationFee,
  });

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return const Center(
        child: Text(
          "No slots generated for this day.",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        return SlotCard(
          slot: slot,
          isPatientView: isPatientView,
          isFollowUpMode: isFollowUpMode,
          onBook:
              isPatientView ? () => _showBookingDialog(context, slot) : null,
          onDetails: () {
            context.push(
              AppRouter.kMedicalDetails,
              extra: {
                'appointmentId': slot.appointmentId,
                'patientName': slot.patientName,
                'status': slot.status,
              },
            );
          },
          onCancelByDoctor:
              () => context.read<AppointmentActionCubit>().doctorCancel(
                slot.appointmentId!,
                "Doctor Request",
              ),
          onDelete:
              () => context.read<AppointmentActionCubit>().deleteAvailableSlot(
                slot.slotId,
              ),
          onBlock:
              () => context.read<AppointmentActionCubit>().blockAvailableSlot(
                slot.slotId,
              ),
          onBookFollowUp:
              () => context.read<AppointmentActionCubit>().bookFollowUp(
                originalId: originalAppointmentId!,
                slotId: slot.slotId,
                instructions: "Follow-up",
              ),
          unblock:
              () => context.read<AppointmentActionCubit>().restoreSlot(
                slot.slotId,
              ),
        );
      },
    );
  }

  void _showBookingDialog(BuildContext context, SlotEntity slot) {
    final reasonController = TextEditingController();
    bool grantAccess = true;
    String selectedPaymentMethod = 'Card';

    final List<Map<String, dynamic>> paymentMethods = [
      {'id': 'Card', 'name': 'Card', 'icon': Icons.credit_card},
      {
        'id': 'VodafoneCash',
        'name': 'Vodafone',
        'icon': Icons.account_balance_wallet,
      },
      {
        'id': 'EtisalatCash',
        'name': 'Etisalat',
        'icon': Icons.account_balance_wallet_outlined,
      },
    ];

    final appointmentCubit = context.read<AppointmentActionCubit>();

    showDialog(
      context: context,
      builder:
          (dialogContext) => BlocProvider.value(
            value: appointmentCubit,
            child: StatefulBuilder(
              builder:
                  (context, setDialogState) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    title: const Text("Confirm Booking"),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Doctor: Dr. $doctorName",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text("Time: ${slot.startTime}"),
                          Text(
                            "Fees: $consultationFee EGP",
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(height: 30),

                          const Text(
                            "Reason for visit",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          TextField(
                            controller: reasonController,
                            decoration: InputDecoration(
                              hintText: "Reason for visit",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            "Payment Method",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Wrap(
                            spacing: 8,
                            children:
                                paymentMethods.map((method) {
                                  final isSelected =
                                      selectedPaymentMethod == method['id'];
                                  return ChoiceChip(
                                    label: Text(method['name']),
                                    selected: isSelected,
                                    onSelected:
                                        (val) => setDialogState(
                                          () =>
                                              selectedPaymentMethod =
                                                  method['id'],
                                        ),
                                    selectedColor: const Color(
                                      0xFF9333EA,
                                    ).withValues(alpha: 0.2),
                                  );
                                }).toList(),
                          ),

                          const SizedBox(height: 20),
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  "Share History",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                              Switch(
                                value: grantAccess,
                                onChanged:
                                    (v) =>
                                        setDialogState(() => grantAccess = v),
                                activeThumbColor: const Color(0xFF9333EA),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9333EA),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          appointmentCubit.bookAndPay(
                            slotId: slot.slotId,
                            reason: reasonController.text,
                            grantAccess: grantAccess,
                            paymentMethod: selectedPaymentMethod,
                          );
                        },
                        child: const Text(
                          "Confirm & Pay",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
            ),
          ),
    );
  }
}
