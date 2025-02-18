import 'dart:typed_data';

import '../accessor/accessor.dart';
import '../accessor/lazy_file.dart';
import '../utils/path_utils.dart';

class Asset {
  final String id;
  final LazyFile file;

  final String mediaType;
  final List<String> properties;

  Asset({
    required this.id,
    required this.file,
    required this.mediaType,
    required this.properties,
  });

  Future<Uint8List> get bytes => file.bytes;
  Future<bool> get loaded => file.loaded;
  String get name => file.name;
  String get path => file.path;
  String get dirPath => file.dirPath;
  String get extension => file.extension;

  @override
  String toString() {
    return 'Asset{id: $id, file: $file, mediaType: $mediaType, properties: $properties}';
  }

  Future<void> close() async {
    await file.close();
  }
}

class AssetRef {
  final String id;
  final String href;
  final String mediaType;
  final List<String> properties;

  AssetRef({
    required this.id,
    required this.href,
    required this.mediaType,
    required this.properties,
  });

  @override
  String toString() {
    return 'AssetRef{id: $id, href: $href, mediaType: $mediaType, properties: $properties}';
  }
}

class Manifest {
  final Accessor _accessor;

  late final List<(AssetRef, Asset?)> _assetWithRefs;
  late final Map<String, int> _idToAssetIndex;
  late final Map<String, int> _hrefToAssetIndex;

  late final Map<String, LazyFile?> _lazyFiles;

  late final List<int> _assetIndexWithProperties;

  List<(AssetRef, Asset?)> get assetWithRefs => _assetWithRefs;

  Manifest(this._accessor, List<AssetRef> assetRefs) {
    _assetWithRefs = [];
    _idToAssetIndex = {};
    _hrefToAssetIndex = {};
    _assetIndexWithProperties = [];
    _lazyFiles = {};
    for (var assetRef in assetRefs) {
      assetRef = AssetRef(
        id: assetRef.id,
        href: _trimHref(assetRef.href),
        mediaType: assetRef.mediaType,
        properties: assetRef.properties,
      );

      _assetWithRefs.add((assetRef, null));
      _idToAssetIndex[assetRef.id] = _assetWithRefs.length - 1;
      _hrefToAssetIndex[assetRef.href] = _assetWithRefs.length - 1;

      if (assetRef.properties.isNotEmpty) {
        _assetIndexWithProperties.add(_assetWithRefs.length - 1);
      }
    }
  }

  String _trimHref(String href) {
    return PathUtils.normalize(href.split('#')[0]);
  }

  Future<Asset> accessByAssetIndex(int index) async {
    final assetRef = _assetWithRefs[index].$1;
    if (_assetWithRefs[index].$2 == null) {
      final Asset asset = Asset(
        id: assetRef.id,
        file: await _accessor.access(assetRef.href),
        mediaType: assetRef.mediaType,
        properties: assetRef.properties,
      );
      _assetWithRefs[index] = (assetRef, asset);
    }
    return _assetWithRefs[index].$2!;
  }

  void clearCacheByIndex(int index) {
    _assetWithRefs[index].$2?.close();
    _assetWithRefs[index] = (_assetWithRefs[index].$1, null);
  }

  Future<Asset> accessById(String id) async {
    final index = _idToAssetIndex[id]!;
    return await accessByAssetIndex(index);
  }

  void clearCacheById(String id) {
    final index = _idToAssetIndex[id]!;
    clearCacheByIndex(index);
  }

  Future<Asset> accessByHref(String href) async {
    final index = _hrefToAssetIndex[href]!;
    return await accessByAssetIndex(index);
  }

  void clearCacheByHref(String href) {
    final index = _hrefToAssetIndex[href]!;
    clearCacheByIndex(index);
  }

  String getHrefById(String id) {
    final index = _idToAssetIndex[id]!;
    return _assetWithRefs[index].$1.href;
  }

  String getIdByHref(String href) {
    final index = _hrefToAssetIndex[href]!;
    return _assetWithRefs[index].$1.id;
  }

  String getFirstHrefWithProperty(String properties) {
    return getFirstOrNullHrefWithProperty(properties)!;
  }

  String? getFirstOrNullHrefWithProperty(String property) {
    for (final index in _assetIndexWithProperties) {
      if (_assetWithRefs[index].$1.properties.contains(property)) {
        return _assetWithRefs[index].$1.href;
      }
    }
    return null;
  }

  bool containsId(String id) {
    return _idToAssetIndex.containsKey(id);
  }

  bool containsHref(String href) {
    return _hrefToAssetIndex.containsKey(href);
  }

  Future<LazyFile?> accessFileOutsideManifest(String path) async {
    if (_lazyFiles.containsKey(path)) {
      return _lazyFiles[path];
    }
    if (_accessor.canCheckExist && !await _accessor.exists(path)) {
      _lazyFiles[path] = null;
      return null;
    }
    final file = await _accessor.access(path);
    _lazyFiles[path] = file;
    return file;
  }

  Future<void> clearCacheForFileOutsideManifest(String path) async {
    if (_lazyFiles.containsKey(path)) {
      await _lazyFiles[path]!.close();
      _lazyFiles.remove(path);
    }
  }

  void dispose() {
    for (final file in _lazyFiles.values) {
      file?.close();
    }
    _lazyFiles.clear();

    for (final asset in _assetWithRefs) {
      asset.$2?.close();
    }
    _assetWithRefs.clear();

    _accessor.dispose();
  }
}
