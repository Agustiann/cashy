import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/home_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<TransactionModel>> getTransactions(String userId, DateTime date);
  Future<Map<String, double>> getBudgetSummaryByDate(
      String userId, DateTime date);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final SupabaseClient client;

  HomeRemoteDataSourceImpl(this.client);

  @override
  Future<List<TransactionModel>> getTransactions(
      String userId, DateTime date) async {
    final response = await client
        .from('transactions')
        .select()
        .eq('user_id', userId)
        .eq('date', date.toIso8601String().split('T')[0])
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => TransactionModel.fromJson(json))
        .toList();
  }

  @override
  Future<Map<String, double>> getBudgetSummaryByDate(
      String userId, DateTime date) async {
    final formattedDate = date.toIso8601String().split('T')[0];

    final response = await client
        .from('transactions')
        .select()
        .eq('user_id', userId)
        .eq('date', formattedDate); // pastikan field ini ada di DB

    double totalIncome = 0;
    double totalExpense = 0;

    for (final item in response as List) {
      final amount = double.tryParse(item['amount'].toString()) ?? 0;
      if (item['type'] == 'income') {
        totalIncome += amount;
      } else if (item['type'] == 'expense') {
        totalExpense += amount;
      }
    }

    return {
      'total_income': totalIncome,
      'total_expense': totalExpense,
    };
  }
}
