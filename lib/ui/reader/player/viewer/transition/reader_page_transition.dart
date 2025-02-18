import 'package:flutter/material.dart';

import '../constant.dart';

enum PaginationDirection {
  toPrevious,
  toCurrent,
  toNext,
}

abstract class ReaderPageTransition {
  /// Calculate the transform matrix for the page at [index] with [progress].
  ///
  /// [progress] is a value between -1 and 1, where -1 means the page is fully
  /// to the left, 0 means the page is centered, and 1 means the page is fully
  /// to the right.
  ///
  /// [index] is the index of the page in the list of pages.
  /// index -[kSymmetricPageCount] <= index <= [kSymmetricPageCount], where
  /// 0 is the index of the current page and -1 is the index of the previous
  /// page.
  Matrix4 calculateTransform(double progress, int index, Size pageSize);
}
