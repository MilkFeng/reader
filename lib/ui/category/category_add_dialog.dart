import 'package:flutter/material.dart';

import '../../managers/meta/models.dart';

class CategoryAddDialog extends StatefulWidget {
  const CategoryAddDialog({
    super.key,
    required this.newCategoryId,
  });

  final int newCategoryId;

  @override
  State<CategoryAddDialog> createState() => _CategoryEditDialogState();
}

class _CategoryEditDialogState extends State<CategoryAddDialog> {
  late BookCategory category;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    category = BookCategory(
      id: widget.newCategoryId,
      name: '',
      order: CategoryBooksOrder.lastRead,
      index: 0,
    );
    _controller = TextEditingController(text: category.name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.add),
      title: const Text('添加分组'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: '名称',
              errorText: category.name.isNotEmpty ? null : '名称不能为空',
            ),
            onChanged: (value) {
              setState(() {
                category = category.copyWith(name: value);
              });
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<CategoryBooksOrder>(
            decoration: const InputDecoration(labelText: '排序方式'),
            value: category.order,
            onChanged: (value) {
              setState(() {
                category = category.copyWith(order: value);
              });
            },
            items: CategoryBooksOrder.values
                .map(
                  (order) => DropdownMenuItem(
                    value: order,
                    child: Text(order.name),
                  ),
                )
                .toList(),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: category.name.isNotEmpty
              ? () {
                  Navigator.of(context).pop(category);
                }
              : null,
          child: const Text('确定'),
        ),
      ],
    );
  }
}

Future<BookCategory?> showCategoryAddDialog(
  BuildContext context,
  int newCategoryId,
) async {
  return showDialog<BookCategory>(
    context: context,
    builder: (context) {
      return CategoryAddDialog(newCategoryId: newCategoryId);
    },
  );
}
