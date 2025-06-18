abstract class TransactionState {}

class TransactionInitial extends TransactionState {}

class SourceLoading extends TransactionState {}

class SourceLoaded extends TransactionState {
  final List<String> sources;

  SourceLoaded(this.sources);
}

class SourceError extends TransactionState {
  final String message;

  SourceError(this.message);
}

class TransactionLoading extends TransactionState {}

class TransactionSuccess extends TransactionState {}

class TransactionFailure extends TransactionState {
  final String message;

  TransactionFailure(this.message);
}
