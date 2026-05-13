import 'package:flutter/material.dart';
import 'package:graduation_project/core/utils/helper/medication_logic_helper.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/medication_item_entity.dart';
import 'widgets/medication_form_components.dart';

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

            _buildTextField(
              instructionsController,
              "Special Instructions",
              Icons.note_alt,
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

  Widget _buildDynamicFrequencyUI() {
    switch (frequencyType) {
      case 0: // Once
        return _buildTimeLabel(
          "At What Time?",
          child: ReminderTimeSelector(
            times: dailyTimes,
            onPickTime: (i) => _pickTime(index: i),
            onDelete: (i) => setState(() => dailyTimes.removeAt(i)),
            onAddTime: _pickTime,
            showAddButton: false,
          ),
        );
      case 1: // Daily
        return _buildTimeLabel(
          "Daily Times",
          child: ReminderTimeSelector(
            times: dailyTimes,
            onPickTime: (i) => _pickTime(index: i),
            onDelete: (i) => setState(() => dailyTimes.removeAt(i)),
            onAddTime: _pickTime,
          ),
        );
      case 2: // Weekly
        return Column(
          children: [
            WeeklyDayPicker(
              selectedDays: weeklyDays,
              onSelected:
                  (i, v) => setState(
                    () => v ? weeklyDays.add(i) : weeklyDays.remove(i),
                  ),
            ),
            const SizedBox(height: 10),
            _buildTimeLabel(
              "On these days at:",
              child: ReminderTimeSelector(
                times: dailyTimes,
                onPickTime: (i) => _pickTime(index: i),
                onDelete: (i) => setState(() => dailyTimes.removeAt(i)),
                onAddTime: _pickTime,
              ),
            ),
          ],
        );
      case 3: // Monthly
        return Column(
          children: [
            MonthlyDayGrid(
              selectedDays: monthlyDays,
              onToggle:
                  (d) => setState(
                    () =>
                        monthlyDays.contains(d)
                            ? monthlyDays.remove(d)
                            : monthlyDays.add(d),
                  ),
            ),
            const SizedBox(height: 10),
            _buildTimeLabel(
              "At Time:",
              child: ReminderTimeSelector(
                times: dailyTimes,
                onPickTime: (i) => _pickTime(index: i),
                onDelete: (i) => setState(() => dailyTimes.removeAt(i)),
                onAddTime: _pickTime,
              ),
            ),
          ],
        );
      case 4: // Every X Hours
        return _buildIntervalInput();
      default:
        return const SizedBox();
    }
  }

  void _autoCalculateQty() {
    final qty = MedicationLogicHelper.calculateQuantity(
      durationValue: int.tryParse(durationValueController.text) ?? 1,
      durationType: durationType,
      frequencyType: frequencyType,
      dosesPerDay: dailyTimes.length,
      intervalHours: intervalHours,
      weeklyDaysCount: weeklyDays.length,
      monthlyDaysCount: monthlyDays.length,
    );
    setState(() => quantityController.text = qty);
  }

  void _submit() {
    if (!_validate()) return;

    final item = MedicationItemEntity(
      medicationName: nameController.text.trim(),
      dosage: dosageController.text.trim(),
      frequency: MedicationLogicHelper.generateSummary(
        frequencyType: frequencyType,
        selectedStartDate: selectedStartDate,
        weeklyDaysCount: weeklyDays.length,
        monthlyDaysCount: monthlyDays.length,
        intervalHours: intervalHours,
      ),
      duration:
          frequencyType == 0
              ? "1 day"
              : "${durationValueController.text} ${durationType.toLowerCase()}",
      quantity: int.parse(quantityController.text),
      instructions:
          instructionsController.text.isEmpty
              ? "No instructions"
              : instructionsController.text,
      reminderFrequencyType: frequencyType,
      reminderStartDate: selectedStartDate,
      reminderDailyDoseTimes: dailyTimes,
      reminderWeeklyDays: frequencyType == 2 ? weeklyDays : null,
      reminderEndDate:
          durationType == "Ongoing"
              ? null
              : selectedStartDate.add(
                Duration(
                  days: MedicationLogicHelper.calculateDurationInDays(
                    int.tryParse(durationValueController.text) ?? 1,
                    durationType,
                  ),
                ),
              ),
    );

    widget.onAdd(item);
    Navigator.pop(context);
  }

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

  Widget _buildIntervalInput() {
    return Row(
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
        _buildTimeLabel(
          "Starting at",
          child: ReminderTimeSelector(
            times: dailyTimes,
            onPickTime: (i) => _pickTime(index: i),
            onDelete: (i) => {},
            onAddTime: () {},
            showAddButton: false,
          ),
        ),
      ],
    );
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
      decoration: InputDecoration(
        labelText: label,
        prefixIcon:
            icon != null ? Icon(icon, color: const Color(0xFF9333EA)) : null,
        errorText: error,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
    ),
  );

  Widget _buildTimeLabel(String label, {required Widget child}) => Column(
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
      child,
    ],
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
  Widget _buildSectionTitle(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 10),
    child: Text(
      t,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 13,
        color: Colors.grey[600],
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
  Widget _buildAutoCalcButton() => ElevatedButton.icon(
    onPressed: _autoCalculateQty,
    icon: const Icon(Icons.calculate, size: 16),
    label: const Text("Auto"),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue[50],
      foregroundColor: Colors.blue,
      elevation: 0,
    ),
  );
  Widget _buildSubmitButton() => ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF9333EA),
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 55),
    ),
    onPressed: _submit,
    child: const Text(
      "Add to Prescription",
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
  );
  Widget _buildStartDatePicker() => InkWell(
    onTap: () async {
      DateTime? d = await showDatePicker(
        context: context,
        initialDate: selectedStartDate,
        firstDate: DateTime.now().subtract(const Duration(days: 30)),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      );
      if (d != null) setState(() => selectedStartDate = d);
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
  bool _validate() {
    setState(() {
      nameError = nameController.text.isEmpty ? "Required" : null;
      dosageError = dosageController.text.isEmpty ? "Required" : null;
      quantityError =
          (int.tryParse(quantityController.text) ?? 0) <= 0 ? "Invalid" : null;
    });
    return nameError == null && dosageError == null && quantityError == null;
  }
}
