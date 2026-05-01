import 'package:intl/intl.dart';

class MedicationLogicHelper {
  // 1. ميثود حساب الكمية الكلية
  static String calculateQuantity({
    required int durationValue,
    required String durationType,
    required int frequencyType,
    required int dosesPerDay,
    required int intervalHours,
    required int weeklyDaysCount,
    required int monthlyDaysCount,
  }) {
    double days = 0;
    if (durationType == "Days") {
      days = durationValue.toDouble();
    } else if (durationType == "Weeks") {
      days = durationValue * 7.0;
    } else if (durationType == "Months") {
      days = durationValue * 30.0;
    } else {
      days = 30.0; // الافتراضي للـ Ongoing
    }

    double calculatedQty = 0;

    switch (frequencyType) {
      case 0: // Once
        calculatedQty = dosesPerDay.toDouble();
        break;
      case 1: // Daily
        calculatedQty = days * dosesPerDay;
        break;
      case 2: // Weekly
        calculatedQty =
            (days / 7) *
            (weeklyDaysCount == 0 ? 1 : weeklyDaysCount) *
            dosesPerDay;
        break;
      case 3: // Monthly
        calculatedQty =
            (days / 30) *
            (monthlyDaysCount == 0 ? 1 : monthlyDaysCount) *
            dosesPerDay;
        break;
      case 4: // Every X Hours
        calculatedQty = days * (24 / intervalHours);
        break;
    }
    return calculatedQty.ceil().toString();
  }

  // 2. ميثود توليد ملخص التردد
  static String generateSummary({
    required int frequencyType,
    required DateTime selectedStartDate,
    required int weeklyDaysCount,
    required int monthlyDaysCount,
    required int intervalHours,
  }) {
    if (frequencyType == 0)
      return "Once on ${DateFormat('MMM dd').format(selectedStartDate)}";
    if (frequencyType == 1) return "Daily";
    if (frequencyType == 2) return "$weeklyDaysCount days/week";
    if (frequencyType == 3) return "$monthlyDaysCount days/month";
    return "Every $intervalHours hours";
  }

  // 3. ميثود حساب مدة العلاج بالأيام
  static int calculateDurationInDays(int val, String type) {
    if (type == "Weeks") return val * 7;
    if (type == "Months") return val * 30;
    return val;
  }
}
