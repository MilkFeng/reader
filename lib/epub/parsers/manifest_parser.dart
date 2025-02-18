import 'package:path/path.dart';
import 'package:xml/xml.dart';

import '../accessor/accessor.dart';
import '../model/manifest.dart';

class ManifestParser {
  static Future<Manifest> parse(
      XmlElement element, Accessor accessor, String rootPath) async {
    List<AssetRef> assetRefs = [];
    for (var itemElement in element.children.whereType<XmlElement>()) {
      String? id;
      String? href;
      String? mediaType;
      String? properties;
      for (var attribute in itemElement.attributes) {
        final name = attribute.name.local.toLowerCase();
        final value = attribute.value;
        switch (name) {
          case 'id':
            id = value;
            break;
          case 'href':
            href = value;
            break;
          case 'media-type':
            mediaType = value;
            break;
          case 'properties':
            properties = value;
            break;
        }
      }

      assetRefs.add(AssetRef(
        id: id!,
        href: join(rootPath, href!),
        mediaType: mediaType!,
        properties: properties?.split(' ') ?? [],
      ));
    }

    return Manifest(accessor, assetRefs);
  }
}
