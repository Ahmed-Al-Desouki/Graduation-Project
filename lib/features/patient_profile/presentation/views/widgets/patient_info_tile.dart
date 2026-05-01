import 'package:flutter/material.dart';

class PatientInfoTile extends StatelessWidget {
  final IconData? icon;
  final Color iconColor;
  final String label;
  final String value;
  const PatientInfoTile({
    super.key,
    this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 30, child: Icon(icon, color: iconColor, size: 22)),
          const SizedBox(width: 15),

          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ),

          const Text(' : ', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),

          Expanded(
            flex: 5,
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
