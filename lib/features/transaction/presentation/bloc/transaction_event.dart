abstract class TransactionEvent {}

class LoadSources extends TransactionEvent {}

class AddNewTransaction extends TransactionEvent {
  final String userId;
  final double amount;
  final String category;
  final DateTime date;
  final String note;
  final String? source;

  AddNewTransaction({
    required this.userId,
    required this.amount,
    required this.category,
    required this.date,
    required this.note,
    this.source
  });
}
