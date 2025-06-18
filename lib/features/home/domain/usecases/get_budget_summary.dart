import '../repositories/home_repository.dart';

class GetBudgetSummary {
  final HomeRepository repository;

  GetBudgetSummary(this.repository);

  Future<Map<String, double>> call(String userId, DateTime date) {
    return repository.getBudgetSummaryByDate(userId, date);
  }
}
