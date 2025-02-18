import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart';
import 'package:saf_stream/saf_stream.dart';
import 'package:saf_util/saf_util.dart';
import 'package:uri_to_file/uri_to_file.dart';

class Entity {
  final String platformPath;
  final String name;
  final bool isFile;
  final int length;
  final String relativePath;

  Entity({
    required this.platformPath,
    required this.name,
    required this.isFile,
    required this.relativePath,
    this.length = 0,
  });
}

class FSUtils {
  static final _safUtil = SafUtil();
  static final _safStream = SafStream();

  static String _trimPath(String path) {
    if (path.startsWith("/")) {
      return path.substring(1);
    }
    return path;
  }

  static Future<void> writeToFile(
    String rootPath,
    String dirRelativePath,
    String fileName,
    String mime,
    Uint8List data,
  ) async {
    final dirPath = await joinPath(rootPath, dirRelativePath);
    if (Platform.isAndroid) {
      await _safStream.writeFileBytes(dirPath, fileName, mime, data,
          overwrite: true);
    } else if (Platform.isIOS) {
      throw UnimplementedError();
    } else {
      throw UnimplementedError();
    }
  }

  static Future<bool> checkFileOrDirExist(
      String rootPath, String relativePath) async {
    relativePath = _trimPath(relativePath);
    if (Platform.isAndroid) {
      final relativePathSegments = relativePath.split('/');
      final file = await _safUtil.child(rootPath, relativePathSegments);
      return file != null;
    } else if (Platform.isIOS) {
      throw UnimplementedError();
    } else {
      throw UnimplementedError();
    }
  }

  static Future<void> createDir(String rootPath, String relativePath) async {
    relativePath = _trimPath(relativePath);
    if (Platform.isAndroid) {
      final relativePathSegments = relativePath.split('/');
      await _safUtil.mkdirp(rootPath, relativePathSegments);
    } else if (Platform.isIOS) {
      throw UnimplementedError();
    } else {
      throw UnimplementedError();
    }
  }

  static Future<void> deleteDir(String rootPath, String relativePath) async {
    relativePath = _trimPath(relativePath);
    if (Platform.isAndroid) {
      final relativePathSegments = relativePath.split('/');
      final path = await _safUtil.child(rootPath, relativePathSegments);
      if (path == null) {
        return;
      }
      await _safUtil.delete(path.uri, true);
    } else if (Platform.isIOS) {
      throw UnimplementedError();
    } else {
      throw UnimplementedError();
    }
  }

  static Future<String> joinPath(String rootPath, String relativePath) async {
    relativePath = _trimPath(relativePath);
    if (Platform.isAndroid) {
      final relativePathSegments = relativePath.split('/');
      final file = await _safUtil.child(rootPath, relativePathSegments);
      if (file == null) {
        throw FileSystemException("File not found", relativePath);
      }
      return file.uri;
    } else if (Platform.isIOS) {
      throw UnimplementedError();
    } else {
      throw UnimplementedError();
    }
  }

  static Future<File> fileFromJoinPath(
      String rootPath, String relativePath) async {
    final path = await joinPath(rootPath, relativePath);
    if (Platform.isAndroid) {
      return toFile(path);
    } else if (Platform.isIOS) {
      throw UnimplementedError();
    } else {
      return File(path);
    }
  }

  static Future<Uint8List> readFileBytesFromJoinPath(
      String rootPath, String relativePath) async {
    final path = await joinPath(rootPath, relativePath);
    return await readFileBytesFromPlatformPath(path);
  }

  static Future<Stream<Uint8List>> readFileStreamFromJoinPath(
      String rootPath, String relativePath) async {
    final path = await joinPath(rootPath, relativePath);
    return await readFileStreamFromPlatformPath(path);
  }

  static Future<Uint8List> readFileBytesFromPlatformPath(String path) async {
    if (Platform.isAndroid) {
      return await _safStream.readFileBytes(path);
    } else if (Platform.isIOS) {
      throw UnimplementedError();
    } else {
      return await File(path).readAsBytes();
    }
  }

  static Future<Stream<Uint8List>> readFileStreamFromPlatformPath(
      String path) async {
    if (Platform.isAndroid) {
      return await _safStream.readFileStream(path);
    } else if (Platform.isIOS) {
      throw UnimplementedError();
    } else {
      throw UnimplementedError();
    }
  }

  static Future<String?> pickFolder({
    String? initialUri,
    bool? writePermission,
    bool? persistablePermission = true,
  }) async {
    if (Platform.isAndroid) {
      final res = await _safUtil.pickDirectory(
        initialUri: initialUri,
        writePermission: writePermission,
        persistablePermission: persistablePermission,
      );
      if (res == null) {
        return null;
      }
      return res.uri;
    } else if (Platform.isIOS) {
      throw UnimplementedError();
    } else if (Platform.isMacOS) {
      throw UnimplementedError();
    }
    return null;
  }

  static Future<List<Entity>> listDirectory(Entity entity) async {
    if (Platform.isAndroid) {
      final files = await _safUtil.list(entity.platformPath);
      return files.map((e) {
        return Entity(
          platformPath: e.uri.toString(),
          name: e.name,
          isFile: !e.isDir,
          relativePath: '${entity.relativePath}/${e.name}',
          length: e.length,
        );
      }).toList();
    } else if (Platform.isIOS) {
      throw UnimplementedError();
    } else {
      throw UnimplementedError();
    }
  }
}
