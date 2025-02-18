import 'package:flutter/material.dart';

import '../../managers/meta/models.dart';

class ChangeBookCategoryDialog extends StatefulWidget {
  const ChangeBookCategoryDialog({
    super.key,
    required this.categories,
    required this.currentCategory,
  });

  final Map<int, BookCategory> categories;
  final int currentCategory;

  @override
  State<ChangeBookCategoryDialog> createState() =>
      _ChangeBookCategoryDialogState();
}

class _ChangeBookCategoryDialogState extends State<ChangeBookCategoryDialog> {
  late int _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.currentCategory;
  }

  @override
  void didUpdateWidget(covariant ChangeBookCategoryDialog oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentCategory != widget.currentCategory ||
        oldWidget.categories != widget.categories) {
      setState(() {
        _selectedCategory = widget.currentCategory;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> categoriesRadioList = widget.categories.entries
        .map((entry) => RadioListTile<int>(
              title: Text(entry.value.name),
              value: entry.key,
              groupValue: _selectedCategory,
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ))
        .toList();

    return AlertDialog(
      icon: const Icon(Icons.category),
      title: const Text('切换分组'),
      content: SingleChildScrollView(
        child: Column(
          children: categoriesRadioList,
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(_selectedCategory);
          },
          child: const Text('确定'),
        ),
      ],
    );
  }
}

Future<int?> showChangeBookCategoryDialog(
  BuildContext context,
  Map<int, BookCategory> categories,
  int currentCategory,
) {
  return showDialog<int>(
    context: context,
    builder: (context) {
      return ChangeBookCategoryDialog(
        categories: categories,
        currentCategory: currentCategory,
      );
    },
  );
}
