import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../books_state.dart';
import '../../../epub/epub.dart';
import '../../../managers/meta/models.dart';
import '../reader_screen_state.dart';
import 'overlay/panel.dart';
import 'overlay/toc_drawer.dart';
import 'style_state.dart';
import 'viewer/epub_viewer.dart';
import 'viewer/epub_viewer_controller.dart';

class EpubPlayer extends StatefulWidget {
  const EpubPlayer({
    super.key,
  });

  @override
  State<EpubPlayer> createState() => _EpubPlayerState();
}

class _EpubPlayerState extends State<EpubPlayer> with WidgetsBindingObserver {
  late final EpubViewerController epubViewerController;
  late final PanelController panelController;
  late final TOCDrawerController tocDrawerController;

  late final StyleState styleState;

  @override
  void initState() {
    super.initState();

    styleState = StyleState();
    styleState.init(context);

    final readerScreenState = context.read<ReaderScreenState>();
    epubViewerController = EpubViewerController(
      onPageChanged: onPageChanged,
      initialLocation: readerScreenState.initialLocation,
    );

    panelController = PanelController();
    tocDrawerController = TOCDrawerController(
      onNavigate: onNavigate,
      initialLocation: readerScreenState.initialLocation,
    );

    panelController.addListener(_changeSystemBarsVisibility);
    _changeSystemBarsVisibility();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (styleState.isInitialized) {
      styleState.themeData = Theme.of(context);
    }
  }

  Future<void> _changeSystemBarsVisibility() async {
  }

  @override
  dispose() {
    super.dispose();

    epubViewerController.dispose();
    panelController.dispose();
    tocDrawerController.dispose();
  }

  void onNavigate(NavigationPoint point) {
    final readerScreenState = context.read<ReaderScreenState>();

    final contentLocation =
        readerScreenState.navigation.getFirstContentLocation(point.location)!;
    setState(() {
      final initialLocation = PageLocation.firstPageOf(contentLocation);
      epubViewerController.resetInitialLocation(initialLocation);
      onPageChanged(initialLocation);
    });
  }

  void onPageChanged(PageLocation pageLocation) {
    final readerScreenState = context.read<ReaderScreenState>();

    tocDrawerController.currentLocation = pageLocation;

    final booksState = context.read<BooksState>();
    final bookInfo = booksState.getBookInfo(readerScreenState.relativePath);

    booksState.updateBookInfoTemp(
      bookInfo.copyWith(
        lastReadLocation: pageLocation,
        lastReadTitle: readerScreenState.navigation
            .getPointByLocation(pageLocation.contentLocation.pointLocation)!
            .label,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: styleState,
      child: Consumer<StyleState>(
        builder: (context, state, _) {
          if (state.isInitialized) {
            return _buildBody(context);
          } else {
            return const Scaffold(
              body: Center(
                child: Text('正在加载中...'),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (details) {
          // 根据区域判断是打开 panel 还是进行翻页
          if (details.localPosition.dx < width / 4) {
            panelController.closePanel();
            epubViewerController.gestureConsumer.consumeTapUp(details);
          } else if (details.localPosition.dx > width * 3 / 4) {
            panelController.closePanel();
            epubViewerController.gestureConsumer.consumeTapUp(details);
          } else {
            panelController.togglePanel();
          }
          setState(() {});
        },
        onHorizontalDragStart: (details) {
          panelController.closePanel();
          epubViewerController.gestureConsumer
              .consumeHorizontalDragStart(details);
          setState(() {});
        },
        onHorizontalDragUpdate: (details) {
          epubViewerController.gestureConsumer
              .consumeHorizontalDragUpdate(details);
        },
        onHorizontalDragEnd: (details) {
          epubViewerController.gestureConsumer
              .consumeHorizontalDragEnd(details);
          setState(() {});
        },
        onHorizontalDragCancel: () {
          epubViewerController.gestureConsumer.consumeHorizontalDragCancel();
          setState(() {});
        },
        onHorizontalDragDown: (details) {
          epubViewerController.gestureConsumer
              .consumeHorizontalDragDown(details);
        },
        child: Stack(
          children: [
            EpubViewer(
              key: ValueKey(epubViewerController.initialLocation),
              controller: epubViewerController,
            ),
            Panel(controller: panelController),
          ],
        ),
      ),
      drawer: TOCDrawer(controller: tocDrawerController),
      drawerEnableOpenDragGesture: false,
    );
  }
}
