import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories(String userId, String type);
  Future<void> addCategory(CategoryModel category);
  Future<void> deleteCategory(String id);
  Future<void> updateCategory(CategoryModel category);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final SupabaseClient client;

  CategoryRemoteDataSourceImpl(this.client);

  @override
  Future<List<CategoryModel>> getCategories(String userId, String type) async {
    final response = await client
        .from('categories')
        .select()
        .eq('user_id', userId)
        .eq('type', type);

    return (response as List)
        .map((e) => CategoryModel.fromJson(e))
        .toList();
  }

  @override
  Future<void> addCategory(CategoryModel category) async {
    await client.from('categories').insert(category.toJson());
  }

  @override
  Future<void> deleteCategory(String id) async {
    await client.from('categories').delete().eq('id', id);
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    await client
        .from('categories')
        .update(category.toJson())
        .eq('id', category.id);
  }
}
