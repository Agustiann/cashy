import '../../domain/entities/home_entity.dart';

class TransactionModel extends TransactionEntity {
  TransactionModel({
    required super.id,
    required super.amount,
    required super.type,
    required super.category,
    required super.note,
    required super.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      amount: double.parse(json['amount'].toString()),
      type: json['type'],
      category: json['category'],
      note: json['note'],
      createdAt: DateTime.parse(json['created_at']).toLocal(),
    );
  }
}
