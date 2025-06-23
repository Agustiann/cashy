import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cashy/features/financial_report/data/models/report_model.dart';

class ReportRemoteDatasource {
  final SupabaseClient supabaseClient;

  ReportRemoteDatasource(this.supabaseClient);

  Future<List<String>> getTransactionTypes() async {
    final response = await supabaseClient
        .rpc('get_enum_values', params: {'enum_type': 'transaction_type'});

    final List<dynamic> data = response;

    if (data.isEmpty) {
      return [];
    }

    return data.map((item) {
      final enumLabel = item['enum_label'] as String;

      if (enumLabel == 'income') {
        return 'Pemasukan';
      } else if (enumLabel == 'expense') {
        return 'Pengeluaran';
      } else if (enumLabel == 'Semua tipe') {
        return 'Semua tipe';
      } else {
        return enumLabel;
      }
    }).toList();
  }

  Future<List<ReportModel>> getMonthlyReport(String month, String year) async {
    final intMonth = int.parse(month);
    final intYear = int.parse(year);
    final startDate = DateTime(intYear, intMonth, 1);
    final endDate = DateTime(intYear, intMonth + 1, 1);

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await supabaseClient
        .from('transactions')
        .select('amount, type, category, date')
        .eq('user_id', userId) // Filter sesuai user login
        .gte('date', startDate.toIso8601String())
        .lt('date', endDate.toIso8601String())
        .order('date', ascending: true)
        .limit(100);

    final data = response as List<dynamic>?;

    if (data == null || data.isEmpty) {
      return [];
    }

    return data
        .map((item) => ReportModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<ReportModel>> getYearlyReport(String year) async {
    final intYear = int.parse(year);
    final startDate = DateTime(intYear, 1, 1);
    final endDate = DateTime(intYear + 1, 1, 1);

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await supabaseClient
        .from('transactions')
        .select('amount, type, category, date')
        .eq('user_id', userId) // Filter sesuai user login
        .gte('date', startDate.toIso8601String())
        .lt('date', endDate.toIso8601String())
        .order('date', ascending: true)
        .limit(100);

    final data = response as List<dynamic>?;

    if (data == null || data.isEmpty) {
      return [];
    }

    return data
        .map((item) => ReportModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<ReportModel>> getReportsThisYearUntilNow() async {
    final now = DateTime.now();
    final startDate = DateTime(now.year, 1, 1);
    final endDate = DateTime(now.year, now.month + 1, 1);

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await supabaseClient
        .from('transactions')
        .select('amount, type, category, date')
        .eq('user_id', userId) // Filter sesuai user login
        .gte('date', startDate.toIso8601String())
        .lt('date', endDate.toIso8601String())
        .order('date', ascending: true)
        .limit(1000);

    final data = response as List<dynamic>?;

    if (data == null || data.isEmpty) {
      return [];
    }

    return data
        .map((item) => ReportModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
