import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../../../../managers/meta/models.dart';
import '../../../../managers/settings/models.dart';
import 'js_bridge_ext.dart';

class PageLoadedDetail {
  final ViewPortInfo viewPortInfo;
  final PageInfo pageInfo;

  PageLoadedDetail({
    required this.viewPortInfo,
    required this.pageInfo,
  });
}

class PageRendererController extends ChangeNotifier {
  final String? debugLabel;

  Stylesheet? style;
  PageLocation? pageLocation;

  Future<void> Function()? _cancel;
  Future<void> Function()? _loadContent;
  Future<ViewPortInfo?> Function()? _attachStyle;
  Future<PageInfo?> Function()? _paginate;

  PageRendererController({this.debugLabel});

  registerFunctions({
    required Future<void> Function() cancel,
    required Future<void> Function() loadContent,
    required Future<ViewPortInfo?> Function() attachStyle,
    required Future<PageInfo?> Function() paginate,
  }) {
    _cancel = cancel;
    _loadContent = loadContent;
    _attachStyle = attachStyle;
    _paginate = paginate;
  }

  Future<void> loadContent() async {
    if (_loadContent != null) {
      return await _loadContent!();
    }
  }

  Future<ViewPortInfo?> attachStyle() async {
    if (_attachStyle != null) {
      return await _attachStyle!();
    }
    return null;
  }

  Future<PageInfo?> paginate() async {
    if (_paginate != null) {
      return await _paginate!();
    }
    return null;
  }

  Future<void> cancel() async {
    if (_cancel != null) {
      return await _cancel!();
    }
  }

  Future<PageLoadedDetail?> load() async {
    await loadContent();
    final viewPortInfo = await attachStyle();
    if (viewPortInfo == null) {
      await cancel();
      return null;
    }
    final pageInfo = await paginate();
    if (pageInfo == null) {
      await cancel();
      return null;
    }
    await cancel();
    return PageLoadedDetail(
      viewPortInfo: viewPortInfo,
      pageInfo: pageInfo,
    );
  }
}
