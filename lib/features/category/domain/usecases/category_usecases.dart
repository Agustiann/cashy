import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

class GetCategories {
  final CategoryRepository repository;

  GetCategories(this.repository);

  Future<List<Category>> call(String userId, String type) {
    return repository.getCategories(userId, type);
  }
}
