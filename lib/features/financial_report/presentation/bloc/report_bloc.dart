import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashy/features/financial_report/domain/usecases/report_usecase.dart';
import 'package:cashy/features/financial_report/presentation/bloc/report_event.dart';
import 'package:cashy/features/financial_report/presentation/bloc/report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final ReportUseCase reportUseCase;

  ReportBloc(this.reportUseCase) : super(ReportInitial()) {
    on<FetchMonthlyReport>(_onFetchMonthlyReport);
    on<FetchYearlyReport>(_onFetchYearlyReport);
    on<FetchReportsThisYearUntilNow>(_onFetchReportsThisYearUntilNow);
  }

  Future<void> _onFetchMonthlyReport(
      FetchMonthlyReport event, Emitter<ReportState> emit) async {
    emit(ReportLoading());
    try {
      final report =
          await reportUseCase.getMonthlyReport(event.month, event.year);
      emit(ReportLoaded(report));
    } catch (e) {
      emit(ReportError('Failed to load monthly report'));
    }
  }

  Future<void> _onFetchYearlyReport(
      FetchYearlyReport event, Emitter<ReportState> emit) async {
    emit(ReportLoading());
    try {
      final report = await reportUseCase.getYearlyReport(event.year);
      emit(ReportLoaded(report));
    } catch (e) {
      emit(ReportError('Failed to load yearly report'));
    }
  }

  Future<void> _onFetchReportsThisYearUntilNow(
      FetchReportsThisYearUntilNow event, Emitter<ReportState> emit) async {
    emit(ReportLoading());
    try {
      final report = await reportUseCase.getReportsThisYearUntilNow();
      emit(ReportLoaded(report));
    } catch (e) {
      emit(ReportError('Failed to load partial-year report'));
    }
  }
}
