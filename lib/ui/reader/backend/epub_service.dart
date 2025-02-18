import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:html/dom.dart';
import 'package:html/parser.dart';

import '../../../epub/epub.dart';
import 'service.dart';

class EpubService extends Service {
  final Epub epub;

  final String style;
  final String script;

  // FIFO cache
  static const int cacheSize = 10;

  final Map<String, Uint8List> htmlCache = {};
  final List<String> cacheKeys = [];

  EpubService(
    this.epub, {
    required this.style,
    required this.script,
  });

  @override
  String get part => 'epub';

  @override
  Future<void> handleRequest(String path, HttpRequest request) async {
    if (htmlCache.containsKey(path)) {
      request.response.statusCode = 200;
      request.response.headers.contentType = ContentType.html;
      request.response.add(htmlCache[path]!);
      request.response.close();
      return;
    }

    final Uint8List bytes;
    final bool isHtml;
    final String mime;
    if (epub.manifest.containsHref(path)) {
      final asset = await epub.manifest.accessByHref(path);

      bytes = await asset.bytes;
      mime = asset.mediaType;
      isHtml = MIMEUtils.isHTML(asset.mediaType);
    } else {
      final file = await epub.manifest.accessFileOutsideManifest(path);
      if (file == null) {
        throw Exception('File not found: $path');
      }
      bytes = await file.bytes;
      mime = MIMEUtils.gaussMIMEFromName(file.path);
      isHtml = MIMEUtils.isHTMLByExtension(file.path);
    }

    if (isHtml) {
      Document html = parse(utf8.decode(bytes));
      html = injectScript(html);
      html = injectStyle(html);
      html = injectMeta(html);

      final htmlBytes = utf8.encode(html.outerHtml);
      cache(path, htmlBytes);

      request.response.statusCode = 200;
      request.response.headers.contentType = ContentType.html;
      request.response.add(htmlBytes);
      request.response.close();
    } else {
      request.response.statusCode = 200;
      request.response.headers.contentType = ContentType.parse(mime);
      request.response.add(bytes);
      request.response.close();
    }
  }

  void cache(String path, Uint8List bytes) {
    if (cacheKeys.length >= cacheSize) {
      final key = cacheKeys.removeAt(0);
      htmlCache.remove(key);
    }
    cacheKeys.add(path);
    htmlCache[path] = bytes;
  }

  static const String _scriptId = "___epub_script";
  static const String _styleId = "___epub_style";

  Document injectScript(Document html) {
    final script = Element.tag('script');
    script.id = _scriptId;
    script.text = this.script;
    html.head!.append(script);
    return html;
  }

  Document injectStyle(Document html) {
    final style = Element.tag('style');
    style.id = _styleId;
    style.text = this.style;
    html.head!.append(style);
    return html;
  }

  Document injectMeta(Document html) {
    final meta = Element.tag('meta');
    meta.attributes['name'] = 'viewport';
    meta.attributes['content'] =
        'width=device-width, height=device-height, user-scalable=no, initial-scale=1.0';
    html.head!.append(meta);
    return html;
  }
}
