import '../entities/home_entity.dart';

abstract class HomeRepository {
  Future<List<TransactionEntity>> getTransactionsByDate(String userId, DateTime date);
  Future<Map<String, double>> getBudgetSummaryByDate(String userId, DateTime date);
}
