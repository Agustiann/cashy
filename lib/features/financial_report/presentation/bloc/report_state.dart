import 'package:cashy/features/financial_report/domain/entities/report_entity.dart';

abstract class ReportState {}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class ReportLoaded extends ReportState {
  final List<ReportEntity> report;

  ReportLoaded(this.report);
}

class ReportError extends ReportState {
  final String message;

  ReportError(this.message);
}
