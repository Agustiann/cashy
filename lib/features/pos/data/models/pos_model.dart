import '../../domain/entities/pos_entity.dart';

class PosModel extends PosEntity {
  PosModel({
    required double totalIncome,
    required double needs,
    required double wants,
    required double savings,
  }) : super(
          totalIncome: totalIncome,
          needs: needs,
          wants: wants,
          savings: savings,
        );

  factory PosModel.fromMap(Map<String, dynamic> map) {
    return PosModel(
      totalIncome: (map['total_income'] ?? 0).toDouble(),
      needs: (map['needs'] ?? 0).toDouble(),
      wants: (map['wants'] ?? 0).toDouble(),
      savings: (map['savings'] ?? 0).toDouble(),
    );
  }
}
