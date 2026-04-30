import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/features/booking/domain/entities/slot_entity.dart';
import 'package:graduation_project/features/booking/presentation/manager/appointment_action_cubit/appointment_action_cubit.dart';

class BookingConfirmDialog extends StatefulWidget {
  final SlotEntity slot;
  final String doctorName;
  final double consultationFee;

  const BookingConfirmDialog({
    super.key,
    required this.slot,
    required this.doctorName,
    required this.consultationFee,
  });

  @override
  State<BookingConfirmDialog> createState() => _BookingConfirmDialogState();
}

class _BookingConfirmDialogState extends State<BookingConfirmDialog> {
  final reasonController = TextEditingController();
  bool grantAccess = true;
  String selectedPaymentMethod = 'Card';

  final List<Map<String, dynamic>> paymentMethods = [
    {'id': 'Card', 'name': 'Credit Card', 'icon': Icons.credit_card},
    {
      'id': 'VodafoneCash',
      'name': 'Vodafone Cash',
      'icon': Icons.account_balance_wallet,
    },
    {
      'id': 'EtisalatCash',
      'name': 'Etisalat Cash',
      'icon': Icons.account_balance_wallet_outlined,
    },
    {'id': 'OrangeCash', 'name': 'Orange Cash', 'icon': Icons.wallet},
    {'id': 'WePay', 'name': 'WE Pay', 'icon': Icons.payments},
    {'id': 'Valu', 'name': 'Valu', 'icon': Icons.install_mobile},
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      title: Row(
        children: [
          const Icon(Icons.verified_outlined, color: Colors.green),
          SizedBox(width: 10.w),
          const Text("Confirm Booking"),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogInfoRow(
              Icons.person_outline,
              "Doctor",
              "Dr. ${widget.doctorName}",
            ),
            _buildDialogInfoRow(
              Icons.access_time,
              "Time",
              widget.slot.startTime,
            ),
            _buildDialogInfoRow(
              Icons.payments_outlined,
              "Fees",
              "${widget.consultationFee} EGP",
              isPrice: true,
            ),
            const Divider(height: 30),
            const Text(
              "Reason for visit",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: reasonController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: "Enter symptoms...",
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Select Payment Method",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children:
                  paymentMethods
                      .map((method) => _buildPaymentMethodItem(method))
                      .toList(),
            ),
            const SizedBox(height: 20),
            _buildMedicalHistorySwitch(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF9333EA),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          ),
          onPressed: () {
            Navigator.pop(context);
            context.read<AppointmentActionCubit>().bookAndPay(
              slotId: widget.slot.slotId,
              reason: reasonController.text,
              grantAccess: grantAccess,
              paymentMethod: selectedPaymentMethod,
            );
          },
          child: const Text(
            "Confirm & Pay",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodItem(Map<String, dynamic> method) {
    final isSelected = selectedPaymentMethod == method['id'];
    return InkWell(
      onTap: () => setState(() => selectedPaymentMethod = method['id']),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color(0xFF9333EA).withOpacity(0.1)
                  : Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF9333EA) : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              method['icon'],
              size: 16.sp,
              color: isSelected ? const Color(0xFF9333EA) : Colors.grey,
            ),
            SizedBox(width: 6.w),
            Text(
              method['name'],
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalHistorySwitch() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFF9333EA).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          const Icon(Icons.history_edu, color: Color(0xFF9333EA), size: 20),
          SizedBox(width: 10.w),
          const Expanded(
            child: Text(
              "Share Medical History",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          Switch(
            value: grantAccess,
            activeThumbColor: const Color(0xFF9333EA),
            onChanged: (val) => setState(() => grantAccess = val),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isPrice = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: Colors.grey),
          SizedBox(width: 8.w),
          Text(
            "$label: ",
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isPrice ? Colors.blue : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
