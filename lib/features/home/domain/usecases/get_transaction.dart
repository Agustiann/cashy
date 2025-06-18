import '../entities/home_entity.dart';
import '../repositories/home_repository.dart';

class GetTransactionsByDate {
  final HomeRepository repository;

  GetTransactionsByDate(this.repository);

  Future<List<TransactionEntity>> call(String userId, DateTime date) {
    return repository.getTransactionsByDate(userId, date);
  }
}
