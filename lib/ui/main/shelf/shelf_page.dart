import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../books_state.dart';
import '../../../managers/meta/models.dart';
import '../../main/shelf/book_tile.dart';

class ShelfPage extends StatefulWidget {
  const ShelfPage({super.key});

  static NavigationDestination get destination => NavigationDestination(
        selectedIcon: Icon(Icons.local_library),
        icon: Icon(Icons.local_library_outlined),
        label: '书架',
      );

  @override
  State<ShelfPage> createState() => _ShelfPageState();
}

class _ShelfPageState extends State<ShelfPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  Map<String, List<BookInfo>> books = {};
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      length: 0,
      vsync: this,
    );
  }

  void showDetailBottomSheet(
      BuildContext context, ExtendedBookInfo bookInfo) async {
    Navigator.of(context).pushNamed(
      '/detail',
      arguments: bookInfo.relativePath,
    );
  }

  void updateTabController(int newCategoryCount) {
    if (tabController.length != newCategoryCount) {
      final oldIndex = tabController.index;
      final newIndex = oldIndex.clamp(0, newCategoryCount - 1);
      tabController = TabController(
        length: newCategoryCount,
        vsync: this,
        initialIndex: newIndex,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final booksState = context.watch<BooksState>();
    updateTabController(booksState.categories.keys.length);

    final categorizedBooks = booksState.categorizedBooks;

    final tabHeight = 46.0;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('书架 '),
            AnimatedFlipCounter(value: booksState.books.length),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              booksState.update();
            },
            icon: Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/category');
            },
            icon: Icon(Icons.category),
          ),
        ],
        bottom: TabBar(
          controller: tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: booksState.sortedCategories
              .map((category) => SizedBox(
                    height: tabHeight,
                    child: Row(
                      children: [
                        Text('${category.name} '),
                        AnimatedFlipCounter(
                            value: categorizedBooks[category.id]!.length),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: tabController,
        physics: const AlwaysScrollableScrollPhysics(),
        children: booksState.sortedCategories.map((category) {
          final books = categorizedBooks[category.id]!;
          return Scrollbar(
            child: ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                return BookTile(
                  key: ValueKey(books[index].relativePath),
                  book: books[index],
                  onRead: (bookInfo) {
                    // 更新阅读时间
                    booksState.updateBookInfo(bookInfo.copyWith(
                      lastReadTime: DateTime.now().millisecondsSinceEpoch,
                    ));
                    Navigator.of(context).pushNamed(
                      '/reader',
                      arguments: bookInfo.relativePath,
                    );
                  },
                  onDetail: (bookInfo) {
                    showDetailBottomSheet(context, bookInfo);
                  },
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
