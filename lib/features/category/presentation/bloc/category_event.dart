import '../../domain/entities/category_entity.dart';

abstract class CategoryEvent {}

class LoadCategories extends CategoryEvent {
  final String userId;
  final String type;

  LoadCategories(this.userId, this.type);
}

class AddCategoryEvent extends CategoryEvent {
  final Category category;

  AddCategoryEvent(this.category);
}

class DeleteCategoryEvent extends CategoryEvent {
  final String id;
  final String userId;
  final String type;

  DeleteCategoryEvent(this.id, this.userId, this.type);
}

class UpdateCategoryEvent extends CategoryEvent {
  final Category category;

  UpdateCategoryEvent(this.category);
}
