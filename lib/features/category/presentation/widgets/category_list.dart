import 'package:flutter/material.dart';
import '../../domain/entities/category_entity.dart';

class CategoryList extends StatelessWidget {
  final List<Category> categories;
  final void Function(Category) onEdit;
  final void Function(String) onDelete;

  const CategoryList({
    super.key,
    required this.categories,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        bool isEditable =
            !(cat.name == 'Bayar Kos' || cat.name == 'Biaya Kuliah');

        return Card(
          color: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          shadowColor: Colors.grey.withAlpha(77),
          child: ListTile(
            leading: Icon(
              cat.type == 'expense' ? Icons.upload : Icons.download,
              color: cat.type == 'expense' ? Colors.red : Colors.green,
            ),
            title: Text(cat.name),
            trailing: isEditable
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          icon: Icon(Icons.edit), onPressed: () => onEdit(cat)),
                      IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => onDelete(cat.id)),
                    ],
                  )
                : null,
          ),
        );
      },
    );
  }
}
