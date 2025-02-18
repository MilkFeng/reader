import 'dart:convert';

import 'package:xml/xml.dart';

import '../accessor/lazy_file.dart';

class ContainerParser {
  static Future<String> parse(LazyFile containerFile) async {
    final containerBytes = await containerFile.bytes;
    final containerString = utf8.decode(containerBytes);
    final containerDocument = XmlDocument.parse(containerString);

    final packageElement = containerDocument
        .findAllElements('container',
            namespace: 'urn:oasis:names:tc:opendocument:xmlns:container')
        .first;

    final rootFileElement = packageElement.descendants
        .where((e) => (e is XmlElement) && e.name.local == 'rootfile')
        .first;

    return rootFileElement.getAttribute('full-path')!;
  }
}
