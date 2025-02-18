import '../../accessor/accessor.dart';
import '../epub.dart';
import 'manifest_bundle.dart';
import 'metadata_bundle.dart';
import 'navigation_bundle.dart';

class EpubBundle {
  final MetadataBundle metadataBundle;
  final ManifestBundle manifestBundle;
  final NavigationBundle navigationBundle;

  EpubBundle({
    required this.metadataBundle,
    required this.manifestBundle,
    required this.navigationBundle,
  });

  factory EpubBundle.fromEpub(Epub epub) {
    return EpubBundle(
      metadataBundle: MetadataBundle.fromMetadata(epub.metadata),
      manifestBundle: ManifestBundle.fromManifest(epub.manifest),
      navigationBundle: NavigationBundle.fromNavigation(epub.navigation),
    );
  }

  Epub toEpub(Accessor accessor) {
    return Epub(
      metadata: metadataBundle.toMetadata(),
      manifest: manifestBundle.toManifest(accessor),
      navigation: navigationBundle.toNavigation(),
    );
  }

  factory EpubBundle.fromJson(Map<String, dynamic> json) {
    return EpubBundle(
      metadataBundle: MetadataBundle.fromJson(json['metadata']),
      manifestBundle: ManifestBundle.fromJson(json['manifest']),
      navigationBundle: NavigationBundle.fromJson(json['navigation']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'metadata': metadataBundle.toJson(),
      'manifest': manifestBundle.toJson(),
      'navigation': navigationBundle.toJson(),
    };
  }
}

extension EpubBundleExtension on Epub {
  EpubBundle toBundle() => EpubBundle.fromEpub(this);

  Epub fromBundle(Accessor accessor, EpubBundle bundle) =>
      bundle.toEpub(accessor);
}
