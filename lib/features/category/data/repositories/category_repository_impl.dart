import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_datasource.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource;

  CategoryRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Category>> getCategories(String userId, String type) {
    return remoteDataSource.getCategories(userId, type);
  }

  @override
  Future<void> addCategory(Category category) {
    return remoteDataSource.addCategory(CategoryModel(
      id: category.id,
      userId: category.userId,
      name: category.name,
      type: category.type,
    ));
  }

  @override
  Future<void> deleteCategory(String id) {
    return remoteDataSource.deleteCategory(id);
  }

  @override
  Future<void> updateCategory(Category category) {
    return remoteDataSource.updateCategory(CategoryModel(
      id: category.id,
      userId: category.userId,
      name: category.name,
      type: category.type,
    ));
  }
}
