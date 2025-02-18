import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:provider/provider.dart';

import '../../../../managers/meta/models.dart';
import '../../../../managers/settings/models.dart';
import '../../reader_screen_state.dart';
import '../common/gesture_consumer.dart';
import '../renderer/js_bridge_ext.dart';
import '../renderer/page_renderer.dart';
import '../renderer/page_renderer_controller.dart';
import '../style_state.dart';
import 'epub_viewer_controller.dart';
import 'page_meta.dart';
import 'single_load_manager.dart';

enum _FlingDirection {
  previous,
  current,
  next,
  none,
}

class EpubViewer extends StatefulWidget {
  const EpubViewer({super.key, required this.controller});

  final EpubViewerController controller;

  @override
  State<EpubViewer> createState() => _EpubViewerState();
}

class _EpubViewerState extends State<EpubViewer> with TickerProviderStateMixin {
  static final springDescription = SpringDescription.withDampingRatio(
    mass: 1,
    stiffness: 200,
    ratio: 1.0,
  );

  late final PageMetaList pages;

  late bool isDragging;
  late final ValueNotifier<double> dragProgress;

  late AnimationController animationController;
  late _FlingDirection flingDirection;

  EpubViewerController get controller => widget.controller;

  late PageLocation _initialLocation;
  late SingleLoadManager<(PageMeta, PageLocation?), PageLoadedDetail?>
      _singleLoadManager;

  @override
  void initState() {
    super.initState();
    _singleLoadManager = SingleLoadManager(
      onLoad: loadPage2,
      onCancel: cancelLoadPage,
    );

    pages = PageMetaList.generate((id) {
      final controller = PageRendererController();
      return PageMeta(
        id: id,
        widget: PageRenderer(
          controller: controller,
          onCreated: () {
            pages[pages.getIndexById(id)].created = true;
            if (pages.allPagesCreated) {
              onCreated();
            }
          },
        ),
        controller: controller,
        pageCount: 0,
        completed: false,
        created: false,
      );
    });

    isDragging = false;
    dragProgress = ValueNotifier(0.0);

    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    flingDirection = _FlingDirection.none;

    controller.registerGestureConsumer(
      GestureConsumer(
        consumeHorizontalDragStart: consumeHorizontalDragStart,
        consumeHorizontalDragUpdate: consumeHorizontalDragUpdate,
        consumeHorizontalDragEnd: consumeHorizontalDragEnd,
        consumeHorizontalDragDown: consumeHorizontalDragDown,
        consumeHorizontalDragCancel: consumeHorizontalDragCancel,
        consumeTapUp: consumeTapUp,
      ),
    );

    _initialLocation = controller.initialLocation;

    controller.addListener(reload);
    context.read<StyleState>().addListener(reload);
  }

  @override
  void dispose() {
    super.dispose();

    _singleLoadManager.dispose();
    animationController.dispose();
    dragProgress.dispose();
    pages.dispose();
  }

  void onCreated() async {
    await load(controller.initialLocation);
  }

  Future<void> loadToNextDirection(
      PageMetaList snapshot, PageLocation? nextPageLocation) async {
    final navigation = context.read<ReaderScreenState>().navigation;

    PageLocation? location = nextPageLocation;
    for (var index = pages.nextIndex; index <= pages.lastIndex; index++) {
      final page = snapshot[index];
      final derail = await _singleLoadManager.load(page.id, (page, location));
      if (derail == null) break;
      location = navigation.getNextPageLocation(
        page.controller.pageLocation,
        derail.viewPortInfo.pageCount,
      );
    }
  }

  Future<void> loadToPreviousDirection(
      PageMetaList snapshot, PageLocation? previousPageLocation) async {
    final navigation = context.read<ReaderScreenState>().navigation;

    PageLocation? location = previousPageLocation;
    for (var index = pages.previousIndex; index >= pages.firstIndex; index--) {
      final page = snapshot[index];
      final detail = await _singleLoadManager.load(page.id, (page, location));
      if (detail == null) break;
      location =
          navigation.getPreviousPageLocation(page.controller.pageLocation);
    }
  }

  Future<void> load(PageLocation? currentPageLocation) async {
    final snapshot = pages.snapshot;

    // 清空所有的 pageLocation
    for (var index = snapshot.firstIndex;
        index <= snapshot.lastIndex;
        index++) {
      snapshot[index].controller.pageLocation = null;
    }

    // 先加载当前页
    final detail = await loadPage(snapshot.current, currentPageLocation);

    // 如果加载失败，那么不加载其他页
    if (detail == null) return;

    final navigation = context.read<ReaderScreenState>().navigation;

    // 向两侧加载
    final nextPageLocation = navigation.getNextPageLocation(
      snapshot.current.controller.pageLocation,
      detail.viewPortInfo.pageCount,
    );
    final previousPageLocation =
        navigation.getPreviousPageLocation(currentPageLocation);

    await Future.wait([
      loadToNextDirection(snapshot, nextPageLocation),
      loadToPreviousDirection(snapshot, previousPageLocation),
    ]);
  }

  Future<void> reload() async {
    PageLocation? pageLocation;

    if (_initialLocation != controller.initialLocation) {
      _initialLocation = controller.initialLocation;
      pageLocation = _initialLocation;
    } else {
      pageLocation = pages.current.controller.pageLocation;
    }

    for (var index = pages.firstIndex; index <= pages.lastIndex; index++) {
      pages[index].controller.style = context.read<StyleState>().style;
    }

    await load(pageLocation);
  }

  PageLocation? correctPageLocation(PageMeta page, PageInfo pageInfo) {
    final location = page.controller.pageLocation;
    if (location != null && location.pageIndex != pageInfo.pageIndex) {
      page.controller.pageLocation = PageLocation(
        contentLocation: location.contentLocation,
        pageIndex: pageInfo.pageIndex,
      );
    }
    return page.controller.pageLocation;
  }

  Future<PageLoadedDetail?> loadPage(
      PageMeta page, PageLocation? location) async {
    page.completed = false;

    setState(() {});

    final style = context.read<StyleState>().style;

    page.controller.pageLocation = location;
    page.controller.style = style;

    final detail = await page.controller.load();
    page.completed = true;

    setState(() {});

    if (detail != null) {
      correctPageLocation(page, detail.pageInfo);
      page.pageCount = detail.viewPortInfo.pageCount;
    }

    return detail;
  }

  Future<PageLoadedDetail?> loadPage2(
      int id, (PageMeta, PageLocation?) args) async {
    return await loadPage(args.$1, args.$2);
  }

  Future<void> cancelLoadPage(int id, (PageMeta, PageLocation?) args) async {
    await args.$1.controller.cancel();
  }

  void paginateToNext() {
    // 将最左侧一页放到最右侧，加载这一页的内容
    pages.cycleLeft();

    final navigation = context.read<ReaderScreenState>().navigation;

    final nextPageLocation = navigation.getNextPageLocation(
      pages.lastSecond.controller.pageLocation,
      pages.lastSecond.pageCount,
    );
    _singleLoadManager.load(pages.last.id, (pages.last, nextPageLocation));
    controller.onPageChanged(
      pages.current.controller.pageLocation!,
    );

    setState(() {});
  }

  void paginateToPrevious() {
    // 将最右侧一页放到最左侧，加载这一页的内容
    pages.cycleRight();

    final navigation = context.read<ReaderScreenState>().navigation;

    final previousPageLocation = navigation.getPreviousPageLocation(
      pages.second.controller.pageLocation,
    );
    _singleLoadManager
        .load(pages.first.id, (pages.first, previousPageLocation));
    controller.onPageChanged(
      pages.current.controller.pageLocation!,
    );
    setState(() {});
  }

  void removeAllAnimationListeners() {
    animationController
        .removeListener(_changeDragProgressForAnimatedPaginateToNext);
    animationController
        .removeListener(_changeDragProgressForAnimatedPaginateToPrevious);
    animationController
        .removeListener(_changeDragProgressForAnimatedToCurrentPage);
  }

  void _changeDragProgressForAnimatedPaginateToNext() {
    dragProgress.value = -animationController.value;
  }

  void animatedPaginateToNext(double velocity) async {
    // dragProgress 从当前值到 -1
    flingDirection = _FlingDirection.next;
    final spring =
        SpringSimulation(springDescription, -dragProgress.value, 1, -velocity);

    animationController.reset();
    removeAllAnimationListeners();
    animationController
        .addListener(_changeDragProgressForAnimatedPaginateToNext);
    await animationController.animateWith(spring);
    dragProgress.value = 0.0;
    paginateToNext();

    flingDirection = _FlingDirection.none;
  }

  void _changeDragProgressForAnimatedPaginateToPrevious() {
    dragProgress.value = animationController.value;
  }

  void animatedPaginateToPrevious(double velocity) async {
    flingDirection = _FlingDirection.previous;
    // dragProgress 从当前值到 1
    final spring =
        SpringSimulation(springDescription, dragProgress.value, 1, velocity);

    animationController.reset();
    removeAllAnimationListeners();
    animationController
        .addListener(_changeDragProgressForAnimatedPaginateToPrevious);
    await animationController.animateWith(spring);

    dragProgress.value = 0.0;
    paginateToPrevious();

    flingDirection = _FlingDirection.none;
  }

  void _changeDragProgressForAnimatedToCurrentPage() {
    dragProgress.value = animationController.value * 2 - 1;
  }

  void animatedPaginateToCurrent(double velocity) async {
    flingDirection = _FlingDirection.current;
    // dragProgress 从当前值到 0
    final spring = SpringSimulation(
        springDescription, dragProgress.value / 2 + 0.5, 0.5, velocity);

    animationController.reset();
    removeAllAnimationListeners();
    animationController
        .addListener(_changeDragProgressForAnimatedToCurrentPage);
    await animationController.animateWith(spring);

    dragProgress.value = 0.0;
    flingDirection = _FlingDirection.none;
  }

  bool get hasPreviousPage => pages.previous.isNotEmpty;

  bool get hasNextPage => pages.next.isNotEmpty;

  void forceFlingToNext() {
    animationController.stop();
    removeAllAnimationListeners();
    dragProgress.value = 0.0;
    paginateToNext();

    flingDirection = _FlingDirection.none;
  }

  void forceFlingToPrevious() {
    animationController.stop();
    removeAllAnimationListeners();
    dragProgress.value = 0.0;
    paginateToPrevious();

    flingDirection = _FlingDirection.none;
  }

  void forceFlingToCurrent() {
    animationController.stop();
    removeAllAnimationListeners();
    dragProgress.value = 0.0;

    flingDirection = _FlingDirection.none;
  }

  void forceFling() {
    if (flingDirection == _FlingDirection.next) {
      forceFlingToNext();
    } else if (flingDirection == _FlingDirection.previous) {
      forceFlingToPrevious();
    } else if (flingDirection == _FlingDirection.current) {
      forceFlingToCurrent();
    }
  }

  bool consumeTapUp(TapUpDetails details) {
    // 根据点击位置判断是翻前一页还是翻后一页
    final width = MediaQuery.of(context).size.width;
    if (details.localPosition.dx < width / 2) {
      if (hasPreviousPage) {
        forceFling();
        animatedPaginateToPrevious(0);
      }
    } else {
      if (hasNextPage) {
        forceFling();
        animatedPaginateToNext(0);
      }
    }

    return true;
  }

  bool consumeHorizontalDragStart(DragStartDetails details) {
    forceFling();
    isDragging = true;
    dragProgress.value = 0;
    return true;
  }

  bool consumeHorizontalDragUpdate(DragUpdateDetails details) {
    final width = MediaQuery.of(context).size.width;
    if (!isDragging || flingDirection != _FlingDirection.none) {
      return true;
    }

    var delta = details.primaryDelta! / width;
    if (delta.abs() > 0.3) {
      delta = delta.sign * 0.3;
    }
    dragProgress.value += delta;

    if (!hasPreviousPage && dragProgress.value > 0) {
      dragProgress.value = 0;
    } else if (!hasNextPage && dragProgress.value < 0) {
      dragProgress.value = 0;
    }

    return true;
  }

  bool consumeHorizontalDragEnd(DragEndDetails details) {
    final width = MediaQuery.of(context).size.width;
    final velocity = details.primaryVelocity! / width;

    if (!isDragging || flingDirection != _FlingDirection.none) {
      return true;
    }

    isDragging = false;

    if (hasPreviousPage &&
        ((dragProgress.value > 1 / 2 && velocity > -0.2) ||
            (dragProgress.value > 0 && velocity > 0.2))) {
      animatedPaginateToPrevious(velocity);
    } else if (hasNextPage &&
        ((dragProgress.value < -1 / 2 && velocity < 0.2) ||
            (dragProgress.value < 0 && velocity < -0.2))) {
      animatedPaginateToNext(velocity);
    } else {
      if (dragProgress.value > 0) {
        if (hasPreviousPage) {
          animatedPaginateToCurrent(max(velocity, 0));
        } else {
          dragProgress.value = 0;
        }
      } else {
        if (hasNextPage) {
          animatedPaginateToCurrent(min(velocity, 0));
        } else {
          dragProgress.value = 0;
        }
      }
    }

    return true;
  }

  bool consumeHorizontalDragDown(DragDownDetails details) {
    return true;
  }

  bool consumeHorizontalDragCancel() {
    isDragging = false;
    forceFling();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final top = MediaQuery.of(context).viewPadding.top;
    final bottom = MediaQuery.of(context).viewPadding.bottom;

    return RepaintBoundary(
      child: ClipRect(
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: pages.generate((index, page) {
            return ValueListenableBuilder<double>(
              key: ValueKey(page.id),
              valueListenable: dragProgress,
              builder: (context, value, child) {
                final transform = controller.pageTransition
                    .calculateTransform(value, index, size);

                return Transform(
                  transform: transform,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          offset: Offset(0, 0),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Selector<StyleState, AppStyle>(
                      selector: (context, styleState) => styleState.appStyle,
                      builder: (context, appStyle, child) {
                        return Stack(
                          key: ValueKey(page.id),
                          children: [
                            Container(
                              color: appStyle.backgroundColor,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: appStyle.padding,
                                  right: appStyle.padding,
                                  top: top + appStyle.padding,
                                  bottom: bottom + appStyle.padding,
                                ),
                                child: page.widget,
                              ),
                            ),
                            if (!page.completed)
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  color: appStyle.backgroundColor,
                                  child: Center(
                                    child: Text('正在加载中...'),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                      child: page.widget,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
