import '../../domain/entities/home_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<TransactionEntity>> getTransactionsByDate(
      String userId, DateTime date) {
    return remoteDataSource.getTransactions(userId, date);
  }

  @override
  Future<Map<String, double>> getBudgetSummaryByDate(
      String userId, DateTime date) {
    return remoteDataSource.getBudgetSummaryByDate(userId, date);
  }

  @override
  Future<Map<String, double>> getExpenseDistributionBySource(
      String userId, DateTime date) {
    return remoteDataSource.getExpenseDistributionBySource(userId, date);
  }
}
