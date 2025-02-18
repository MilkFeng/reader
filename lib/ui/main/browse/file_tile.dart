import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';

import '../../../common/fs_utils.dart';
import '../../../settings_state.dart';

class FileTile extends StatelessWidget {
  const FileTile({
    super.key,
    required this.entity,
    required this.selecting,
    required this.selected,
    required this.imported,
    required this.onClick,
  });

  final Entity entity;

  final bool selecting;
  final bool selected;
  final bool imported;

  final Function(Entity entity) onClick;

  @override
  Widget build(BuildContext context) {
    if (entity.isFile) {
      return ListTile(
        title: Text(entity.name),
        leading: Builder(builder: (context) {
          if (!imported && !selecting) {
            return Icon(Icons.menu_book);
          } else {
            return SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: imported || selected,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
                onChanged: imported
                    ? null
                    : (value) {
                        onClick(entity);
                      },
              ),
            );
          }
        }),
        enabled: !imported,
        selected: selected,
        subtitle: Text("${imported ? '已导入 ' : ''}${filesize(entity.length)}"),
        onTap: () {
          onClick(entity);
        },
      );
    } else {
      final isMeta = entity.relativePath == SettingsState.metaRelativePath;

      return ListTile(
        title: Text(entity.name),
        leading: Icon(Icons.folder),
        subtitle: isMeta ? Text('元数据文件夹') : null,
        enabled: !selecting && !isMeta,
        onTap: () {
          onClick(entity);
        },
      );
    }
  }
}
