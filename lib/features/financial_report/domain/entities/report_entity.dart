import 'package:cashy/features/financial_report/data/models/report_model.dart';

class ReportEntity {
  final double totalIncome;
  final double totalExpense;
  final DateTime date;

  ReportEntity({
    required this.date,
    required this.totalIncome,
    required this.totalExpense,
  });

  factory ReportEntity.fromModel(ReportModel model) {
    return ReportEntity(
      date: model.date, 
      totalIncome: model.type == 'income' ? model.amount : 0.0,
      totalExpense: model.type == 'expense' ? model.amount : 0.0,
    );
  }
}
