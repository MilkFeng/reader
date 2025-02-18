import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../renderer/page_renderer_controller.dart';
import 'constant.dart';

final class PageMeta {
  final Widget widget;
  final int id;
  final PageRendererController controller;
  int pageCount;
  bool completed;
  bool created;

  PageMeta({
    required this.widget,
    required this.id,
    required this.controller,
    required this.pageCount,
    required this.completed,
    required this.created,
  });

  bool get isEmpty => controller.pageLocation == null;
  bool get isNotEmpty => !isEmpty;
}

final class PageMetaList {
  late final List<PageMeta> _pages;

  PageMetaList({required List<PageMeta> pages}) {
    assert(pages.length == kSymmetricPageCount * 2 + 1);
    _pages = pages;
  }

  int _toRealIndex(int index) {
    return index + kSymmetricPageCount;
  }

  int _toLogicalIndex(int index) {
    return index - kSymmetricPageCount;
  }

  bool isAllowedIndex(int index) {
    return index >= -kSymmetricPageCount && index <= kSymmetricPageCount;
  }

  PageMeta operator [](int index) {
    return _pages[_toRealIndex(index)];
  }

  void operator []=(int index, PageMeta page) {
    _pages[_toRealIndex(index)] = page;
  }

  int getIndexById(int id) {
    final realIndex = _pages.indexWhere((page) => page.id == id);
    return _toLogicalIndex(realIndex);
  }

  void cycleLeft() {
    final first = _pages.removeAt(0);
    _pages.add(first);
  }

  void cycleRight() {
    final last = _pages.removeLast();
    _pages.insert(0, last);
  }

  factory PageMetaList.generate(PageMeta Function(int id) pageBuilder) {
    final pages = List.generate(
      kSymmetricPageCount * 2 + 1,
      (index) {
        return pageBuilder(index);
      },
    );

    return PageMetaList(pages: pages);
  }

  List<T> generate<T>(T Function(int, PageMeta) builder) {
    return _pages.reversed.mapIndexed((index, page) {
      return builder(_toLogicalIndex(_pages.length - index - 1), page);
    }).toList();
  }

  void dispose() {
    for (final page in _pages) {
      page.controller.dispose();
    }
  }

  PageMetaList get snapshot {
    final List<PageMeta> snapShotPages = [];
    for (final page in _pages) {
      snapShotPages.add(page);
    }
    return PageMetaList(pages: snapShotPages);
  }

  bool get allPagesCreated => _pages.every((page) => page.created);

  PageMeta get current => this[0];
  int get currentIndex => 0;

  PageMeta get next => this[1];
  int get nextIndex => 1;

  PageMeta get previous => this[-1];
  int get previousIndex => -1;

  PageMeta get first => _pages.first;
  int get firstIndex => -kSymmetricPageCount;

  PageMeta get second => _pages[1];
  int get secondIndex => -kSymmetricPageCount + 1;

  PageMeta get last => _pages.last;
  int get lastIndex => kSymmetricPageCount;

  PageMeta get lastSecond => _pages[_pages.length - 2];
  int get lastSecondIndex => kSymmetricPageCount - 1;
}
