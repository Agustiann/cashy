// 📁 data/datasources/home_remote_datasource.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/home_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<TransactionModel>> getTransactions(String userId, DateTime date);
  Future<Map<String, double>> getBudgetSummaryByDate(
      String userId, DateTime date);
  Future<Map<String, double>> getExpenseDistributionBySource(
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
        .eq('date', formattedDate);

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

  @override
  Future<Map<String, double>> getExpenseDistributionBySource(
      String userId, DateTime date) async {
    final month = date.month;
    final year = date.year;

    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);

    final response = await client
        .from('transactions')
        .select('amount, source')
        .eq('user_id', userId)
        .eq('type', 'expense')
        .gte('date', startDate.toIso8601String().split('T').first)
        .lte('date', endDate.toIso8601String().split('T').first);

    double total = 0;
    final Map<String, double> sourceTotals = {
      'needs': 0,
      'wants': 0,
      'savings': 0,
    };

    for (final item in response as List) {
      final amount = double.tryParse(item['amount'].toString()) ?? 0;
      final source = item['source'];
      if (sourceTotals.containsKey(source)) {
        sourceTotals[source] = sourceTotals[source]! + amount;
        total += amount;
      }
    }

    if (total > 0) {
      return sourceTotals.map((key, value) =>
          MapEntry(key, double.parse(((value / total) * 100).toStringAsFixed(2))));
    } else {
      return sourceTotals.map((key, value) => MapEntry(key, 0.0));
    }
  }
}
