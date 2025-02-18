import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../settings_state.dart';
import '../../../managers/meta/models.dart';
import '../../common/image.dart';

class BookTile extends StatelessWidget {
  const BookTile({
    super.key,
    required this.book,
    required this.onRead,
    required this.onDetail,
  });

  final ExtendedBookInfo book;
  final Function(ExtendedBookInfo book) onRead;
  final Function(ExtendedBookInfo book) onDetail;

  Widget _buildMeta(BuildContext context, IconData icon, String content) {
    return Row(
      children: [
        Icon(
          icon,
          size: 12,
          color: Theme.of(context).iconTheme.color,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            content,
            style: Theme.of(context).textTheme.labelMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = book.titles.firstOrNull ?? "未知书名";
    final author = book.authors.isNotEmpty ? book.authors.join(' ') : "未知作者";
    return Selector<SettingsState, String?>(
      selector: (context, settingsState) => settingsState.rootPath,
      builder: (context, rootPath, _) {
        return InkWell(
          onTap: () {
            onRead(book);
          },
          onLongPress: () {
            onDetail(book);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 90,
                  height: 130,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: book.coverRelativePath != null && rootPath != null
                      ? CustomImageWidget.custom(
                          rootPath,
                          book.coverRelativePath!,
                          fit: BoxFit.fill,
                        )
                      : Image.asset('assets/images/cover.png',
                          fit: BoxFit.fill),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      _buildMeta(context, Icons.account_circle, author),
                      const SizedBox(height: 4),
                      _buildMeta(
                          context, Icons.file_present, book.relativePath),
                      const SizedBox(height: 4),
                      _buildMeta(context, Icons.schedule, book.lastReadTitle),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
