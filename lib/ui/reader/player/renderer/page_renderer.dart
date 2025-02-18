import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import '../../reader_screen_state.dart';
import 'js_bridge_ext.dart';
import 'page_renderer_controller.dart';

class PageRenderer extends StatefulWidget {
  const PageRenderer({
    super.key,
    required this.controller,
    required this.onCreated,
  });

  final PageRendererController controller;
  final Function() onCreated;

  @override
  State<StatefulWidget> createState() => PageRendererState();
}

enum _PageRendererStage {
  idle,
  contentLoading,
  contentLoaded,
  styleAttaching,
  styleAttached,
  paginating,
  paginated,
}

class PageRendererState extends State<PageRenderer> {
  InAppWebViewController? _webViewController;

  PageRendererController get controller => widget.controller;
  _PageRendererStage _stage = _PageRendererStage.idle;

  late final BehaviorSubject _stateManager;

  @override
  void initState() {
    super.initState();

    controller.registerFunctions(
      cancel: cancel,
      loadContent: loadContent,
      attachStyle: attachStyle,
      paginate: paginate,
    );

    _stateManager = BehaviorSubject.seeded(_stage);
  }

  void _setStage(_PageRendererStage stage) {
    _stage = stage;
    _stateManager.add(stage);
  }

  String? get url {
    final contentLocation = controller.pageLocation?.contentLocation;
    if (contentLocation == null) return null;

    final readerScreenState = context.read<ReaderScreenState>();
    final href =
        readerScreenState.navigation.getHrefByLocation(contentLocation);
    return "http://localhost:${readerScreenState.serverPort}/epub/$href";
  }

  Future<void> _waitFor(_PageRendererStage stage) async {
    await _stateManager.stream
        .startWith(_stage)
        .firstWhere((s) => s.index >= stage.index);
  }

  Future<void> loadContent() async {
    final url = this.url;
    if (_stage == _PageRendererStage.contentLoading) {
      await _webViewController?.stopLoading();
    }

    if (url == null) {
      _setStage(_PageRendererStage.contentLoaded);
      return;
    }

    final urlRequest = URLRequest(url: WebUri.uri(Uri.parse(url)));
    await _webViewController?.loadUrl(urlRequest: urlRequest);
  }

  Future<ViewPortInfo?> attachStyle() async {
    // 等待内容加载完成
    await _waitFor(_PageRendererStage.contentLoaded);

    _setStage(_PageRendererStage.styleAttaching);
    await _webViewController?.injectCSS(controller.style);
    _setStage(_PageRendererStage.styleAttached);

    return await _webViewController?.getViewPortInfo();
  }

  Future<PageInfo?> paginate() async {
    // 等待样式注入完成
    await _waitFor(_PageRendererStage.styleAttached);

    _setStage(_PageRendererStage.paginating);
    final pageIndex = controller.pageLocation?.pageIndex;
    if (pageIndex != null) {
      await _webViewController?.paginateTo(pageIndex);
    }
    _setStage(_PageRendererStage.paginated);

    return await _webViewController?.getPageInfo();
  }

  Future<void> cancel() async {
    await _webViewController?.stopLoading();
    _setStage(_PageRendererStage.idle);
  }

  Future<void> scrollToPage() async {
    if (widget.controller.pageLocation != null) {
      final index = widget.controller.pageLocation!.pageIndex;
      await _webViewController!.paginateTo(index);
    }
  }

  Widget _buildWebView() {
    return InAppWebView(
      onWebViewCreated: (controller) {
        _webViewController = controller;
        widget.onCreated();
      },
      onLoadStart: (controller, url) {
        _setStage(_PageRendererStage.contentLoading);
      },
      onLoadStop: (controller, url) {
        _setStage(_PageRendererStage.contentLoaded);
      },
      initialSettings: InAppWebViewSettings(
        disableVerticalScroll: true,
        disableHorizontalScroll: true,
        disallowOverScroll: true,
        supportZoom: false,
        useHybridComposition: false,
        verticalScrollBarEnabled: false,
        horizontalScrollBarEnabled: false,
        transparentBackground: true,
        isInspectable: false,
        supportMultipleWindows: false,
        allowsLinkPreview: false,
        cacheEnabled: false,
        cacheMode: CacheMode.LOAD_CACHE_ELSE_NETWORK,
        geolocationEnabled: false,
        isPagingEnabled: true,
        disableContextMenu: true,
        disableLongPressContextMenuOnLinks: true,
        disableDefaultErrorPage: true,
        disableInputAccessoryView: true,
        incognito: true,
        databaseEnabled: false,
        domStorageEnabled: false,
        thirdPartyCookiesEnabled: false,
        saveFormData: false,
        allowsBackForwardNavigationGestures: false,
        allowsAirPlayForMediaPlayback: false,
        sharedCookiesEnabled: false,
        isFindInteractionEnabled: false,
        isFraudulentWebsiteWarningEnabled: false,
        limitsNavigationsToAppBoundDomains: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: _buildWebView(),
    );
  }
}
