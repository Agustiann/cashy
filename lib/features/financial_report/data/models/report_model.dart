class ReportModel {
  final double amount;
  final String type;
  final String category;
  final DateTime date;

  ReportModel({
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      amount: json['amount']?.toDouble() ?? 0.0,
      type: json['type'] ?? '',
      category: json['category'] ?? '',
      date: DateTime.parse(json['date']),
    );
  }
}
