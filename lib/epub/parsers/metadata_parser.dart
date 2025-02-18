import 'package:xml/xml.dart';

import '../model/manifest.dart';
import '../model/metadata.dart';

class MetadataParser {
  static Future<Metadata> parse(XmlElement element, Version version,
      Manifest manifest, String rootPath) async {
    List<String> titles = [];
    List<String> authors = [];

    String? description;
    List<String> subjects = [];

    String? coverHref;

    for (var itemElement in element.children.whereType<XmlElement>()) {
      final innerText = itemElement.innerText;
      switch (itemElement.name.local.toLowerCase()) {
        case 'title':
          titles.add(innerText);
          break;
        case 'creator':
          authors.add(innerText);
          break;
        case 'subject':
          subjects.add(innerText);
          break;
        case 'description':
          description = innerText;
          break;
        case 'meta':
          if (version.isVersion2()) {
            if (itemElement.getAttribute('name') == 'cover') {
              final coverId = itemElement.getAttribute('content');
              if (coverId != null) {
                coverHref = manifest.getHrefById(coverId);
              }
            }
          }
          break;
      }
    }

    coverHref ??= manifest.getFirstOrNullHrefWithProperty('cover-image');

    if (coverHref == null) {
      for (var assetWithRef in manifest.assetWithRefs) {
        final assetRef = assetWithRef.$1;
        final lowercaseId = assetRef.id.toLowerCase();
        if (lowercaseId == 'cover.jpg' || lowercaseId == 'cover.png') {
          coverHref = assetRef.href;
          break;
        }
      }
    }

    return Metadata(
      version: version,
      titles: titles,
      authors: authors,
      description: description,
      subjects: subjects,
      coverHref: coverHref,
    );
  }
}
