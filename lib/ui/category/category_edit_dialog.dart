import 'package:flutter/material.dart';

import '../../managers/meta/models.dart';

class CategoryEditDialog extends StatefulWidget {
  const CategoryEditDialog({
    super.key,
    required this.category,
  });

  final BookCategory category;

  @override
  State<CategoryEditDialog> createState() => _CategoryEditDialogState();
}

class _CategoryEditDialogState extends State<CategoryEditDialog> {
  late BookCategory category;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    category = widget.category;
    _controller = TextEditingController(text: category.name);
  }

  @override
  void didUpdateWidget(covariant CategoryEditDialog oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.category != widget.category) {
      _controller.text = category.name;
      category = widget.category;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.edit),
      title: const Text('编辑分组'),
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

Future<BookCategory?> showCategoryEditDialog(
  BuildContext context,
  BookCategory category,
) async {
  return showDialog<BookCategory>(
    context: context,
    builder: (context) {
      return CategoryEditDialog(category: category);
    },
  );
}
