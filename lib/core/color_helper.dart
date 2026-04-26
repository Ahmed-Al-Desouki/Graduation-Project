// core/utils/color_helper.dart

import 'package:flutter/material.dart';

Color getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'open':
      return Colors.blue.shade700;
    case 'inprogress':
      return Colors.amber.shade800;
    case 'resolved':
      return Colors.green.shade700;
    case 'closed':
      return Colors.grey.shade600;
    default:
      return Colors.blueGrey;
  }
}

Color getPriorityColor(String priority) {
  switch (priority.toLowerCase()) {
    case 'urgent':
      return Colors.red.shade700;
    case 'high':
      return Colors.orange.shade700;
    case 'normal':
      return Colors.blue.shade600;
    case 'low':
      return Colors.teal.shade600;
    default:
      return Colors.grey;
  }
}
