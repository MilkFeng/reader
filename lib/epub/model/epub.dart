import 'dart:typed_data';

import 'manifest.dart';
import 'metadata.dart';
import 'navigation.dart';

class Epub {
  final Metadata metadata;
  final Manifest manifest;
  final Navigation navigation;

  Epub({
    required this.metadata,
    required this.manifest,
    required this.navigation,
  });

  Future<Asset?> get coverAsset async {
    final coverHref = metadata.coverHref;
    if (coverHref == null) {
      return null;
    }
    return await manifest.accessByHref(coverHref);
  }

  Future<Uint8List?> get coverBytes async {
    return await (await coverAsset)?.bytes;
  }

  void dispose() {
    manifest.dispose();
  }
}
