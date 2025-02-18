import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../books_state.dart';
import 'category_add_dialog.dart';
import 'category_edit_dialog.dart';

class CategoryManageScreen extends StatefulWidget {
  const CategoryManageScreen({super.key});

  @override
  State<CategoryManageScreen> createState() => _CategoryManageScreenState();
}

class _CategoryManageScreenState extends State<CategoryManageScreen> {
  void _showDeleteCategoryDialog(BuildContext context, int categoryId) {
    final booksState = context.read<BooksState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          iconColor: Theme.of(context).colorScheme.error,
          surfaceTintColor: Theme.of(context).colorScheme.error,
          icon: const Icon(Icons.delete),
          title: const Text('删除分组'),
          content: const Text('删除分组后，分组内的书籍将会被移动到默认分组。'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
            ),
            FilledButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.error,
                ),
              ),
              onPressed: () {
                booksState.removeCategory(categoryId);
                Navigator.of(context).pop();
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final booksState = context.watch<BooksState>();

    final reservedCategoryNameColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('分组管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              var newCategory = await showCategoryAddDialog(
                  context, booksState.nextCategoryId);
              if (newCategory != null) {
                newCategory = newCategory.copyWith(index: booksState.categories.length);
                booksState.addCategory(newCategory);
              }
            },
          ),
        ],
      ),
      body: ReorderableListView(
        children: [
          for (final category in booksState.sortedCategories)
            Builder(
              key: ValueKey(category.id),
              builder: (context) {
                final errorColor = Theme.of(context).colorScheme.error;

                return ListTile(
                  title: booksState.reservedCategoryIds.contains(category.id)
                      ? Row(
                          children: [
                            Text(category.name),
                            const SizedBox(width: 8),
                            Text(
                              booksState.reservedCategories[category.id]!.name,
                              style: TextStyle(color: reservedCategoryNameColor),
                            ),
                          ],
                        )
                      : Text(category.name),
                  leading: ReorderableDragStartListener(
                    index: category.index,
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.drag_indicator),
                    ),
                  ),
                  trailing: booksState.reservedCategoryIds.contains(category.id)
                      ? null
                      : IconButton(
                          onPressed: () {
                            _showDeleteCategoryDialog(context, category.id);
                          },
                          icon: const Icon(Icons.delete),
                          color: errorColor,
                        ),
                  onTap: () async {
                    final newCategory =
                        await showCategoryEditDialog(context, category);
                    if (newCategory != null) {
                      booksState.updateCategory(newCategory);
                    }
                  },
                );
              },
            ),
        ],
        onReorder: (oldIndex, newIndex) {
          booksState.reorderCategory(oldIndex, newIndex);
        },
      ),
    );
  }
}
