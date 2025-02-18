import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../../common/fs_utils.dart';
import '../../epub/epub.dart';
import '../../managers/meta/models.dart';

class BookCacheDao {
  static const String cacheDirName = 'cache';

  final String rootPath;
  final String metaDirRelativePath;

  BookCacheDao({
    required this.rootPath,
    required this.metaDirRelativePath,
  });

  String get cacheRelativeDirPath => '$metaDirRelativePath/$cacheDirName';

  String getBookDirName(String relativePath) {
    final bytes = utf8.encode(relativePath);
    final md5Digest = md5.convert(bytes);
    return md5Digest.toString();
  }

  String getBookDirRelativePath(String relativePath) {
    return '$cacheRelativeDirPath/${getBookDirName(relativePath)}';
  }

  Future<bool> checkBookDirExist(String relativePath) async {
    final bookDirRelativePath = getBookDirRelativePath(relativePath);
    return await FSUtils.checkFileOrDirExist(rootPath, bookDirRelativePath);
  }

  Future<void> createBookDir(String relativePath) async {
    if (await checkBookDirExist(relativePath)) {
      return;
    }
    final bookDirRelativePath = getBookDirRelativePath(relativePath);
    await FSUtils.createDir(rootPath, bookDirRelativePath);
  }

  Future<void> deleteBookDir(String relativePath) async {
    final bookDirRelativePath = getBookDirRelativePath(relativePath);
    await FSUtils.deleteDir(rootPath, bookDirRelativePath);
  }

  String getCoverRelativePath(String relativePath, String extension) {
    final bookDirRelativePath = getBookDirRelativePath(relativePath);
    return '$bookDirRelativePath/cover.$extension';
  }

  String getDescRelativePath(String relativePath) {
    final bookDirRelativePath = getBookDirRelativePath(relativePath);
    return '$bookDirRelativePath/desc.txt';
  }

  String getEpubBundleRelativePath(String relativePath) {
    final bookDirRelativePath = getBookDirRelativePath(relativePath);
    return '$bookDirRelativePath/bundle.json';
  }

  ExtendedBookInfo extendBookInfo(BookInfo bookInfo) {
    String? coverRelativePath;
    String? descRelativePath;
    late final String epubBundleRelativePath;

    if (bookInfo.coverExtension != null) {
      coverRelativePath =
          getCoverRelativePath(bookInfo.relativePath, bookInfo.coverExtension!);
    }

    descRelativePath = getDescRelativePath(bookInfo.relativePath);
    epubBundleRelativePath = getEpubBundleRelativePath(bookInfo.relativePath);

    return ExtendedBookInfo(
      coverRelativePath: coverRelativePath,
      descRelativePath: descRelativePath,
      epubBundleRelativePath: epubBundleRelativePath,
      titles: bookInfo.titles,
      authors: bookInfo.authors,
      relativePath: bookInfo.relativePath,
      coverExtension: bookInfo.coverExtension,
      categoryId: bookInfo.categoryId,
      lastReadTime: bookInfo.lastReadTime,
      lastReadLocation: bookInfo.lastReadLocation,
      lastReadTitle: bookInfo.lastReadTitle,
    );
  }

  Future<String> getDesc(String relativePath) async {
    final descPath = getDescRelativePath(relativePath);
    final descBytes =
        await FSUtils.readFileBytesFromJoinPath(rootPath, descPath);
    return utf8.decode(descBytes);
  }

  Future<EpubBundle> getEpubBundle(String relativePath) async {
    final bundlePath = getEpubBundleRelativePath(relativePath);
    final bundleBytes =
        await FSUtils.readFileBytesFromJoinPath(rootPath, bundlePath);
    final bundleJson = jsonDecode(utf8.decode(bundleBytes));
    return EpubBundle.fromJson(bundleJson);
  }

  Future<String> saveDesc(String relativePath, String desc) async {
    await createBookDir(relativePath);
    final bookDirRelativePath = getBookDirRelativePath(relativePath);
    final descBytes = utf8.encode(desc);
    await FSUtils.writeToFile(
        rootPath, bookDirRelativePath, 'desc.txt', 'text/plain', descBytes);

    return "$bookDirRelativePath/desc.txt";
  }

  Future<String> saveCover(
    String relativePath,
    String extension,
    String mime,
    Uint8List bytes,
  ) async {
    await createBookDir(relativePath);
    final bookDirRelativePath = getBookDirRelativePath(relativePath);
    await FSUtils.writeToFile(
        rootPath, bookDirRelativePath, "cover.$extension", mime, bytes);

    return "$bookDirRelativePath/cover.$extension";
  }

  Future<String> saveEpubBundle(String relativePath, EpubBundle bundle) async {
    await createBookDir(relativePath);
    final bookDirRelativePath = getBookDirRelativePath(relativePath);
    final bundleJson = jsonEncode(bundle.toJson());
    final bundleBytes = utf8.encode(bundleJson);
    await FSUtils.writeToFile(rootPath, bookDirRelativePath, "bundle.json",
        "application/json", bundleBytes);

    return "$bookDirRelativePath/bundle.json";
  }
}
