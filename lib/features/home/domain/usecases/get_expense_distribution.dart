import '../repositories/home_repository.dart';

class GetExpenseDistribution {
  final HomeRepository repository;

  GetExpenseDistribution(this.repository);

  Future<Map<String, double>> call(String userId, DateTime date) {
    return repository.getExpenseDistributionBySource(userId, date);
  }
}