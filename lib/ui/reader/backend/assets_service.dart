import 'dart:io';

import 'package:flutter/services.dart';

import '../../../epub/epub.dart';
import 'service.dart';

class AssetsService extends Service {
  AssetsService();

  final Map<String, (Uint8List, String)> cache = {};

  @override
  String get part => 'assets';

  @override
  Future<void> handleRequest(String path, HttpRequest request) async {
    if (path.startsWith('/')) {
      path = path.substring(1);
    }

    if (cache.containsKey(path)) {
      final bytes = cache[path]!.$1;
      final mimeType = cache[path]!.$2;

      request.response.statusCode = 200;
      request.response.headers.contentType = ContentType.parse(mimeType);
      request.response.add(bytes);
      request.response.close();
    }

    final byteData = await rootBundle.load("assets/$path");
    final bytes = byteData.buffer.asUint8List();
    final mimeType = MIMEUtils.gaussMIMEFromName(path);
    cache[path] = (bytes, mimeType);

    request.response.statusCode = 200;
    request.response.headers.contentType = ContentType.parse(mimeType);
    request.response.add(bytes);
    request.response.close();
  }
}
