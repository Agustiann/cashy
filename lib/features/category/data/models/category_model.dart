import '../../domain/entities/category_entity.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.type,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type,
    };
  }
}
