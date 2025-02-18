import 'package:flutter/material.dart';

import 'browse_page_state.dart';

enum _ImportState {
  normal,
  importing,
  imported,
  error,
}

class ImportBookDialog extends StatefulWidget {
  const ImportBookDialog({
    super.key,
    required this.explorePageState,
  });

  final BrowsePageState explorePageState;

  @override
  State<ImportBookDialog> createState() => _ImportBookDialogState();
}


class _ImportBookDialogState extends State<ImportBookDialog> {
  _ImportState state = _ImportState.normal;
  String? error;

  BrowsePageState get explorePageState => widget.explorePageState;

  void importBook() async {
    setState(() {
      state = _ImportState.importing;
    });

    try {
      await widget.explorePageState.importSelected();
      setState(() {
        state = _ImportState.imported;
      });
    } catch (e) {
      setState(() {
        state = _ImportState.error;
        error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> actions;
    final Widget title;
    final Widget icon;

    if (state == _ImportState.normal) {
      icon = Icon(Icons.add_chart);
      title = Text('确定添加书籍 ${explorePageState.selectedEntities.length}');
      actions = [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('取消'),
        ),
        FilledButton(
          onPressed: () {
            importBook();
          },
          child: Text('添加'),
        ),
      ];
    } else if (state == _ImportState.importing) {
      icon = Icon(Icons.add_chart);
      title = Text('正在添加书籍 ${explorePageState.selectedEntities.length}');
      actions = [
        FilledButton(
          onPressed: null,
          child: Container(
            width: 24,
            height: 24,
            padding: const EdgeInsets.all(2.0),
            child: const CircularProgressIndicator(
              strokeWidth: 3,
            ),
          ),
        ),
      ];
    } else if (state == _ImportState.imported) {
      icon = Icon(Icons.done_all);
      title = Text('添加书籍成功');
      actions = [
        TextButton(
          onPressed: () {
            explorePageState.exitSelecting();
            Navigator.of(context).pop();
          },
          child: Text('确定'),
        ),
      ];
    } else {
      icon = Icon(Icons.error);
      title = Text('添加书籍失败');
      actions = [];
    }

    return AlertDialog(
      icon: icon,
      title: title,
      actions: actions,
      content: SingleChildScrollView(
        child: Column(
          children: [
            for (final entity in explorePageState.selectedEntities)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(entity.name),
              ),
          ],
        ),
      ),
    );
  }
}