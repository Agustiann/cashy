import '../../domain/entities/pos_entity.dart';

abstract class PosState {}

class PosInitial extends PosState {}

class PosLoading extends PosState {}

class PosLoaded extends PosState {
  final PosEntity data;

  PosLoaded(this.data);
}

class PosError extends PosState {
  final String message;

  PosError(this.message);
}
