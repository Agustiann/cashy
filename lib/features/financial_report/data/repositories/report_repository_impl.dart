import 'package:cashy/features/financial_report/data/datasources/report_remote_datasource.dart';
import 'package:cashy/features/financial_report/domain/entities/report_entity.dart';
import 'package:cashy/features/financial_report/domain/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDatasource remoteDatasource;

  ReportRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<ReportEntity>> getMonthlyReport(String month, String year) async {
    final reportModels = await remoteDatasource.getMonthlyReport(month, year);
    return reportModels.map((model) => ReportEntity.fromModel(model)).toList();
  }

  @override
  Future<List<ReportEntity>> getYearlyReport(String year) async {
    final reportModels = await remoteDatasource.getYearlyReport(year);
    return reportModels.map((model) => ReportEntity.fromModel(model)).toList();
  }

  @override
  Future<List<ReportEntity>> getReportsThisYearUntilNow() async {
    final reportModels = await remoteDatasource.getReportsThisYearUntilNow();
    return reportModels.map((model) => ReportEntity.fromModel(model)).toList();
  }
}
