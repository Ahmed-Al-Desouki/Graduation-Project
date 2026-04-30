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
  final nameController = TextEditingController();
  final dosageController = TextEditingController();
  final quantityController = TextEditingController();
  final durationValueController = TextEditingController(text: "7");
  final instructionsController = TextEditingController();

  String? nameError, dosageError, quantityError;

  final List<String> durationTypes = ["Days", "Weeks", "Months", "Ongoing"];
  String durationType = "Days";
  int frequencyType = 1;

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
                      backgroundColor: Colors.purple.withValues(alpha: 0.05),
                      selectedColor: Colors.purple.withValues(alpha: 0.1),
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

  void _autoCalculateQty() {
    int val = int.tryParse(durationValueController.text) ?? 1;
    double days = 0;
    if (durationType == "Days") {
      days = val.toDouble();
    } else if (durationType == "Weeks") {
      days = val * 7.0;
    } else if (durationType == "Months") {
      days = val * 30.0;
    } else {
      days = 30.0;
    }

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

  void _submit() {
    if (!_validate()) return;

    String finalDuration =
        frequencyType == 0
            ? "1 day"
            : "${durationValueController.text} ${durationType.toLowerCase()}";
    DateTime startDate = DateTime(
      selectedStartDate.year,
      selectedStartDate.month,
      selectedStartDate.day,
    );

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
      "reminderStartDate": startDate.toIso8601String().split('.')[0],
      "reminderDailyDoseTimes": dailyTimes,
    };

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
      reminderWeeklyDays: frequencyType == 2 ? weeklyDays : null,
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
        if (index != null) {
          dailyTimes[index] = formatted;
        } else if (!dailyTimes.contains(formatted)) {
          dailyTimes.add(formatted);
        }
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
    if (frequencyType == 0) {
      return "Once on ${DateFormat('MMM dd').format(selectedStartDate)}";
    }
    if (frequencyType == 1) return "Daily";
    if (frequencyType == 2) return "${weeklyDays.length} days/week";
    if (frequencyType == 3) return "${monthlyDays.length} days/month";
    return "Every $intervalHours hours";
  }
}
