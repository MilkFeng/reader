import 'dart:typed_data';

import 'accessor/epub_archive.dart';
import 'model/bundle/epub_bundle.dart';
import 'model/epub.dart';
import 'parsers/epub_parser.dart';

class EpubOpener {
  static Future<Epub> openBytes(Uint8List bytes) async {
    final accessor = EpubArchiveAccessor.fromBytes(bytes);
    return await EpubParser.parse(accessor);
  }

  static Epub openBytesWithBundle(Uint8List bytes, EpubBundle bundle) {
    final accessor = EpubArchiveAccessor.fromBytes(bytes);
    return bundle.toEpub(accessor);
  }
}
