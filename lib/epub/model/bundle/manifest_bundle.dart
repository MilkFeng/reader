import '../../accessor/accessor.dart';
import '../manifest.dart';

class AssetRefBundle {
  final String id;
  final String href;
  final String mediaType;
  final List<String> properties;

  AssetRefBundle({
    required this.id,
    required this.href,
    required this.mediaType,
    required this.properties,
  });

  factory AssetRefBundle.fromAssetRef(AssetRef assetRef) {
    return AssetRefBundle(
      id: assetRef.id,
      href: assetRef.href,
      mediaType: assetRef.mediaType,
      properties: assetRef.properties,
    );
  }

  AssetRef toAssetRef() {
    return AssetRef(
      id: id,
      href: href,
      mediaType: mediaType,
      properties: properties,
    );
  }

  factory AssetRefBundle.fromJson(Map<String, dynamic> json) {
    return AssetRefBundle(
      id: json['id'],
      href: json['href'],
      mediaType: json['media_type'],
      properties: List<String>.from(json['properties']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'href': href,
      'media_type': mediaType,
      'properties': properties,
    };
  }
}

class ManifestBundle {
  final List<AssetRefBundle> assetRefs;

  ManifestBundle({
    required this.assetRefs,
  });

  factory ManifestBundle.fromManifest(Manifest manifest) {
    return ManifestBundle(
      assetRefs: manifest.assetWithRefs
          .map((e) => AssetRefBundle.fromAssetRef(e.$1))
          .toList(),
    );
  }

  Manifest toManifest(Accessor accessor) {
    return Manifest(
      accessor,
      assetRefs.map((e) => e.toAssetRef()).toList(),
    );
  }

  factory ManifestBundle.fromJson(Map<String, dynamic> json) {
    return ManifestBundle(
      assetRefs: List<AssetRefBundle>.from(
          json['asset_refs'].map((e) => AssetRefBundle.fromJson(e))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'asset_refs': assetRefs.map((e) => e.toJson()).toList(),
    };
  }
}
