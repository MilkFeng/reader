import 'dart:convert';

import '../../common/fs_utils.dart';
import 'models.dart';

class BookInfosDao {
  static const String bookInfosFileName = 'book_infos.json';
  static const String bookInfosFileMIME = 'application/json';

  final String rootPath;
  final String metaDirRelativePath;

  BookInfosDao({
    required this.rootPath,
    required this.metaDirRelativePath,
  });

  String get bookInfosFileRelativePath =>
      '$metaDirRelativePath/$bookInfosFileName';

  Future<bool> checkBookInfosFileExist() async {
    return await FSUtils.checkFileOrDirExist(
        rootPath, bookInfosFileRelativePath);
  }

  Future<Map<String, BookInfo>> getBookInfos() async {
    if (!await checkBookInfosFileExist()) {
      return {};
    }
    final jsonBytes = await FSUtils.readFileBytesFromJoinPath(
        rootPath, bookInfosFileRelativePath);
    final jsonStr = utf8.decode(jsonBytes);
    return BookInfo.mapFromJson(jsonStr);
  }

  Future<void> saveBookInfos(Map<String, BookInfo> bookInfos) async {
    final jsonStr = BookInfo.mapToJson(bookInfos);
    final jsonBytes = utf8.encode(jsonStr);
    await FSUtils.writeToFile(rootPath, metaDirRelativePath, bookInfosFileName,
        bookInfosFileMIME, jsonBytes);
  }
}
