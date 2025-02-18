import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'common/fs_utils.dart';
import 'epub/epub.dart';
import 'managers/epub/epub_manager.dart';
import 'managers/meta/meta_manager.dart';
import 'managers/meta/models.dart';

class BooksState extends ChangeNotifier {
  final String rootPath;

  late final MetaManager _metaManager;
  late final EpubManager _epubManager;

  late final Map<String, ExtendedBookInfo> _books;
  late final Map<int, BookCategory> _categories;

  Map<String, ExtendedBookInfo> get books => _books;

  Map<int, BookCategory> get categories => _categories;

  List<BookCategory> get sortedCategories {
    return _categories.values.toList()
      ..sort((a, b) => a.index.compareTo(b.index));
  }

  Map<int, List<ExtendedBookInfo>> get categorizedBooks {
    final categorizedBooks = <int, List<ExtendedBookInfo>>{};
    for (final categoryId in _categories.keys) {
      categorizedBooks[categoryId] = [];
    }
    for (final bookInfo in _books.values) {
      categorizedBooks[bookInfo.categoryId]!.add(bookInfo);
    }
    for (final categoryId in categorizedBooks.keys) {
      final category = _categories[categoryId]!;
      categorizedBooks[categoryId]!.sort((a, b) {
        switch (category.order) {
          case CategoryBooksOrder.title:
            return a.titles.first.compareTo(b.titles.first);
          case CategoryBooksOrder.lastRead:
            return b.lastReadTime.compareTo(a.lastReadTime);
        }
      });
    }

    return categorizedBooks;
  }

  BooksState({required this.rootPath}) {
    _metaManager = MetaManager(rootPath: rootPath);
    _epubManager = EpubManager(rootPath: rootPath);

    _categories = {};
    _books = {};
    update();
  }

  ExtendedBookInfo getBookInfo(String relativePath) {
    return _books[relativePath]!;
  }

  bool containsBook(String relativePath) {
    return _books.containsKey(relativePath);
  }

  Future<void> update() async {
    _books.clear();
    _books.addAll(await _metaManager.getExtendedBookInfos());

    _categories.clear();
    _categories.addAll(await _metaManager.getBookCategories());

    notifyListeners();
  }

  Future<void> save() async {
    await _metaManager.saveBookInfos(_books);
    await _metaManager.saveBookCategories(_categories);
  }

  Future<void> addBookInfo(ExtendedBookInfo bookInfo) async {
    _books[bookInfo.relativePath] = bookInfo;
    notifyListeners();
    await _metaManager.saveBookInfos(_books);
  }

  void _recalculateIndexOfCategories() {
    final sortedCategories = _categories.values.toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    for (var i = 0; i < sortedCategories.length; i++) {
      final category = sortedCategories[i];
      if (category.index != i) {
        _categories[category.id] = category.copyWith(index: i);
      }
    }
  }

  Future<void> addCategory(BookCategory category) async {
    _categories[category.id] = category;
    _recalculateIndexOfCategories();
    notifyListeners();
    await _metaManager.saveBookCategories(_categories);
  }

  Future<void> reorderCategory(int oldIndex, int newIndex) async {
    final sortedCategories = this.sortedCategories;
    sortedCategories.insert(newIndex, sortedCategories[oldIndex]);
    if (oldIndex < newIndex) {
      sortedCategories.removeAt(oldIndex);
    } else {
      sortedCategories.removeAt(oldIndex + 1);
    }
    for (var i = 0; i < sortedCategories.length; i++) {
      final category = sortedCategories[i];
      if (category.index != i) {
        _categories[category.id] = category.copyWith(index: i);
      }
    }
    notifyListeners();
    await _metaManager.saveBookCategories(_categories);
  }

  Future<void> removeCategory(int categoryId) async {
    _categories.remove(categoryId);
    _recalculateIndexOfCategories();

    for (final relativePath in _books.keys) {
      final bookInfo = _books[relativePath]!;
      if (bookInfo.categoryId == categoryId) {
        _books[relativePath] = bookInfo.copyWith(categoryId: 0);
      }
    }

    notifyListeners();
    await _metaManager.saveBookCategories(_categories);
    await _metaManager.saveBookInfos(_books);
  }

  Future<void> updateBookInfo(ExtendedBookInfo bookInfo) async {
    _books[bookInfo.relativePath] = bookInfo;
    notifyListeners();
    await _metaManager.saveBookInfos(_books);
  }

  void updateBookInfoTemp(ExtendedBookInfo bookInfo) {
    _books[bookInfo.relativePath] = bookInfo;
    notifyListeners();
  }

  Future<void> updateCategory(BookCategory category) async {
    _categories[category.id] = category;
    notifyListeners();
    await _metaManager.saveBookCategories(_categories);
  }

  Future<void> clearBookInfos() async {
    _books.clear();
    notifyListeners();
    await _metaManager.saveBookInfos(_books);
  }

  Future<Epub> openEpub(String relativePath) async {
    return await _epubManager.openEpub(relativePath);
  }

  Future<Uint8List> readBytes(String relativePath) async {
    return await FSUtils.readFileBytesFromJoinPath(rootPath, relativePath);
  }

  Future<Epub> openEpubFromBytes(Uint8List bytes) async {
    return await _epubManager.openEpubFromBytes(bytes);
  }

  Future<Epub> openEpubFromBytesWithBundle(
      Uint8List bytes, EpubBundle bundle) async {
    return await _epubManager.openEpubFromBytesWithBundle(bytes, bundle);
  }

  Future<String?> saveCover(Epub epub, String relativePath) async {
    final coverAsset = await epub.coverAsset;
    if (coverAsset != null) {
      final coverExtension = coverAsset.extension;
      final coverBytes = await coverAsset.bytes;
      return await _metaManager.saveCover(
        relativePath,
        coverExtension,
        coverAsset.mediaType,
        coverBytes,
      );
    }
    return null;
  }

  Future<String?> saveDesc(String relativePath, String description) async {
    return await _metaManager.saveDesc(relativePath, description);
  }

  Future<String?> getCoverPath(String relativePath) async {
    final bookInfo = getBookInfo(relativePath);
    if (bookInfo.coverExtension == null) {
      return null;
    }
    return _metaManager.getCoverRelativePath(
        relativePath, bookInfo.coverExtension!);
  }

  Future<String> getDesc(String relativePath) async {
    return await _metaManager.getDesc(relativePath);
  }

  Future<ExtendedBookInfo> uploadBook(String relativePath) async {
    final epub = await openEpub(relativePath);
    final bookInfo = BookInfo(
      titles: epub.metadata.titles,
      authors: epub.metadata.authors,
      relativePath: relativePath,
      coverExtension: (await epub.coverAsset)?.extension,
      categoryId: 0,
      lastReadTime: DateTime.now().millisecondsSinceEpoch,
      lastReadLocation: PageLocation.firstPageOf(epub.navigation.firstLocation),
      lastReadTitle: epub.navigation.firstPoint.label,
    );

    final coverPath = await saveCover(epub, relativePath);
    final descPath =
        await saveDesc(relativePath, epub.metadata.description ?? '');
    final bundlePath =
        await _metaManager.saveEpubBundle(relativePath, epub.toBundle());

    final extendedBookInfo = ExtendedBookInfo(
      coverRelativePath: coverPath,
      descRelativePath: descPath,
      epubBundleRelativePath: bundlePath,
      titles: bookInfo.titles,
      authors: bookInfo.authors,
      relativePath: bookInfo.relativePath,
      coverExtension: bookInfo.coverExtension,
      categoryId: bookInfo.categoryId,
      lastReadTime: bookInfo.lastReadTime,
      lastReadLocation: bookInfo.lastReadLocation,
      lastReadTitle: bookInfo.lastReadTitle,
    );

    await addBookInfo(extendedBookInfo);
    return extendedBookInfo;
  }

  Future<void> deleteBook(String relativePath) async {
    _books.remove(relativePath);
    await _metaManager.deleteBookDir(relativePath);
    await _metaManager.saveBookInfos(_books);
    notifyListeners();
  }

  String? getCategoryName(int category) {
    return _categories[category]?.name;
  }

  int get nextCategoryId {
    return _categories.keys.max + 1;
  }

  Map<int, BookCategory> get reservedCategories =>
      _metaManager.reservedCategories;

  Set<int> get reservedCategoryIds => _metaManager.reservedCategoryIds;
}
