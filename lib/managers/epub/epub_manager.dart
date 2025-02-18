import 'package:flutter/foundation.dart';

import '../../common/fs_utils.dart';
import '../../epub/epub.dart';

class EpubManager {
  EpubManager({required this.rootPath});

  final String rootPath;

  Future<Epub> openEpub(String relativePath) async {
    final bytes = await _openEpubBytes(relativePath);
    return await openEpubFromBytes(bytes);
  }

  Future<Epub> openEpubWithBundle(
      String relativePath, EpubBundle bundle) async {
    final bytes = await _openEpubBytes(relativePath);
    return await openEpubFromBytesWithBundle(bytes, bundle);
  }

  Future<Uint8List> _openEpubBytes(String relativePath) async {
    return await FSUtils.readFileBytesFromJoinPath(rootPath, relativePath);
  }

  Future<Epub> openEpubFromBytes(Uint8List bytes) async {
    return await compute(EpubOpener.openBytes, bytes);
  }

  Future<Epub> openEpubFromBytesWithBundle(
      Uint8List bytes, EpubBundle bundle) async {
    final accessor = EpubArchiveAccessor.fromBytes(bytes);
    return bundle.toEpub(accessor);
  }
}
