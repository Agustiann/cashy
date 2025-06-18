import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/category_usecases.dart';
import '../../domain/usecases/add_category.dart';
import '../../domain/usecases/delete_category.dart';
import '../../domain/usecases/update_category.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetCategories getCategories;
  final AddCategory addCategory;
  final DeleteCategory deleteCategory;
  final UpdateCategory updateCategory;

  CategoryBloc({
    required this.getCategories,
    required this.addCategory,
    required this.deleteCategory,
    required this.updateCategory,
  }) : super(CategoryInitial()) {
    on<LoadCategories>((event, emit) async {
      emit(CategoryLoading());
      try {
        final categories = await getCategories(event.userId, event.type);
        emit(CategoryLoaded(categories));
      } catch (e) {
        emit(CategoryError(e.toString()));
      }
    });

    on<AddCategoryEvent>((event, emit) async {
      try {
        await addCategory(event.category);
        add(LoadCategories(event.category.userId, event.category.type));
      } catch (e) {
        emit(CategoryError(e.toString()));
      }
    });

    on<DeleteCategoryEvent>((event, emit) async {
      try {
        await deleteCategory(event.id);
        add(LoadCategories(event.userId, event.type));
      } catch (e) {
        emit(CategoryError(e.toString()));
      }
    });

    on<UpdateCategoryEvent>((event, emit) async {
      try {
        await updateCategory(event.category);
        add(LoadCategories(event.category.userId, event.category.type));
      } catch (e) {
        emit(CategoryError(e.toString()));
      }
    });
  }
}
