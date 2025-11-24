import 'package:flutter/material.dart';

class InfoCardWidget extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isHighlighted;

  const InfoCardWidget({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool isSmallScreen = screenWidth < 380;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isSmallScreen ? 12 : 16,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: isHighlighted ? const Color(0xFFEFF6FF) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlighted ? const Color(0xFFBFDBFE) : Colors.grey.shade200,
        ),
        boxShadow:
            isHighlighted
                ? []
                : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color:
                isHighlighted ? const Color(0xFF2563EB) : Colors.grey.shade600,
            size: isSmallScreen ? 20 : 24,
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Text(
            label,
            style: TextStyle(
              fontSize: isSmallScreen ? 11 : 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: isHighlighted ? const Color(0xFF1E40AF) : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
