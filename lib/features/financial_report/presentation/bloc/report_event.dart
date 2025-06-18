abstract class ReportEvent {}

class FetchMonthlyReport extends ReportEvent {
  final String month;
  final String year;

  FetchMonthlyReport(this.month, this.year);
}

class FetchYearlyReport extends ReportEvent {
  final String year;

  FetchYearlyReport(this.year);
}

class FetchReportsThisYearUntilNow extends ReportEvent {}

