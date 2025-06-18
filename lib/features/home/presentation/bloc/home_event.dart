
part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadHomeData extends HomeEvent {
  final String userId;
  final DateTime selectedDate;

  LoadHomeData({required this.userId, required this.selectedDate});

  @override
  List<Object?> get props => [userId, selectedDate];
}
