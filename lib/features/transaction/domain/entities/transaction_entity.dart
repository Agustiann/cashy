import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final String? id;
  final String userId;
  final double amount;
  final String type;
  final String category;
  final String? note;
  final DateTime date;
  final String? source;

  const TransactionEntity({
    this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.category,
    this.note,
    required this.date,
    this.source,
  });

  @override
  List<Object?> get props =>
      [id, userId, amount, type, category, note, date, source];
}
