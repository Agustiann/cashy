import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/transaction_entity.dart';

abstract class TransactionRemoteDataSource {
  Future<void> addTransaction(TransactionEntity transaction);
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final SupabaseClient client;

  TransactionRemoteDataSourceImpl(this.client);

  @override
  Future<void> addTransaction(TransactionEntity transaction) async {
    final userId = transaction.userId;
    final amount = transaction.amount;
    final date = transaction.date;
    final category = transaction.category;
    final note = transaction.note;
    final type = transaction.type;
    final source = transaction.source;

    try {
      final _ = await client.from('transactions').insert({
        'user_id': userId,
        'amount': amount,
        'type': type,
        'category': category,
        'note': note,
        'date': date.toIso8601String(),
        if (source != null) 'source': source,
      }).select();

      final month = date.month;
      final year = date.year;

      final budgetData = await client
          .from('budget_allocation')
          .select()
          .eq('user_id', userId)
          .eq('month', month)
          .eq('year', year)
          .maybeSingle();

      if (type == 'income') {
        final needs = amount * 0.5;
        final wants = amount * 0.3;
        final savings = amount * 0.2;

        if (budgetData == null) {
          await client.from('budget_allocation').insert({
            'user_id': userId,
            'month': month,
            'year': year,
            'needs': needs,
            'wants': wants,
            'savings': savings,
            'total_income': amount,
          });
        } else {
          final updatedNeeds = (budgetData['needs'] ?? 0) + needs;
          final updatedWants = (budgetData['wants'] ?? 0) + wants;
          final updatedSavings = (budgetData['savings'] ?? 0) + savings;
          final updatedIncome = (budgetData['total_income'] ?? 0) + amount;

          await client
              .from('budget_allocation')
              .update({
                'needs': updatedNeeds,
                'wants': updatedWants,
                'savings': updatedSavings,
                'total_income': updatedIncome,
              })
              .eq('user_id', userId)
              .eq('month', month)
              .eq('year', year);
        }
      } else if (type == 'expense') {
        if (budgetData == null) {
          throw Exception("Data alokasi tidak ditemukan untuk bulan ini");
        }

        if (source == null) {
          throw Exception("Source harus diisi untuk pengeluaran");
        }

        final currentSourceValue = (budgetData[source] ?? 0) as num;

        if (currentSourceValue < amount) {
          throw Exception("Dana ${source} tidak cukup");
        }

        final updatedSourceValue = currentSourceValue - amount;

        await client
            .from('budget_allocation')
            .update(<String, dynamic>{
              source: updatedSourceValue,
            })
            .eq('user_id', userId)
            .eq('month', month)
            .eq('year', year);
      }
    } catch (e) {
      throw Exception('Gagal menyimpan transaksi: ${e.toString()}');
    }
  }
}
