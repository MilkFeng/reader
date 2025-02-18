import 'dart:convert';

import '../../common/fs_utils.dart';
import 'models.dart';

class BookCategoriesDao {
  static const String bookCategoriesFileName = 'book_categories.json';
  static const String bookCategoriesFileMIME = 'application/json';

  final String rootPath;
  final String metaDirRelativePath;

  BookCategoriesDao({
    required this.rootPath,
    required this.metaDirRelativePath,
  });

  String get bookCategoriesFileRelativePath =>
      '$metaDirRelativePath/$bookCategoriesFileName';

  static final reservedCategories = {
    0: BookCategory(
      id: 0,
      name: '未分组',
      order: CategoryBooksOrder.lastRead,
      index: 0,
    ),
  };

  static final reservedCategoryIds = reservedCategories.keys.toSet();

  Future<bool> checkBookCategoriesFileExist() async {
    return await FSUtils.checkFileOrDirExist(
        rootPath, bookCategoriesFileRelativePath);
  }

  Future<Map<int, BookCategory>> getBookCategories() async {
    if (!await checkBookCategoriesFileExist()) {
      return reservedCategories;
    }
    final jsonBytes = await FSUtils.readFileBytesFromJoinPath(
        rootPath, bookCategoriesFileRelativePath);
    final jsonStr = utf8.decode(jsonBytes);
    return BookCategory.mapFromJson(jsonStr);
  }

  Future<void> saveBookCategories(Map<int, BookCategory> bookCategories) async {
    final jsonStr = BookCategory.mapToJson(bookCategories);
    final jsonBytes = utf8.encode(jsonStr);
    await FSUtils.writeToFile(rootPath, metaDirRelativePath,
        bookCategoriesFileName, bookCategoriesFileMIME, jsonBytes);
  }
}
