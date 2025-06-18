part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<TransactionEntity> transactions;
  final double totalIncome;
  final double totalExpense;

  HomeLoaded({
    required this.transactions,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  List<Object?> get props => [transactions, totalIncome, totalExpense];
}

class HomeError extends HomeState {
  final String message;

  HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
