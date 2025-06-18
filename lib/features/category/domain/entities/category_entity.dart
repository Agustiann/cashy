import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String type; // 'income' or 'expense'

  const Category({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
  });

  @override
  List<Object> get props => [id, userId, name, type];
}
