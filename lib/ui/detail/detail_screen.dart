import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../books_state.dart';
import '../common/image.dart';
import 'change_book_category_dialog.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({
    super.key,
    required this.relativePath,
  });

  final String relativePath;

  Widget _buildMeta(
      BuildContext context, IconData icon, String title, String content) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Row(
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 4),
            Text(title, style: textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 4),
        Text(content, style: textTheme.bodySmall),
      ],
    );
  }

  void _showDeleteBookDialog(BuildContext context) async {
    final booksState = context.read<BooksState>();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: Icon(Icons.delete),
          title: Text('删除书籍'),
          content: Text('确定要删除这本书吗？该操作不会删除本地文件。'),
          iconColor: Theme.of(context).colorScheme.error,
          surfaceTintColor: Theme.of(context).colorScheme.error,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text('取消'),
            ),
            FilledButton(
              onPressed: () async {
                await booksState.deleteBook(relativePath);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.error,
                ),
              ),
              child: Text('确定'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BooksState>(builder: (context, booksState, child) {
      if (!booksState.containsBook(relativePath)) {
        return Scaffold(
          appBar: AppBar(
            title: Text('书籍详情'),
          ),
          body: Center(
            child: Text('书籍不存在'),
          ),
        );
      }
      final bookInfo = booksState.getBookInfo(relativePath);

      final bottom = MediaQuery.of(context).padding.bottom;

      final title = bookInfo.titles.firstOrNull ?? "未知书名";
      final author =
          bookInfo.authors.isNotEmpty ? bookInfo.authors.join(' ') : "未知作者";
      final category =
          booksState.getCategoryName(bookInfo.categoryId) ?? "未知分组";

      final descFuture = booksState.getDesc(relativePath);

      return Scaffold(
        appBar: AppBar(
          title: Text('书籍详情'),
          actions: [
            IconButton(
              icon: Icon(Icons.delete),
              color: Theme.of(context).colorScheme.error,
              onPressed: () async {
                _showDeleteBookDialog(context);
              },
            ),
          ],
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flex(
                        direction: Axis.horizontal,
                        children: [
                          Flexible(
                            flex: 5,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: bookInfo.coverRelativePath != null
                                  ? CustomImageWidget.custom(
                                      booksState.rootPath,
                                      bookInfo.coverRelativePath!,
                                      fit: BoxFit.fill,
                                    )
                                  : Image.asset(
                                      'assets/images/cover.png',
                                      fit: BoxFit.fill,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 7,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(Icons.account_circle, size: 16),
                                    const SizedBox(width: 4),
                                    Text(author),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildMeta(context, Icons.category, '分组', category),
                      const SizedBox(height: 16),
                      _buildMeta(context, Icons.schedule, '最近阅读',
                          "${bookInfo.lastReadTitle}\n${bookInfo.lastReadTimeString}"),
                      const SizedBox(height: 16),
                      _buildMeta(context, Icons.file_present, '文件相对路径',
                          bookInfo.relativePath),
                      const SizedBox(height: 16),
                      FutureBuilder(
                        future: descFuture,
                        builder: (context, snapshot) {
                          if (snapshot.data == null) {
                            return _buildMeta(
                                context, Icons.description, '描述', '加载中...');
                          }
                          return _buildMeta(context, Icons.description, '描述',
                              snapshot.data!.isEmpty ? '无' : snapshot.data!);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  FilledButton.tonal(
                    onPressed: () async {
                      final newCategoryId = await showChangeBookCategoryDialog(
                          context, booksState.categories, bookInfo.categoryId);
                      if (newCategoryId != null) {
                        booksState.updateBookInfo(
                          bookInfo.copyWith(categoryId: newCategoryId),
                        );
                      }
                    },
                    child: Text("切换分组"),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        booksState.updateBookInfo(bookInfo.copyWith(
                          lastReadTime: DateTime.now().millisecondsSinceEpoch,
                        ));
                        Navigator.of(context).pushNamed(
                          '/reader',
                          arguments: relativePath,
                        );
                      },
                      child: Text('阅读'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: bottom + 8),
            ],
          ),
        ),
      );
    });
  }
}
