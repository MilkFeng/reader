import 'dart:typed_data';

import '../../common/fs_utils.dart';
import '../../epub/epub.dart';
import '../../managers/meta/book_categories_dao.dart';
import 'book_cache_dao.dart';
import 'book_infos_dao.dart';
import 'models.dart';

class MetaManager {
  static const String metaDirName = '.meta';

  MetaManager({
    required this.rootPath,
  })  : _bookInfosDao = BookInfosDao(
          rootPath: rootPath,
          metaDirRelativePath: metaDirName,
        ),
        _bookCacheDao = BookCacheDao(
          rootPath: rootPath,
          metaDirRelativePath: metaDirName,
        ),
        _bookCategoriesDao = BookCategoriesDao(
          rootPath: rootPath,
          metaDirRelativePath: metaDirName,
        );

  final String rootPath;
  final BookInfosDao _bookInfosDao;
  final BookCacheDao _bookCacheDao;
  final BookCategoriesDao _bookCategoriesDao;

  Future<void> createMetaDir() async {
    if (!await FSUtils.checkFileOrDirExist(rootPath, metaDirName)) {
      await FSUtils.createDir(rootPath, metaDirName);
    }
  }

  Future<Map<String, ExtendedBookInfo>> getExtendedBookInfos() async {
    await createMetaDir();
    final bookInfos = await _bookInfosDao.getBookInfos();
    final extendedBookInfos = <String, ExtendedBookInfo>{};
    for (final entry in bookInfos.entries) {
      final extendedBookInfo = _bookCacheDao.extendBookInfo(entry.value);
      extendedBookInfos[entry.key] = extendedBookInfo;
    }
    return extendedBookInfos;
  }

  Future<void> saveBookInfos(Map<String, ExtendedBookInfo> bookInfos) async {
    await createMetaDir();
    await _bookInfosDao.saveBookInfos(bookInfos);
  }

  Future<Map<int, BookCategory>> getBookCategories() async {
    await createMetaDir();
    return await _bookCategoriesDao.getBookCategories();
  }

  Future<void> saveBookCategories(Map<int, BookCategory> bookCategories) async {
    await createMetaDir();
    await _bookCategoriesDao.saveBookCategories(bookCategories);
  }

  Future<String?> saveCover(
    String relativePath,
    String extension,
    String mediaType,
    Uint8List bytes,
  ) async {
    await createMetaDir();
    return await _bookCacheDao.saveCover(
      relativePath,
      extension,
      mediaType,
      bytes,
    );
  }

  Future<String> saveDesc(String relativePath, String content) async {
    await createMetaDir();
    return await _bookCacheDao.saveDesc(relativePath, content);
  }

  Future<String> saveEpubBundle(String relativePath, EpubBundle bundle) async {
    await createMetaDir();
    return await _bookCacheDao.saveEpubBundle(relativePath, bundle);
  }

  Future<String> getDesc(String relativePath) async {
    await createMetaDir();
    return await _bookCacheDao.getDesc(relativePath);
  }

  Future<EpubBundle> getEpubBundle(String relativePath) async {
    await createMetaDir();
    return await _bookCacheDao.getEpubBundle(relativePath);
  }

  String? getCoverRelativePath(String relativePath, String extension) {
    return _bookCacheDao.getCoverRelativePath(relativePath, extension);
  }

  Future<void> deleteBookDir(String relativePath) async {
    await createMetaDir();
    await _bookCacheDao.deleteBookDir(relativePath);
  }

  Map<int, BookCategory> get reservedCategories =>
      BookCategoriesDao.reservedCategories;

  Set<int> get reservedCategoryIds => BookCategoriesDao.reservedCategoryIds;
}
