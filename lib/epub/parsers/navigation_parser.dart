import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:path/path.dart';
import 'package:xml/xml.dart';

import '../model/location.dart';
import '../model/manifest.dart';
import '../model/metadata.dart';
import '../model/navigation.dart';
import '../utils/path_utils.dart';

class _Spine {
  final List<String> _hrefs;
  final Map<String, int> _hrefToIndex;

  _Spine(this._hrefs)
      : _hrefToIndex = Map.fromEntries(
          _hrefs
              .asMap()
              .entries
              .map((entry) => MapEntry(entry.value, entry.key)),
        );

  int getIndexByHref(String href) {
    href = PathUtils.normalize(href);
    return _hrefToIndex[href]!;
  }

  List<String> getSublistHrefs(int start, int end) {
    return _hrefs.sublist(start, end);
  }
}

class _NavigationPointRef {
  final String label;
  final List<_NavigationPointRef> children;
  final int pivot;

  _NavigationPointRef({
    required this.label,
    required this.children,
    required this.pivot,
  });

  bool get isLeaf => children.isEmpty;
}

class NavigationParser {
  static Future<Navigation> parse(XmlElement element, Metadata metadata,
      Manifest manifest, String rootPath) async {
    List<String> spineHrefs = [];
    for (var itemElement in element.children.whereType<XmlElement>()) {
      final idref = itemElement.getAttribute('idref')!;
      final href = manifest.getHrefById(idref);
      spineHrefs.add(href);
    }
    final spine = _Spine(spineHrefs);

    final _NavigationPointRef rootPointRef;
    final toc = element.getAttribute('toc');
    if (toc != null) {
      final tocAsset = await manifest.accessById(toc);
      rootPointRef = await _parseNCX(tocAsset, metadata, spine);
    } else {
      final tocHref = manifest.getFirstOrNullHrefWithProperty('nav');
      if (tocHref != null) {
        final tocAsset = await manifest.accessByHref(tocHref);
        rootPointRef = await _parseNav(tocAsset, metadata, spine);
      } else {
        throw Exception('No navigation document found');
      }
    }
    final rootPoint =
        await _toNavigationPoint(rootPointRef, spine, spineHrefs.length, []);

    return Navigation(rootPoint: rootPoint);
  }

  static Future<_NavigationPointRef> _parseNCX(
      Asset asset, Metadata metadata, _Spine spine) async {
    final rootPath = asset.file.dirPath;

    final ncxBytes = await asset.file.bytes;
    final ncxString = utf8.decode(ncxBytes);
    final ncxDocument = XmlDocument.parse(ncxString);

    final ncxElement = ncxDocument.rootElement;
    final navMapElement = ncxElement.findElements('navMap').first;

    int pivot = 1;
    final List<_NavigationPointRef> children = [];
    for (var navPointElement
        in navMapElement.children.whereType<XmlElement>()) {
      final pointRef = await _parseNCXPoint(navPointElement, spine, rootPath);
      children.add(pointRef);
    }
    return _NavigationPointRef(
      label: metadata.titles.first,
      children: children,
      pivot: pivot,
    );
  }

  static Future<_NavigationPointRef> _parseNCXPoint(
      XmlElement element, _Spine spine, String rootPath) async {
    final labelElement = element.findElements('navLabel').first;
    final labelTextElement = labelElement.findElements('text').first;
    final labelText = labelTextElement.innerText;

    final contentElement = element.findElements('content').first;
    final src = contentElement.getAttribute('src')!;
    final trimmedHref = src.split('#')[0];
    final href = join(rootPath, trimmedHref);
    final index = spine.getIndexByHref(href) + 1;

    final children = <_NavigationPointRef>[];
    for (var navPointElement in element.children.whereType<XmlElement>()) {
      if (navPointElement.name.local == 'navPoint') {
        final pointRef = await _parseNCXPoint(navPointElement, spine, rootPath);
        children.add(pointRef);
      }
    }

    return _NavigationPointRef(
      label: labelText,
      children: children,
      pivot: index,
    );
  }

  static Future<_NavigationPointRef> _parseNav(
      Asset asset, Metadata metadata, _Spine spine) async {
    final rootPath = asset.file.dirPath;

    final navBytes = await asset.file.bytes;
    final navString = utf8.decode(navBytes);
    final navDocument = XmlDocument.parse(navString);

    final htmlElement = navDocument.rootElement;
    final bodyElement = htmlElement.findElements('body').first;
    final navElement = bodyElement.findElements('nav').first;

    String? label;
    List<_NavigationPointRef> children = [];

    for (var navItemElement in navElement.children.whereType<XmlElement>()) {
      if (navItemElement.name.local == 'ol') {
        final pointRefList = await _parseNavOl(navItemElement, spine, rootPath);
        children.addAll(pointRefList);
      } else if (['h1', 'h2', 'h3', 'h4', 'h5', 'h6']
          .contains(navItemElement.name.local)) {
        label = navItemElement.innerText;
      }
    }
    return _NavigationPointRef(
      label: label ?? metadata.titles.first,
      children: children,
      pivot: 1,
    );
  }

  static Future<List<_NavigationPointRef>> _parseNavOl(
      XmlElement element, _Spine spine, String rootPath) async {
    List<_NavigationPointRef> list = [];

    for (var childElement in element.children.whereType<XmlElement>()) {
      if (childElement.name.local == 'li') {
        final pointRef = await _parseNavLi(childElement, spine, rootPath);
        if (pointRef != null) {
          list.add(pointRef);
        }
      } else {
        // Do nothing
      }
    }

    return list;
  }

  static Future<_NavigationPointRef?> _parseNavLi(
      XmlElement element, _Spine spine, String rootPath) async {
    String? label;
    int pivot = 0;
    List<_NavigationPointRef> children = [];

    for (var childElement in element.children.whereType<XmlElement>()) {
      if (childElement.name.local == 'ol') {
        final pointRefList = await _parseNavOl(childElement, spine, rootPath);
        children.addAll(pointRefList);
      } else if (childElement.name.local == 'a') {
        label = childElement.innerText;
        final href = childElement.getAttribute('href')!;
        final trimmedHref = href.split('#')[0];
        final fullHref = join(rootPath, trimmedHref);
        pivot = spine.getIndexByHref(fullHref) + 1;
      } else if (childElement.name.local == 'span') {
        // Do nothing
      }
    }

    if (pivot == 0) {
      return null;
    }

    return _NavigationPointRef(
      label: label!,
      children: children,
      pivot: pivot,
    );
  }

  static Future<NavigationPoint> _toNavigationPoint(
      _NavigationPointRef pointRef,
      _Spine spine,
      int end,
      List<int> path) async {
    final children = <NavigationPoint>[];
    for (var i = pointRef.children.length - 1; i >= 0; i--) {
      final child = pointRef.children[i];
      path.add(i);
      children.add(await _toNavigationPoint(child, spine, end, path));
      path.removeLast();
      end = child.pivot - 1;
    }

    children.reverseRange(0, children.length);
    List<String> contentHrefs = [];
    if (end >= pointRef.pivot) {
      contentHrefs = spine.getSublistHrefs(pointRef.pivot - 1, end);
    }
    return NavigationPoint(
      label: pointRef.label,
      contentHrefs: contentHrefs,
      children: children,
      location: PointLocation(position: [...path]),
    );
  }
}
