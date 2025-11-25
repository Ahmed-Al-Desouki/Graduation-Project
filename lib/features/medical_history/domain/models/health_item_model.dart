enum HealthType { condition, allergy }

class HealthItem {
  final String name;
  final HealthType type;

  HealthItem({required this.name, required this.type});
}
