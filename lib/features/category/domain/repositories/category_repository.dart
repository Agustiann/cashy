import '../entities/category_entity.dart';

abstract class CategoryRepository {
  Future<List<Category>> getCategories(String userId, String type);
  Future<void> addCategory(Category category);
  Future<void> deleteCategory(String id);
  Future<void> updateCategory(Category category);
}
