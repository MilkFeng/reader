import 'dart:convert';

import 'package:xml/xml.dart';

import '../accessor/accessor.dart';
import '../accessor/lazy_file.dart';
import '../model/manifest.dart';
import '../model/metadata.dart';
import '../model/navigation.dart';
import 'manifest_parser.dart';
import 'metadata_parser.dart';
import 'navigation_parser.dart';

class PackageParser {
  static Future<(Metadata, Manifest, Navigation)> parse(
      LazyFile packageFile, Accessor accessor) async {
    final packageBytes = await packageFile.bytes;
    final packageString = utf8.decode(packageBytes);
    final packageDocument = XmlDocument.parse(packageString);

    final packageElement = packageDocument.rootElement;
    final versionString = packageElement.getAttribute('version')!;

    final version = Version(versionString);
    XmlElement? metadataElement;
    XmlElement? manifestElement;
    XmlElement? spineElement;

    for (var itemElement in packageElement.children.whereType<XmlElement>()) {
      switch (itemElement.name.local.toLowerCase()) {
        case 'metadata':
          metadataElement = itemElement;
          break;
        case 'manifest':
          manifestElement = itemElement;
          break;
        case 'spine':
          spineElement = itemElement;
          break;
      }
    }

    final rootPath = packageFile.dirPath;

    final manifest =
        await ManifestParser.parse(manifestElement!, accessor, rootPath);
    final metadata =
        await MetadataParser.parse(metadataElement!, version, manifest, rootPath);
    final navigation =
        await NavigationParser.parse(spineElement!, metadata, manifest, rootPath);

    return (metadata, manifest, navigation);
  }
}
