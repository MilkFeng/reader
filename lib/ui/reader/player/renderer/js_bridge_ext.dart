import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../../managers/settings/models.dart';

class ViewPortInfo {
  final double pageWidth;
  final double scrollWidth;
  final int pageCount;

  ViewPortInfo({
    required this.pageWidth,
    required this.scrollWidth,
    required this.pageCount,
  });

  @override
  String toString() {
    return 'ViewPortInfo(pageWidth: $pageWidth, scrollWidth: $scrollWidth, pageCount: $pageCount)';
  }
}

class PageInfo {
  final int pageIndex;
  final String firstVisibleElementPath;

  PageInfo({
    required this.pageIndex,
    required this.firstVisibleElementPath,
  });

  @override
  String toString() {
    return 'PageInfo(pageIndex: $pageIndex, firstVisibleElementPath: $firstVisibleElementPath)';
  }
}

extension JsBridgeExt on InAppWebViewController {
  Future<void> paginateTo(int index) async {
    await evaluateJavascript(
      source: 'window.api.paginateTo($index)',
    );
  }

  double _toDouble(dynamic value) {
    if (value is int) {
      return value.toDouble();
    }
    return value as double;
  }

  ViewPortInfo _toViewPortInfo(dynamic result) {
    return ViewPortInfo(
      pageWidth: _toDouble(result['pageWidth']),
      scrollWidth: _toDouble(result['scrollWidth']),
      pageCount: result['pageCount'] as int,
    );
  }

  PageInfo _toPageInfo(dynamic result) {
    return PageInfo(
      pageIndex: result['pageIndex'] as int,
      firstVisibleElementPath: result['firstVisibleElementPath'] as String,
    );
  }

  Future<ViewPortInfo?> getViewPortInfo() async {
    final result = await evaluateJavascript(
      source: 'window.api.getViewPortInfo()',
    );
    if (result == null) {
      return null;
    }
    return _toViewPortInfo(result);
  }

  Future<PageInfo?> getPageInfo() async {
    final result = await evaluateJavascript(
      source: 'window.api.getCurrentPageInfo()',
    );
    if (result == null) {
      return null;
    }
    return _toPageInfo(result);
  }

  Future<void> injectCSS(Stylesheet? style, {
    bool recalculate = false,
  }) async {
    final css = style?.toCss() ?? '';
    final cssBase64 = base64Encode(utf8.encode(css));
    await evaluateJavascript(
      source: 'window.api.injectCss("$cssBase64")',
    );
  }

  void addOnViewPortInfoChangedHandler(void Function(ViewPortInfo) handler) {
    addJavaScriptHandler(
      handlerName: 'onViewPortInfoChanged',
      callback: (args) {
        handler(_toViewPortInfo(args.first));
      },
    );
  }
}
