import 'package:flutter/material.dart';

class GeneralSettingsSection extends StatelessWidget {
  final TextEditingController durationController;
  final TextEditingController bufferController;
  final String startDateText;
  final String endDateText;
  final VoidCallback onStartDateTap;
  final VoidCallback onEndDateTap;

  const GeneralSettingsSection({
    super.key,
    required this.durationController,
    required this.bufferController,
    required this.startDateText,
    required this.endDateText,
    required this.onStartDateTap,
    required this.onEndDateTap,
  });

  @override
  Widget build(BuildContext context) {
    // حساب الأبعاد بناءً على حجم الشاشة لضمان الـ Responsiveness
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Card(
      elevation: 0,
      color: Colors.blue.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'General Settings',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: screenHeight * 0.02),

            // صف يحتوي على مدة الكشف والبريك جنب بعض
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: durationController,
                    label: 'Duration',
                    hint: 'Mins',
                  ),
                ),
                SizedBox(width: screenWidth * 0.03),
                Expanded(
                  child: _buildTextField(
                    controller: bufferController,
                    label: 'Buffer',
                    hint: 'Mins',
                  ),
                ),
              ],
            ),

            SizedBox(height: screenHeight * 0.02),
            const Text(
              'Schedule Validity',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            SizedBox(height: screenHeight * 0.01),

            // صف لاختيار تاريخ البداية والنهاية
            Row(
              children: [
                Expanded(
                  child: _buildDateTile(
                    context,
                    label: "Start Date",
                    value: startDateText,
                    onTap: onStartDateTap,
                  ),
                ),
                SizedBox(width: screenWidth * 0.03),
                Expanded(
                  child: _buildDateTile(
                    context,
                    label: "End Date",
                    value: endDateText,
                    onTap: onEndDateTap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget صغير لبناء حقول النصوص بشكل موحد
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Widget صغير لبناء أزرار اختيار التاريخ
  Widget _buildDateTile(
    BuildContext context, {
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.blue),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
