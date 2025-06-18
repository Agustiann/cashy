import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  TransactionModel({
    String? id,
    required String userId,
    required double amount,
    required String type,
    required String category,
    String? note,
    required DateTime date,
    String? source,
  }) : super(
          id: id,
          userId: userId,
          amount: amount,
          type: type,
          category: category,
          note: note,
          date: date,
          source: source,
        );

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      userId: json['user_id'],
      amount: (json['amount'] as num).toDouble(),
      type: json['type'],
      category: json['category'],
      note: json['note'],
      date: DateTime.parse(json['date']),
      source: json['source'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'type': type,
      'category': category,
      'note': note,
      'date': date.toIso8601String(),
      'source': source,
    };
  }
}
