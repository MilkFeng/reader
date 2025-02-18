import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:quiver/core.dart';

import '../../common/fs_utils.dart';

class CustomImage extends ImageProvider<CustomImage> {
  final String rootPath;
  final String relativePath;
  final double scale;

  const CustomImage(this.rootPath, this.relativePath, {this.scale = 1.0});

  @override
  ImageStreamCompleter loadImage(CustomImage key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode: decode),
      scale: scale,
      debugLabel: relativePath,
      informationCollector: () => <DiagnosticsNode>[
        ErrorDescription('Path: $rootPath, $relativePath'),
      ],
    );
  }

  Future<ui.Codec> _loadAsync(
    CustomImage key, {
    required ImageDecoderCallback decode,
  }) async {
    final bytes =
        await FSUtils.readFileBytesFromJoinPath(rootPath, relativePath);
    return decode(await ImmutableBuffer.fromUint8List(bytes));
  }

  @override
  Future<CustomImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<CustomImage>(this);
  }

  @override
  bool operator ==(Object other) =>
      other is CustomImage &&
      relativePath == other.relativePath &&
      scale == other.scale;

  @override
  int get hashCode => hash2(relativePath, scale);
}

final _emptyImageBytes = Uint8List.fromList(<int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);

class CustomImageWidget extends FadeInImage {
  const CustomImageWidget({
    super.key,
    required super.placeholder,
    super.placeholderErrorBuilder,
    required super.image,
    super.imageErrorBuilder,
    super.excludeFromSemantics = false,
    super.imageSemanticLabel,
    super.fadeOutDuration = const Duration(milliseconds: 100),
    super.fadeOutCurve = Curves.easeOut,
    super.fadeInDuration = const Duration(milliseconds: 400),
    super.fadeInCurve = Curves.easeIn,
    super.color,
    super.colorBlendMode,
    super.placeholderColor,
    super.placeholderColorBlendMode,
    super.width,
    super.height,
    super.fit,
    super.placeholderFit,
    super.filterQuality = FilterQuality.medium,
    super.placeholderFilterQuality,
    super.alignment = Alignment.center,
    super.repeat = ImageRepeat.noRepeat,
    super.matchTextDirection = false,
  });

  CustomImageWidget.custom(
    String rootPath,
    String path, {
    super.key,
    double scale = 1.0,
    double placeholderScale = 1.0,
    super.placeholderErrorBuilder,
    super.imageErrorBuilder,
    super.excludeFromSemantics = false,
    super.imageSemanticLabel,
    super.fadeOutDuration = const Duration(milliseconds: 100),
    super.fadeOutCurve = Curves.easeOut,
    super.fadeInDuration = const Duration(milliseconds: 400),
    super.fadeInCurve = Curves.easeIn,
    super.color,
    super.colorBlendMode,
    super.placeholderColor,
    super.placeholderColorBlendMode,
    super.width,
    super.height,
    super.fit,
    super.placeholderFit,
    super.filterQuality = FilterQuality.medium,
    super.placeholderFilterQuality,
    super.alignment = Alignment.center,
    super.repeat = ImageRepeat.noRepeat,
    super.matchTextDirection = false,
    int? placeholderCacheWidth,
    int? placeholderCacheHeight,
    int? cacheWidth,
    int? cacheHeight,
  }) : super(
          image: ResizeImage.resizeIfNeeded(cacheWidth, cacheHeight,
              CustomImage(rootPath, path, scale: scale)),
          placeholder: ResizeImage.resizeIfNeeded(
              placeholderCacheWidth,
              placeholderCacheHeight,
              MemoryImage(_emptyImageBytes, scale: placeholderScale)),
        );
}
