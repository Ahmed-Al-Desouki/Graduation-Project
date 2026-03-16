// import 'package:flutter/material.dart';
// import 'package:graduation_project/features/booking/domain/entities/medication_item_entity.dart';

// class AddMedicationSheet extends StatefulWidget {
//   final Function(MedicationItemEntity) onAdd;
//   const AddMedicationSheet({super.key, required this.onAdd});

//   @override
//   State<AddMedicationSheet> createState() => _AddMedicationSheetState();
// }

// class _AddMedicationSheetState extends State<AddMedicationSheet> {
//   final nameController = TextEditingController();
//   final dosageController = TextEditingController();
//   final quantityController = TextEditingController();
//   final durationValueController = TextEditingController(text: "7");
//   final instructionsController = TextEditingController();
//   // ✅ متغيرات لحمل رسائل الخطأ
//   String? nameError;
//   String? quantityError;

//   String durationType = "Days";
//   final List<String> durationTypes = ["Days", "Weeks", "Months", "Ongoing"];

//   int frequencyType = 1; // 1 = Daily
//   List<String> dailyTimes = ["09:00:00"];
//   List<int> weeklyDays = [];
//   int intervalHours = 8;
//   String firstDoseTime = "09:00:00";

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
//       ),
//       padding: EdgeInsets.only(
//         bottom: MediaQuery.of(context).viewInsets.bottom + 20,
//         left: 24,
//         right: 24,
//         top: 24,
//       ),
//       child: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildHandleBar(),
//             const SizedBox(height: 15),
//             const Text(
//               "Add Medication",
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 22,
//                 color: Color(0xFF9333EA),
//               ),
//             ),
//             const SizedBox(height: 20),

//             // الاسم (Required)
//             TextField(
//               controller: nameController,
//               onChanged:
//                   (_) => setState(
//                     () => nameError = null,
//                   ), // إخفاء الخطأ عند الكتابة
//               decoration: _buildInputDecoration(
//                 "Medication Name *",
//                 Icons.medication,
//               ).copyWith(errorText: nameError),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: dosageController,
//               decoration: _buildInputDecoration(
//                 "Dosage (e.g. 500mg) *",
//                 Icons.shutter_speed,
//               ),
//             ),
//             const SizedBox(height: 12),

//             // الـ Duration
//             Row(
//               children: [
//                 Expanded(flex: 2, child: _buildDurationTypeDropdown()),
//                 if (durationType != "Ongoing") ...[
//                   const SizedBox(width: 10),
//                   Expanded(
//                     flex: 1,
//                     child: TextField(
//                       controller: durationValueController,
//                       keyboardType: TextInputType.number,
//                       decoration: _buildInputDecoration("Val", null),
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//             const SizedBox(height: 12),

//             // الكمية (Required)
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: quantityController,
//                     onChanged: (_) => setState(() => quantityError = null),
//                     decoration: _buildInputDecoration(
//                       "Quantity *",
//                       Icons.inventory,
//                     ).copyWith(errorText: quantityError),
//                     keyboardType: TextInputType.number,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 TextButton.icon(
//                   onPressed: _autoCalculateQty,
//                   icon: const Icon(Icons.calculate, size: 18),
//                   label: const Text(
//                     "Auto Qty",
//                     style: TextStyle(color: Color(0xFF9333EA)),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: instructionsController,
//               decoration: _buildInputDecoration(
//                 "Special Instructions",
//                 Icons.note_alt,
//               ),
//             ),

//             const SizedBox(height: 25),
//             const Text(
//               "Reminder Frequency",
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//             ),
//             const SizedBox(height: 10),
//             _buildFrequencyDropdown(),
//             const SizedBox(height: 15),
//             _buildFrequencyOptions(),

//             const SizedBox(height: 30),
//             _buildSubmitButton(),
//           ],
//         ),
//       ),
//     );
//   }

//   // --- UI Components ---
//   Widget _buildHandleBar() => Center(
//     child: Container(
//       width: 50,
//       height: 5,
//       decoration: BoxDecoration(
//         color: Colors.grey[300],
//         borderRadius: BorderRadius.circular(10),
//       ),
//     ),
//   );

//   InputDecoration _buildInputDecoration(String label, IconData? icon) {
//     return InputDecoration(
//       labelText: label,
//       prefixIcon:
//           icon != null
//               ? Icon(icon, color: const Color(0xFF9333EA), size: 20)
//               : null,
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(15),
//         borderSide: BorderSide(color: Colors.grey[200]!),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(15),
//         borderSide: const BorderSide(color: Color(0xFF9333EA), width: 1.5),
//       ),
//       filled: true,
//       fillColor: Colors.grey[50],
//     );
//   }

//   Widget _buildDurationTypeDropdown() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           isExpanded: true,
//           value: durationType,
//           items:
//               durationTypes
//                   .map((t) => DropdownMenuItem(value: t, child: Text(t)))
//                   .toList(),
//           onChanged: (val) => setState(() => durationType = val!),
//         ),
//       ),
//     );
//   }

//   Widget _buildFrequencyDropdown() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<int>(
//           isExpanded: true,
//           value: frequencyType,
//           items: const [
//             DropdownMenuItem(value: 0, child: Text("Once")),
//             DropdownMenuItem(value: 1, child: Text("Daily")),
//             DropdownMenuItem(value: 2, child: Text("Weekly")),
//             DropdownMenuItem(value: 3, child: Text("Monthly")),
//             DropdownMenuItem(value: 4, child: Text("Every X Hours")),
//           ],
//           onChanged:
//               (val) => setState(() {
//                 frequencyType = val!;
//                 if (frequencyType == 0) dailyTimes = [dailyTimes.first];
//               }),
//         ),
//       ),
//     );
//   }

//   Widget _buildFrequencyOptions() {
//     if (frequencyType == 2) return _buildWeeklySelection();
//     if (frequencyType == 4) return _buildIntervalOption();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Wrap(
//           spacing: 8,
//           children:
//               dailyTimes
//                   .asMap()
//                   .entries
//                   .map(
//                     (entry) => InkWell(
//                       onTap: () => _pickTime(index: entry.key),
//                       child: Chip(
//                         backgroundColor: const Color(
//                           0xFF9333EA,
//                         ).withOpacity(0.1),
//                         label: Text(
//                           entry.value,
//                           style: const TextStyle(color: Color(0xFF9333EA)),
//                         ),
//                         onDeleted:
//                             dailyTimes.length > 1
//                                 ? () => setState(
//                                   () => dailyTimes.removeAt(entry.key),
//                                 )
//                                 : null,
//                         deleteIcon: const Icon(
//                           Icons.cancel,
//                           size: 16,
//                           color: Color(0xFF9333EA),
//                         ),
//                       ),
//                     ),
//                   )
//                   .toList(),
//         ),
//         if (frequencyType != 0)
//           TextButton.icon(
//             onPressed: () => _pickTime(),
//             icon: const Icon(
//               Icons.add_alarm,
//               size: 18,
//               color: Color(0xFF9333EA),
//             ),
//             label: const Text(
//               "Add Dose Time",
//               style: TextStyle(color: Color(0xFF9333EA)),
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildWeeklySelection() {
//     const days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Wrap(
//           spacing: 5,
//           children: List.generate(7, (index) {
//             bool isSelected = weeklyDays.contains(index);
//             return FilterChip(
//               label: Text(
//                 days[index],
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: isSelected ? Colors.white : Colors.black,
//                 ),
//               ),
//               selected: isSelected,
//               selectedColor: const Color(0xFF9333EA),
//               onSelected:
//                   (val) => setState(
//                     () =>
//                         val ? weeklyDays.add(index) : weeklyDays.remove(index),
//                   ),
//             );
//           }),
//         ),
//         _buildDoseTimesHeader(),
//       ],
//     );
//   }

//   Widget _buildIntervalOption() {
//     return Column(
//       children: [
//         Row(
//           children: [
//             const Text("Every "),
//             SizedBox(
//               width: 60,
//               child: TextField(
//                 keyboardType: TextInputType.number,
//                 textAlign: TextAlign.center,
//                 onChanged: (val) => intervalHours = int.tryParse(val) ?? 8,
//               ),
//             ),
//             const Text(" Hours"),
//           ],
//         ),
//         ListTile(
//           contentPadding: EdgeInsets.zero,
//           title: const Text("First Dose Time:", style: TextStyle(fontSize: 14)),
//           trailing: TextButton(
//             onPressed: () => _pickFirstDoseTime(),
//             child: Text(
//               firstDoseTime,
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF9333EA),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDoseTimesHeader() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         const Text("Dose Times:"),
//         TextButton(
//           onPressed: () => _pickTime(),
//           child: const Text(
//             "+ Add Time",
//             style: TextStyle(color: Color(0xFF9333EA)),
//           ),
//         ),
//       ],
//     );
//   }

//   // --- Logic Helpers ---
//   void _pickTime({int? index}) async {
//     final time = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
//     if (time != null) {
//       setState(() {
//         final formatted =
//             "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00";
//         if (index != null)
//           dailyTimes[index] = formatted;
//         else if (!dailyTimes.contains(formatted))
//           dailyTimes.add(formatted);
//       });
//     }
//   }

//   void _pickFirstDoseTime() async {
//     final time = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
//     if (time != null) {
//       setState(
//         () =>
//             firstDoseTime =
//                 "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00",
//       );
//     }
//   }

//   void _autoCalculateQty() {
//     int dosesPerDay =
//         (frequencyType == 4) ? (24 ~/ intervalHours) : dailyTimes.length;
//     int totalDays = 1;
//     int val = int.tryParse(durationValueController.text) ?? 1;
//     if (durationType == "Days")
//       totalDays = val;
//     else if (durationType == "Weeks")
//       totalDays = val * 7;
//     else if (durationType == "Months")
//       totalDays = val * 30;
//     else
//       totalDays = 30;
//     setState(
//       () => quantityController.text = (dosesPerDay * totalDays).toString(),
//     );
//   }

//   Widget _buildSubmitButton() {
//     return ElevatedButton(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: const Color(0xFF9333EA),
//         foregroundColor: Colors.white,
//         minimumSize: const Size(double.infinity, 55),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       ),
//       onPressed: _submit,
//       child: const Text(
//         "Add to Prescription",
//         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//       ),
//     );
//   }

//   void _submit() {
//     bool hasError = false;

//     // 1. Validation
//     if (nameController.text.trim().isEmpty) {
//       setState(() => nameError = "Name is required");
//       hasError = true;
//     }

//     final qty = int.tryParse(quantityController.text) ?? 0;
//     if (qty <= 0) {
//       setState(() => quantityError = "Invalid quantity");
//       hasError = true;
//     }

//     if (hasError) return;

//     // 2. Logic for Duration and EndDate
//     DateTime? endDate;
//     String finalDuration;

//     // ✅ معالجة خاصة لنوع "مرة واحدة" (Once)
//     if (frequencyType == 0) {
//       finalDuration = "Once";
//       endDate = null; // تاريخ النهاية هو نفس يوم البداية
//     } else {
//       finalDuration =
//           (durationType == "Ongoing")
//               ? "Ongoing"
//               : "${durationValueController.text} $durationType";

//       if (durationType != "Ongoing") {
//         int val = int.tryParse(durationValueController.text) ?? 1;
//         if (durationType == "Days")
//           endDate = DateTime.now().add(Duration(days: val));
//         else if (durationType == "Weeks")
//           endDate = DateTime.now().add(Duration(days: val * 7));
//         else if (durationType == "Months")
//           endDate = DateTime.now().add(Duration(days: val * 30));
//       }
//     }

//     // 3. Create Entity
//     final item = MedicationItemEntity(
//       medicationName: nameController.text.trim(),
//       dosage: dosageController.text.trim(),
//       frequency:
//           frequencyType == 0
//               ? "Take once"
//               : "Take ${dosageController.text} $finalDuration",
//       duration: finalDuration,
//       quantity: qty,
//       instructions:
//           instructionsController.text.isEmpty
//               ? "No special instructions"
//               : instructionsController.text,
//       reminderFrequencyType: frequencyType,
//       reminderStartDate: DateTime.now(),
//       reminderEndDate: endDate,
//       reminderIntervalHours: frequencyType == 4 ? intervalHours : null,
//       reminderFirstDoseTime: frequencyType == 4 ? firstDoseTime : null,
//       // ✅ التأكد من وجود ميعاد واحد على الأقل للنوع Once لضمان قبول السيرفر
//       reminderDailyDoseTimes:
//           frequencyType == 4
//               ? []
//               : (dailyTimes.isEmpty ? ["09:00:00"] : dailyTimes),
//       reminderWeeklyDays: frequencyType == 2 ? weeklyDays : [],
//     );

//     widget.onAdd(item);
//     Navigator.pop(context);
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:graduation_project/features/booking/domain/entities/medication_item_entity.dart';

// class AddMedicationSheet extends StatefulWidget {
//   final Function(MedicationItemEntity) onAdd;
//   const AddMedicationSheet({super.key, required this.onAdd});

//   @override
//   State<AddMedicationSheet> createState() => _AddMedicationSheetState();
// }

// class _AddMedicationSheetState extends State<AddMedicationSheet> {
//   // 1. Controllers & Errors
//   final nameController = TextEditingController();
//   final dosageController = TextEditingController();
//   final quantityController = TextEditingController();
//   final durationValueController = TextEditingController(text: "7");
//   final instructionsController = TextEditingController();

//   String? nameError, dosageError, quantityError;

//   // 2. Data State
//   final List<String> durationTypes = ["Days", "Weeks", "Months", "Ongoing"];
//   String durationType = "Days";

//   // 0: Once, 1: Daily, 2: Weekly, 3: Monthly, 4: Every X Hours
//   int frequencyType = 1;
//   List<String> dailyTimes = ["09:00:00"];
//   List<int> weeklyDays = [];
//   int intervalHours = 8;
//   int monthlyDay = 1;
//   DateTime selectedStartDate = DateTime.now();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: _sheetDecoration(),
//       padding: _sheetPadding(context),
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildHandleBar(),
//             _buildHeader(),
//             const SizedBox(height: 20),

//             _buildTextField(
//               nameController,
//               "Medication Name *",
//               Icons.medication,
//               error: nameError,
//             ),
//             _buildTextField(
//               dosageController,
//               "Dosage (e.g. 1 Tablet) *",
//               Icons.shutter_speed,
//               error: dosageError,
//             ),

//             const SizedBox(height: 15),
//             _buildSectionTitle("Treatment Timing"),
//             _buildStartDateTile(),

//             const SizedBox(height: 15),
//             _buildDurationAndQuantityRow(),

//             const SizedBox(height: 15),
//             _buildTextField(
//               instructionsController,
//               "Special Instructions",
//               Icons.note_alt,
//             ),

//             const SizedBox(height: 25),
//             _buildSectionTitle("Reminder Frequency"),
//             _buildFrequencyDropdown(),

//             const SizedBox(height: 15),
//             _buildDynamicFrequencyOptions(),

//             const SizedBox(height: 30),
//             _buildSubmitButton(),
//           ],
//         ),
//       ),
//     );
//   }

//   // --- 🧩 UI Components Methods ---

//   Widget _buildHeader() {
//     return const Text(
//       "Add Medication",
//       style: TextStyle(
//         fontWeight: FontWeight.bold,
//         fontSize: 22,
//         color: Color(0xFF9333EA),
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8.0),
//       child: Text(
//         title,
//         style: TextStyle(
//           fontWeight: FontWeight.bold,
//           fontSize: 13,
//           color: Colors.grey[600],
//         ),
//       ),
//     );
//   }

//   Widget _buildDurationAndQuantityRow() {
//     return Column(
//       children: [
//         Row(
//           children: [
//             Expanded(flex: 2, child: _buildDurationTypeDropdown()),
//             const SizedBox(width: 10),
//             if (durationType != "Ongoing")
//               Expanded(
//                 flex: 1,
//                 child: _buildTextField(
//                   durationValueController,
//                   "Val",
//                   null,
//                   isNumber: true,
//                 ),
//               ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             Expanded(
//               child: _buildTextField(
//                 quantityController,
//                 "Total Quantity *",
//                 Icons.inventory,
//                 error: quantityError,
//                 isNumber: true,
//               ),
//             ),
//             const SizedBox(width: 12),
//             _buildAutoCalcButton(),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildDynamicFrequencyOptions() {
//     switch (frequencyType) {
//       case 0:
//         return _buildDoseTimesList("Pick Time for the Dose");
//       case 1:
//         return _buildDoseTimesList("Daily Dose Times");
//       case 2:
//         return Column(
//           children: [
//             _buildWeeklyChips(),
//             const SizedBox(height: 10),
//             _buildDoseTimesList("Dose Times on Selected Days"),
//           ],
//         );
//       case 3:
//         return _buildMonthlyOption();
//       case 4:
//         return _buildIntervalOption();
//       default:
//         return const SizedBox();
//     }
//   }

//   // --- 📈 Logic & Calculations ---

//   void _autoCalculateQty() {
//     int totalDays = _calculateTotalDays();
//     int dosesPerDay = dailyTimes.length;
//     double result = 0;

//     switch (frequencyType) {
//       case 0:
//         result = dosesPerDay.toDouble();
//         break;
//       case 1:
//         result = totalDays * dosesPerDay.toDouble();
//         break;
//       case 2:
//         double weeks = totalDays / 7;
//         result =
//             weeks * (weeklyDays.isEmpty ? 1 : weeklyDays.length) * dosesPerDay;
//         break;
//       case 3:
//         double months = totalDays / 30;
//         result = months * 1 * dosesPerDay;
//         break;
//       case 4:
//         result = totalDays * (24 / intervalHours);
//         break;
//     }
//     setState(() => quantityController.text = result.ceil().toString());
//   }

//   int _calculateTotalDays() {
//     int val = int.tryParse(durationValueController.text) ?? 1;
//     if (durationType == "Weeks") return val * 7;
//     if (durationType == "Months") return val * 30;
//     return val;
//   }

//   void _submit() {
//     if (!_validateInputs()) return;

//     DateTime? endDate =
//         (durationType == "Ongoing")
//             ? null
//             : selectedStartDate.add(Duration(days: _calculateTotalDays()));
//     // لو مـرة واحدة، تاريخ النهاية هو نفس يوم البداية
//     if (frequencyType == 0) endDate = selectedStartDate;

//     final item = MedicationItemEntity(
//       medicationName: nameController.text.trim(),
//       dosage: dosageController.text.trim(),
//       frequency: _generateSummary(),
//       duration:
//           durationType == "Ongoing"
//               ? "Ongoing"
//               : "${durationValueController.text} $durationType",
//       quantity: int.parse(quantityController.text),
//       reminderFrequencyType: frequencyType,
//       reminderStartDate: selectedStartDate,
//       reminderEndDate: endDate,
//       reminderDailyDoseTimes: dailyTimes,
//       reminderWeeklyDays: weeklyDays,
//       reminderIntervalHours: frequencyType == 4 ? intervalHours : null,
//       instructions:
//           instructionsController.text.isEmpty
//               ? "No special instructions"
//               : instructionsController.text,
//     );

//     widget.onAdd(item);
//     Navigator.pop(context);
//   }

//   bool _validateInputs() {
//     setState(() {
//       nameError = nameController.text.isEmpty ? "Required" : null;
//       dosageError = dosageController.text.isEmpty ? "Required" : null;
//       quantityError =
//           (int.tryParse(quantityController.text) ?? 0) <= 0 ? "Invalid" : null;
//     });

//     if (frequencyType == 2 && weeklyDays.isEmpty) {
//       _showTopSnackBar("Please select at least one day for weekly repeat");
//       return false;
//     }

//     return nameError == null && dosageError == null && quantityError == null;
//   }

//   String _generateSummary() {
//     String timeStr = dailyTimes.join(", ");
//     if (frequencyType == 0)
//       return "Once on ${DateFormat('MMM dd').format(selectedStartDate)} at $timeStr";
//     if (frequencyType == 1) return "Daily at $timeStr";
//     if (frequencyType == 2) return "${weeklyDays.length} days/week at $timeStr";
//     return "As prescribed";
//   }

//   // --- 🛠️ Internal Helper Widgets ---

//   Widget _buildTextField(
//     TextEditingController controller,
//     String label,
//     IconData? icon, {
//     String? error,
//     bool isNumber = false,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10),
//       child: TextField(
//         controller: controller,
//         keyboardType: isNumber ? TextInputType.number : TextInputType.text,
//         decoration: _inputDecoration(label, icon).copyWith(errorText: error),
//       ),
//     );
//   }

//   Widget _buildStartDateTile() {
//     return InkWell(
//       onTap: () async {
//         final date = await showDatePicker(
//           context: context,
//           initialDate: selectedStartDate,
//           firstDate: DateTime.now().subtract(const Duration(days: 30)),
//           lastDate: DateTime.now().add(const Duration(days: 365)),
//         );
//         if (date != null) setState(() => selectedStartDate = date);
//       },
//       child: Container(
//         padding: const EdgeInsets.all(15),
//         decoration: BoxDecoration(
//           color: Colors.grey[50],
//           borderRadius: BorderRadius.circular(15),
//           border: Border.all(color: Colors.grey[200]!),
//         ),
//         child: Row(
//           children: [
//             const Icon(
//               Icons.calendar_month,
//               color: Color(0xFF9333EA),
//               size: 20,
//             ),
//             const SizedBox(width: 10),
//             Text(
//               DateFormat('EEEE, MMM dd, yyyy').format(selectedStartDate),
//               style: const TextStyle(fontSize: 15),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildWeeklyChips() {
//     const days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
//     return Wrap(
//       spacing: 6,
//       children: List.generate(
//         7,
//         (i) => FilterChip(
//           label: Text(
//             days[i],
//             style: TextStyle(
//               fontSize: 11,
//               color: weeklyDays.contains(i) ? Colors.white : Colors.black87,
//             ),
//           ),
//           selected: weeklyDays.contains(i),
//           onSelected:
//               (val) => setState(
//                 () => val ? weeklyDays.add(i) : weeklyDays.remove(i),
//               ),
//           selectedColor: const Color(0xFF9333EA),
//           checkmarkColor: Colors.white,
//         ),
//       ),
//     );
//   }

//   Widget _buildMonthlyOption() {
//     return Row(
//       children: [
//         const Text("Day in month: "),
//         DropdownButton<int>(
//           value: monthlyDay,
//           items: List.generate(
//             31,
//             (i) => DropdownMenuItem(value: i + 1, child: Text("${i + 1}")),
//           ),
//           onChanged: (v) => setState(() => monthlyDay = v!),
//         ),
//         const Spacer(),
//         _buildDoseTimesList("At Time"),
//       ],
//     );
//   }

//   Widget _buildDoseTimesList(String label) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 12,
//             color: Colors.blueGrey,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         const SizedBox(height: 5),
//         Wrap(
//           spacing: 8,
//           children:
//               dailyTimes
//                   .asMap()
//                   .entries
//                   .map(
//                     (e) => Chip(
//                       label: Text(
//                         e.value,
//                         style: const TextStyle(fontSize: 11),
//                       ),
//                       onDeleted:
//                           dailyTimes.length > 1
//                               ? () => setState(() => dailyTimes.removeAt(e.key))
//                               : null,
//                       deleteIcon: const Icon(Icons.close, size: 14),
//                     ),
//                   )
//                   .toList(),
//         ),
//         TextButton.icon(
//           onPressed: _pickTime,
//           icon: const Icon(Icons.add_alarm, size: 16),
//           label: const Text("Add Time", style: TextStyle(fontSize: 12)),
//         ),
//       ],
//     );
//   }

//   Widget _buildIntervalOption() {
//     return Row(
//       children: [
//         const Text("Every "),
//         SizedBox(
//           width: 50,
//           child: TextField(
//             keyboardType: TextInputType.number,
//             textAlign: TextAlign.center,
//             onChanged: (v) => intervalHours = int.tryParse(v) ?? 8,
//             decoration: const InputDecoration(hintText: "8"),
//           ),
//         ),
//         const Text(" Hours"),
//         const Spacer(),
//         _buildDoseTimesList("Starting at"),
//       ],
//     );
//   }

//   // --- 🎨 Styling & Low-level UI ---

//   InputDecoration _inputDecoration(String label, IconData? icon) =>
//       InputDecoration(
//         labelText: label,
//         prefixIcon:
//             icon != null
//                 ? Icon(icon, size: 20, color: const Color(0xFF9333EA))
//                 : null,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(15),
//           borderSide: BorderSide(color: Colors.grey[200]!),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(15),
//           borderSide: BorderSide(color: Colors.grey[200]!),
//         ),
//         filled: true,
//         fillColor: Colors.grey[50],
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: 12,
//         ),
//       );

//   BoxDecoration _sheetDecoration() => const BoxDecoration(
//     color: Colors.white,
//     borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
//   );

//   EdgeInsets _sheetPadding(BuildContext context) => EdgeInsets.only(
//     bottom: MediaQuery.of(context).viewInsets.bottom + 20,
//     left: 24,
//     right: 24,
//     top: 20,
//   );

//   Widget _buildHandleBar() => Center(
//     child: Container(
//       width: 40,
//       height: 4,
//       margin: const EdgeInsets.only(bottom: 20),
//       decoration: BoxDecoration(
//         color: Colors.grey[300],
//         borderRadius: BorderRadius.circular(10),
//       ),
//     ),
//   );

//   Widget _buildAutoCalcButton() => ElevatedButton.icon(
//     onPressed: _autoCalculateQty,
//     icon: const Icon(Icons.calculate, size: 16),
//     label: const Text("Auto"),
//     style: ElevatedButton.styleFrom(
//       backgroundColor: Colors.blue[50],
//       foregroundColor: Colors.blue,
//       elevation: 0,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//     ),
//   );

//   Widget _buildSubmitButton() => ElevatedButton(
//     style: ElevatedButton.styleFrom(
//       backgroundColor: const Color(0xFF9333EA),
//       foregroundColor: Colors.white,
//       minimumSize: const Size(double.infinity, 55),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//     ),
//     onPressed: _submit,
//     child: const Text(
//       "Add to Prescription",
//       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//     ),
//   );

//   void _pickTime() async {
//     final t = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
//     if (t != null) {
//       setState(() {
//         final formatted =
//             "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00";
//         if (!dailyTimes.contains(formatted)) dailyTimes.add(formatted);
//       });
//     }
//   }

//   Widget _buildDurationTypeDropdown() => Container(
//     padding: const EdgeInsets.symmetric(horizontal: 12),
//     decoration: BoxDecoration(
//       color: Colors.grey[50],
//       borderRadius: BorderRadius.circular(15),
//       border: Border.all(color: Colors.grey[200]!),
//     ),
//     child: DropdownButtonHideUnderline(
//       child: DropdownButton<String>(
//         isExpanded: true,
//         value: durationType,
//         items:
//             durationTypes
//                 .map((t) => DropdownMenuItem(value: t, child: Text(t)))
//                 .toList(),
//         onChanged: (v) => setState(() => durationType = v!),
//       ),
//     ),
//   );

//   Widget _buildFrequencyDropdown() => Container(
//     padding: const EdgeInsets.symmetric(horizontal: 12),
//     decoration: BoxDecoration(
//       color: Colors.grey[50],
//       borderRadius: BorderRadius.circular(15),
//       border: Border.all(color: Colors.grey[200]!),
//     ),
//     child: DropdownButtonHideUnderline(
//       child: DropdownButton<int>(
//         isExpanded: true,
//         value: frequencyType,
//         items: const [
//           DropdownMenuItem(value: 0, child: Text("Once")),
//           DropdownMenuItem(value: 1, child: Text("Daily")),
//           DropdownMenuItem(value: 2, child: Text("Weekly")),
//           DropdownMenuItem(value: 3, child: Text("Monthly")),
//           DropdownMenuItem(value: 4, child: Text("Every X Hours")),
//         ],
//         onChanged:
//             (v) => setState(() {
//               frequencyType = v!;
//               if (frequencyType == 0) dailyTimes = [dailyTimes.first];
//             }),
//       ),
//     ),
//   );

//   void _showTopSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         behavior: SnackBarBehavior.floating,
//         backgroundColor: Colors.redAccent,
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:graduation_project/features/booking/domain/entities/medication_item_entity.dart';

class AddMedicationSheet extends StatefulWidget {
  final Function(MedicationItemEntity) onAdd;
  const AddMedicationSheet({super.key, required this.onAdd});

  @override
  State<AddMedicationSheet> createState() => _AddMedicationSheetState();
}

class _AddMedicationSheetState extends State<AddMedicationSheet> {
  // 1. Controllers & Errors
  final nameController = TextEditingController();
  final dosageController = TextEditingController();
  final quantityController = TextEditingController();
  final durationValueController = TextEditingController(text: "7");
  final instructionsController = TextEditingController();

  String? nameError, dosageError, quantityError;

  // 2. Data State
  final List<String> durationTypes = ["Days", "Weeks", "Months", "Ongoing"];
  String durationType = "Days";
  int frequencyType = 1; // 0=Once, 1=Daily, 2=Weekly, 3=Monthly, 4=EveryXHours

  List<String> dailyTimes = ["09:00:00"];
  List<int> weeklyDays = [];
  List<int> monthlyDays = [];
  int intervalHours = 8;
  DateTime selectedStartDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _sheetDecoration(),
      padding: _sheetPadding(context),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHandleBar(),
            const Text(
              "Add Medication",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Color(0xFF9333EA),
              ),
            ),
            const SizedBox(height: 20),

            _buildTextField(
              nameController,
              "Medication Name *",
              Icons.medication,
              error: nameError,
            ),
            _buildTextField(
              dosageController,
              "Dosage (e.g. 1 Tablet) *",
              Icons.shutter_speed,
              error: dosageError,
            ),

            const SizedBox(height: 15),
            _buildSectionTitle("Treatment Schedule"),
            _buildStartDatePicker(),

            const SizedBox(height: 15),
            _buildDurationQuantitySection(),

            const SizedBox(height: 15),
            _buildTextField(
              instructionsController,
              "Special Instructions",
              Icons.note_alt,
              // maxLines: 2,
            ),

            const SizedBox(height: 25),
            _buildSectionTitle("Frequency & Reminders"),
            _buildFrequencyDropdown(),

            const SizedBox(height: 15),
            _buildDynamicFrequencyUI(),

            const SizedBox(height: 30),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  // --- 🧩 Modular UI Sections ---

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0, top: 10),
    child: Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 13,
        color: Colors.grey[600],
      ),
    ),
  );

  Widget _buildDurationQuantitySection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(flex: 2, child: _buildDurationDropdown()),
            const SizedBox(width: 10),
            if (durationType != "Ongoing")
              Expanded(
                flex: 1,
                child: _buildTextField(
                  durationValueController,
                  "Val",
                  null,
                  isNumber: true,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                quantityController,
                "Total Quantity *",
                Icons.inventory,
                error: quantityError,
                isNumber: true,
              ),
            ),
            const SizedBox(width: 12),
            _buildAutoCalcButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildDynamicFrequencyUI() {
    switch (frequencyType) {
      case 0:
        return _buildTimeSection("At What Time?");
      case 1:
        return _buildTimeSection("Daily Times");
      case 2:
        return Column(
          children: [
            _buildWeeklyChips(),
            const SizedBox(height: 10),
            _buildTimeSection("On these days at:"),
          ],
        );
      case 3:
        return Column(
          children: [
            _buildMonthlyGrid(),
            const SizedBox(height: 10),
            _buildTimeSection("At Time:"),
          ],
        );
      case 4:
        return _buildIntervalInput();
      default:
        return const SizedBox();
    }
  }

  Widget _buildTimeSection(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.blueGrey,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children:
              dailyTimes
                  .asMap()
                  .entries
                  .map(
                    (e) => InputChip(
                      // ✅ InputChip تدعم onPressed و onDeleted معاً
                      onPressed: () => _pickTime(index: e.key),
                      label: Text(
                        e.value,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9333EA),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onDeleted:
                          dailyTimes.length > 1
                              ? () => setState(() => dailyTimes.removeAt(e.key))
                              : null,
                      deleteIcon: const Icon(
                        Icons.cancel,
                        size: 16,
                        color: Color(0xFF9333EA),
                      ),
                      backgroundColor: Colors.purple.withOpacity(0.05),
                      selectedColor: Colors.purple.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Color(0xFF9333EA)),
                      ),
                    ),
                  )
                  .toList(),
        ),
        if (frequencyType != 0)
          TextButton.icon(
            onPressed: () => _pickTime(),
            icon: const Icon(Icons.add_alarm, size: 16),
            label: const Text("Add Time", style: TextStyle(fontSize: 12)),
          ),
      ],
    );
  }

  // --- 📈 Logic & Calculations ---

  void _autoCalculateQty() {
    int val = int.tryParse(durationValueController.text) ?? 1;
    double days = 0;
    if (durationType == "Days")
      days = val.toDouble();
    else if (durationType == "Weeks")
      days = val * 7.0;
    else if (durationType == "Months")
      days = val * 30.0;
    else
      days = 30.0;

    int dosesPerDay = dailyTimes.length;
    double calculatedQty = 0;

    switch (frequencyType) {
      case 0:
        calculatedQty = dosesPerDay.toDouble();
        break;
      case 1:
        calculatedQty = days * dosesPerDay;
        break;
      case 2:
        calculatedQty =
            (days / 7) *
            (weeklyDays.isEmpty ? 1 : weeklyDays.length) *
            dosesPerDay;
        break;
      case 3:
        calculatedQty =
            (days / 30) *
            (monthlyDays.isEmpty ? 1 : monthlyDays.length) *
            dosesPerDay;
        break;
      case 4:
        calculatedQty = days * (24 / intervalHours);
        break;
    }
    setState(() => quantityController.text = calculatedQty.ceil().toString());
  }

  // void _submit() {
  //   if (!_validate()) return;

  //   // DateTime? endDate =
  //   //     (durationType == "Ongoing")
  //   //         ? null
  //   //         : selectedStartDate.add(Duration(days: _calculateDurationInDays()));
  //   // if (frequencyType == 0) endDate = null;

  //   DateTime? endDate;
  //   String finalDuration;

  //   if (frequencyType == 0) {
  //     // ✅ السر هنا: بنخليه "1 Days" عشان السيرفر يقرأ الـ Count=1 صح
  //     finalDuration = "1 Days";
  //     // ✅ لازم نبعت تاريخ نهاية (بعدها بيوم) عشان الـ RRULE يشتغل
  //     endDate = selectedStartDate.add(const Duration(days: 1));
  //   } else {
  //     finalDuration =
  //         durationType == "Ongoing"
  //             ? "Ongoing"
  //             : "${durationValueController.text} $durationType";
  //     endDate =
  //         (durationType == "Ongoing")
  //             ? null
  //             : selectedStartDate.add(
  //               Duration(days: _calculateDurationInDays()),
  //             );
  //   }

  //   final item = MedicationItemEntity(
  //     reminderFirstDoseTime: frequencyType == 0 ? dailyTimes.first : null,
  //     medicationName: nameController.text.trim(),
  //     dosage: dosageController.text.trim(),
  //     frequency: _generateSummary(),
  //     duration: finalDuration,
  //     quantity: int.parse(quantityController.text),
  //     reminderFrequencyType: frequencyType,
  //     reminderStartDate: DateTime.now(),
  //     reminderEndDate: endDate,
  //     reminderDailyDoseTimes: dailyTimes,
  //     reminderWeeklyDays: frequencyType == 2 ? weeklyDays : [],
  //     reminderIntervalHours: frequencyType == 4 ? intervalHours : null,
  //     instructions:
  //         instructionsController.text.isEmpty
  //             ? "No instructions"
  //             : instructionsController.text,
  //     // تأكد من إضافة الحقول الناقصة في الـ Entity إذا كنت ستدعم الـ Monthly Days بشكل كامل برمجياً
  //   );

  //   widget.onAdd(item);
  //   Navigator.pop(context);
  // }

  void _submit() {
    if (!_validate()) return;

    // 1. تجهيز البيانات الأساسية
    String finalDuration =
        frequencyType == 0
            ? "1 day"
            : "${durationValueController.text} ${durationType.toLowerCase()}";
    DateTime startDate = DateTime(
      selectedStartDate.year,
      selectedStartDate.month,
      selectedStartDate.day,
    );

    // 2. بناء الـ Map يدويًا عشان نتحكم في الحقول اللي هتتبعت (JSON Clean)
    final Map<String, dynamic> medicationMap = {
      "medicationName": nameController.text.trim(),
      "dosage": dosageController.text.trim(),
      "frequency": frequencyType == 0 ? "Once" : _generateSummary(),
      "duration": finalDuration,
      "quantity": int.parse(quantityController.text),
      "instructions":
          instructionsController.text.isEmpty
              ? "No instructions"
              : instructionsController.text,
      "reminderFrequencyType": frequencyType,
      "reminderStartDate":
          startDate.toIso8601String().split('.')[0], // تسييق ISO بدون كسور
      "reminderDailyDoseTimes": dailyTimes,
    };

    // 3. إضافة الحقول الإضافية "فقط" لو مش Once (بناءً على مثال الباك)
    if (frequencyType != 0) {
      if (durationType != "Ongoing") {
        medicationMap["reminderEndDate"] =
            startDate
                .add(Duration(days: _calculateDurationInDays()))
                .toIso8601String()
                .split('.')[0];
      }
      if (frequencyType == 2) {
        medicationMap["reminderWeeklyDays"] = weeklyDays;
      }
      if (frequencyType == 4) {
        medicationMap["reminderIntervalHours"] = intervalHours;
      }
    }

    // 4. تحويل الـ Map لـ Entity أو إرساله للـ Cubit مباشرة
    // هنا هنحتاج نعدل الـ Cubit عشان يستلم Map أو نعدل الـ Model.toJson

    // لغرض التجربة السريعة، ابعت الـ item للـ View بتاعك كالمعتاد
    // بس تأكد إن الـ Model.toJson بيشيل الـ Nulls
    final item = MedicationItemEntity(
      medicationName: medicationMap["medicationName"],
      dosage: medicationMap["dosage"],
      frequency: medicationMap["frequency"],
      duration: medicationMap["duration"],
      quantity: medicationMap["quantity"],
      instructions: medicationMap["instructions"],
      reminderFrequencyType: frequencyType,
      reminderStartDate: startDate,
      reminderDailyDoseTimes: dailyTimes,
      reminderWeeklyDays:
          frequencyType == 2 ? weeklyDays : null, // نبعت null بدل []
      reminderEndDate:
          medicationMap["reminderEndDate"] != null
              ? DateTime.parse(medicationMap["reminderEndDate"])
              : null,
    );

    widget.onAdd(item);
    Navigator.pop(context);
  }

  int _calculateDurationInDays() {
    int val = int.tryParse(durationValueController.text) ?? 1;
    if (durationType == "Weeks") return val * 7;
    if (durationType == "Months") return val * 30;
    return val;
  }

  // --- 🛠️ Helper Methods (TimePicker, DatePicker, etc.) ---

  void _pickTime({int? index}) async {
    final t = await showTimePicker(
      context: context,
      initialTime:
          index != null
              ? TimeOfDay(
                hour: int.parse(dailyTimes[index].split(":")[0]),
                minute: int.parse(dailyTimes[index].split(":")[1]),
              )
              : TimeOfDay.now(),
    );
    if (t != null) {
      String formatted =
          "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00";
      setState(() {
        if (index != null)
          dailyTimes[index] = formatted;
        else if (!dailyTimes.contains(formatted))
          dailyTimes.add(formatted);
      });
    }
  }

  Widget _buildMonthlyGrid() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: List.generate(31, (i) {
        int day = i + 1;
        bool isSelected = monthlyDays.contains(day);
        return InkWell(
          onTap:
              () => setState(
                () =>
                    isSelected ? monthlyDays.remove(day) : monthlyDays.add(day),
              ),
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF9333EA) : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? const Color(0xFF9333EA) : Colors.grey[300]!,
              ),
            ),
            child: Text(
              "$day",
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        );
      }),
    );
  }

  // --- 🎨 Basic UI Builders ---
  Widget _buildStartDatePicker() => InkWell(
    onTap: () async {
      final date = await showDatePicker(
        context: context,
        initialDate: selectedStartDate,
        firstDate: DateTime.now().subtract(const Duration(days: 30)),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      );
      if (date != null) setState(() => selectedStartDate = date);
    },
    child: Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_month, color: Color(0xFF9333EA), size: 20),
          const SizedBox(width: 10),
          Text(DateFormat('EEEE, MMM dd, yyyy').format(selectedStartDate)),
        ],
      ),
    ),
  );

  Widget _buildTextField(
    TextEditingController ctrl,
    String label,
    IconData? icon, {
    String? error,
    bool isNumber = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: _inputDecoration(label, icon).copyWith(errorText: error),
    ),
  );

  InputDecoration _inputDecoration(String label, IconData? icon) =>
      InputDecoration(
        labelText: label,
        prefixIcon:
            icon != null
                ? Icon(icon, size: 20, color: const Color(0xFF9333EA))
                : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      );

  Widget _buildHandleBar() => Center(
    child: Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
  Widget _buildDurationDropdown() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: Colors.grey[50],
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: Colors.grey[200]!),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        isExpanded: true,
        value: durationType,
        items:
            durationTypes
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
        onChanged: (v) => setState(() => durationType = v!),
      ),
    ),
  );
  Widget _buildFrequencyDropdown() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: Colors.grey[50],
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: Colors.grey[200]!),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        isExpanded: true,
        value: frequencyType,
        items: const [
          DropdownMenuItem(value: 0, child: Text("Once")),
          DropdownMenuItem(value: 1, child: Text("Daily")),
          DropdownMenuItem(value: 2, child: Text("Weekly")),
          DropdownMenuItem(value: 3, child: Text("Monthly")),
          DropdownMenuItem(value: 4, child: Text("Every X Hours")),
        ],
        onChanged:
            (v) => setState(() {
              frequencyType = v!;
              if (frequencyType == 0) dailyTimes = [dailyTimes.first];
            }),
      ),
    ),
  );
  Widget _buildWeeklyChips() {
    const days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    return Wrap(
      spacing: 6,
      children: List.generate(
        7,
        (i) => FilterChip(
          label: Text(
            days[i],
            style: TextStyle(
              fontSize: 11,
              color: weeklyDays.contains(i) ? Colors.white : Colors.black,
            ),
          ),
          selected: weeklyDays.contains(i),
          onSelected:
              (val) => setState(
                () => val ? weeklyDays.add(i) : weeklyDays.remove(i),
              ),
          selectedColor: const Color(0xFF9333EA),
        ),
      ),
    );
  }

  Widget _buildAutoCalcButton() => ElevatedButton.icon(
    onPressed: _autoCalculateQty,
    icon: const Icon(Icons.calculate, size: 16),
    label: const Text("Auto"),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue[50],
      foregroundColor: Colors.blue,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
  Widget _buildSubmitButton() => ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF9333EA),
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 55),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    ),
    onPressed: _submit,
    child: const Text(
      "Add to Prescription",
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
  );
  Widget _buildIntervalInput() => Row(
    children: [
      const Text("Every "),
      SizedBox(
        width: 50,
        child: TextField(
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          onChanged: (v) => intervalHours = int.tryParse(v) ?? 8,
        ),
      ),
      const Text(" Hours"),
      const Spacer(),
      _buildTimeSection("Starting at"),
    ],
  );

  bool _validate() {
    setState(() {
      nameError = nameController.text.isEmpty ? "Required" : null;
      dosageError = dosageController.text.isEmpty ? "Required" : null;
      quantityError =
          (int.tryParse(quantityController.text) ?? 0) <= 0 ? "Invalid" : null;
    });
    if (frequencyType == 0 &&
        selectedStartDate.year == DateTime.now().year &&
        selectedStartDate.month == DateTime.now().month &&
        selectedStartDate.day == DateTime.now().day) {
      // بناخد أول وقت في اللستة ونقارنه بالساعة دلوقتي
      String selectedTime = dailyTimes.first; // "12:00:00"
      int selectedHour = int.parse(selectedTime.split(":")[0]);
      int selectedMinute = int.parse(selectedTime.split(":")[1]);

      DateTime now = DateTime.now();
      if (selectedHour < now.hour ||
          (selectedHour == now.hour && selectedMinute < now.minute)) {
        _showMsg("The selected time has already passed for today.");
        return false;
      }
    }
    if (frequencyType == 2 && weeklyDays.isEmpty) {
      _showMsg("Select weekly days");
      return false;
    }
    if (frequencyType == 3 && monthlyDays.isEmpty) {
      _showMsg("Select monthly days");
      return false;
    }
    return nameError == null && dosageError == null && quantityError == null;
  }

  void _showMsg(String m) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(m), backgroundColor: Colors.redAccent));
  BoxDecoration _sheetDecoration() => const BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
  );
  EdgeInsets _sheetPadding(BuildContext c) => EdgeInsets.only(
    bottom: MediaQuery.of(c).viewInsets.bottom + 20,
    left: 24,
    right: 24,
    top: 20,
  );

  String _generateSummary() {
    if (frequencyType == 0)
      return "Once on ${DateFormat('MMM dd').format(selectedStartDate)}";
    if (frequencyType == 1) return "Daily";
    if (frequencyType == 2) return "${weeklyDays.length} days/week";
    if (frequencyType == 3) return "${monthlyDays.length} days/month";
    return "Every $intervalHours hours";
  }
}
