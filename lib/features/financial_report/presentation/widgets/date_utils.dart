List<String> getYears({int startYear = 2025}) {
  final now = DateTime.now();
  int currentYear = now.year;
  return List.generate(currentYear - startYear + 1, (index) => (startYear + index).toString());
}
