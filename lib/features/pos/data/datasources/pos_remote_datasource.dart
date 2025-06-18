import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pos_model.dart';

abstract class PosRemoteDataSource {
  Future<PosModel?> fetchPosData(String userId);
}

class PosRemoteDataSourceImpl implements PosRemoteDataSource {
  final SupabaseClient client;

  PosRemoteDataSourceImpl(this.client);

  @override
  Future<PosModel?> fetchPosData(String userId) async {
    try {
      final incomeResponse = await client
          .from('transactions')
          .select('amount')
          .eq('user_id', userId)
          .eq('type', 'income');

      final incomeTotal = incomeResponse.fold<double>(
          0, (sum, row) => sum + (row['amount'] as num).toDouble());

      final budgetResponse = await client
          .from('budget_allocation')
          .select('needs, wants, savings')
          .eq('user_id', userId);

      double needsTotal = 0;
      double wantsTotal = 0;
      double savingsTotal = 0;

      for (final row in budgetResponse) {
        needsTotal += (row['needs'] ?? 0).toDouble();
        wantsTotal += (row['wants'] ?? 0).toDouble();
        savingsTotal += (row['savings'] ?? 0).toDouble();
      }

      return PosModel(
        totalIncome: incomeTotal,
        needs: needsTotal,
        wants: wantsTotal,
        savings: savingsTotal,
      );
    } catch (e) {
      throw Exception("Gagal mengambil data POS: ${e.toString()}");
    }
  }
}
