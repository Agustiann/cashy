import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/category_entity.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_event.dart';
import '../bloc/category_state.dart';
import '../widgets/category_list.dart';

class CategoryPage extends StatefulWidget {
  final String userId;
  final String type;

  const CategoryPage({super.key, required this.userId, required this.type});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final _nameController = TextEditingController();
  Category? _editingCategory;
  bool isExpense = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    context
        .read<CategoryBloc>()
        .add(LoadCategories(widget.userId, isExpense ? 'expense' : 'income'));
  }

  void _showForm({Category? category}) {
    if (category != null) {
      _editingCategory = category;
      _nameController.text = category.name;
    } else {
      _editingCategory = null;
      _nameController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          category == null
              ? (isExpense ? 'Kategori Pengeluaran' : 'Kategori Pemasukan')
              : 'Edit Kategori',
        ),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Nama Kategori'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              final name = _nameController.text.trim();
              if (name.isNotEmpty) {
                final existingCategories = context.read<CategoryBloc>().state;
                if (existingCategories is CategoryLoaded) {
                  final alreadyExists = existingCategories.categories.any(
                      (cat) => cat.name.toLowerCase() == name.toLowerCase());

                  if (alreadyExists) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Kategori sudah ada')),
                    );
                    return;
                  }
                }

                if (_editingCategory != null) {
                  final updated = Category(
                    id: _editingCategory!.id,
                    userId: widget.userId,
                    name: name,
                    type: isExpense ? 'expense' : 'income',
                  );
                  context
                      .read<CategoryBloc>()
                      .add(UpdateCategoryEvent(updated));
                } else {
                  final newCategory = Category(
                    id: const Uuid().v4(),
                    userId: widget.userId,
                    name: name,
                    type: isExpense ? 'expense' : 'income',
                  );
                  context
                      .read<CategoryBloc>()
                      .add(AddCategoryEvent(newCategory));
                }
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Category category) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: Text('Apakah kamu yakin ingin menghapus "${category.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              context.read<CategoryBloc>().add(DeleteCategoryEvent(
                    category.id,
                    category.userId,
                    category.type,
                  ));
              Navigator.pop(context);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isExpense = false;
                              _loadCategories();
                            });
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: !isExpense ? Colors.green : Colors.white,
                              borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(8)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withAlpha(77),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Pemasukan',
                              style: GoogleFonts.montserrat(
                                color: !isExpense ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isExpense = true;
                              _loadCategories();
                            });
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: isExpense ? Colors.red : Colors.white,
                              borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(8)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withAlpha(77),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Pengeluaran',
                              style: GoogleFonts.montserrat(
                                color: isExpense ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showForm(),
                  icon: const Icon(Icons.add, color: Colors.blue, size: 28),
                )
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, state) {
                if (state is CategoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CategoryLoaded) {
                  if (state.categories.isEmpty) {
                    return const Center(child: Text('Belum ada kategori.'));
                  }
                  return CategoryList(
                    categories: state.categories,
                    onEdit: (cat) => _showForm(category: cat),
                    onDelete: (id) {
                      final cat =
                          state.categories.firstWhere((c) => c.id == id);
                      _confirmDelete(cat);
                    },
                  );
                } else if (state is CategoryError) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}