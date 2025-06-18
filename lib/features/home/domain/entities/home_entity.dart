class TransactionEntity {
  final String id;
  final double amount;
  final String type;
  final String category;
  final String? note;
  final DateTime createdAt;

  TransactionEntity({
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.note,
    required this.createdAt,
  });
}
