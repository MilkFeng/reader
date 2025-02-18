import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../utils/path_utils.dart';
import 'accessor.dart';
import 'lazy_file.dart';

class EpubArchiveLazyFile extends LazyFile {
  final ArchiveFile archiveFile;

  EpubArchiveLazyFile({required this.archiveFile});

  @override
  String get path => archiveFile.name;

  @override
  String get name => path.split('/').last;

  @override
  String get dirPath =>
      path.split('/').sublist(0, path.split('/').length - 1).join('/');

  @override
  Future<bool> get loaded => Future.value(archiveFile.isCompressed);

  @override
  Future<Uint8List> get bytes async {
    return archiveFile.content;
  }

  @override
  Future<void> close() async {
    await archiveFile.close();
  }
}

class EpubArchiveAccessor extends Accessor {
  final Archive archive;

  EpubArchiveAccessor({required this.archive});

  EpubArchiveAccessor.fromBytes(Uint8List bytes)
      : archive = ZipDecoder().decodeBytes(bytes);

  EpubArchiveAccessor.fromStream(InputStream stream)
      : archive = ZipDecoder().decodeStream(stream);

  @override
  bool get canCheckExist => true;

  @override
  Future<bool> exists(String path) async {
    return archive.find(path) != null;
  }

  @override
  Future<LazyFile> access(String path) async {
    path = PathUtils.normalize(path);
    if (path.startsWith('/')) {
      path = path.substring(1);
    }
    final archiveFile = archive.find(path);
    if (archiveFile == null) {
      throw Exception('File not found: $path');
    }
    if (!archiveFile.isFile) {
      throw Exception('Not a file: $path');
    }
    return EpubArchiveLazyFile(archiveFile: archiveFile);
  }

  @override
  bool get canList => true;

  @override
  Future<List<String>?> list() async {
    return archive.files.map((f) => f.name).toList();
  }

  @override
  void dispose() {
    // Do nothing
    archive.clearSync();
  }
}
