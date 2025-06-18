import 'package:cashy/features/financial_report/domain/entities/report_entity.dart';
import 'package:cashy/features/financial_report/domain/repositories/report_repository.dart';

class ReportUseCase {
  final ReportRepository repository;

  ReportUseCase(this.repository);

  Future<List<ReportEntity>> getMonthlyReport(String month, String year) {
    return repository.getMonthlyReport(month, year);
  }

  Future<List<ReportEntity>> getYearlyReport(String year) {
    return repository.getYearlyReport(year);
  }

  Future<List<ReportEntity>> getReportsThisYearUntilNow() {
    return repository.getReportsThisYearUntilNow();
  }
}
