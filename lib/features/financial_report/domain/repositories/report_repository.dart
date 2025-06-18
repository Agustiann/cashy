import 'package:cashy/features/financial_report/domain/entities/report_entity.dart';

abstract class ReportRepository {
  Future<List<ReportEntity>> getMonthlyReport(String month, String year);
  Future<List<ReportEntity>> getYearlyReport(String year);
  Future<List<ReportEntity>> getReportsThisYearUntilNow();
}
