import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/home_entity.dart';
import '../../domain/usecases/get_budget_summary.dart';
import '../../domain/usecases/get_transaction.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetTransactionsByDate getTransactionsByDate;
  final GetBudgetSummary getBudgetSummary;

  HomeBloc({
    required this.getTransactionsByDate,
    required this.getBudgetSummary,
  }) : super(HomeInitial()) {
    on<LoadHomeData>((event, emit) async {
      emit(HomeLoading());
      try {
        final transactions = await getTransactionsByDate(event.userId, event.selectedDate);
        final summary = await getBudgetSummary(event.userId, event.selectedDate);

        emit(HomeLoaded(
          transactions: transactions,
          totalIncome: summary['total_income']!,
          totalExpense: summary['total_expense']!,
        ));
      } catch (e) {
        emit(HomeError("Failed to load data"));
      }
    });
  }
}
