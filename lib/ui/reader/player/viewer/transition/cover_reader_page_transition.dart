import 'package:flutter/material.dart';

import 'reader_page_transition.dart';

class CoverReaderPageTransition extends ReaderPageTransition {
  @override
  Matrix4 calculateTransform(double progress, int index, Size pageSize) {
    double left = 0;

    if (index < -1) {
      left = -pageSize.width;
    } else if (index > 1) {
      left = pageSize.width;
    } else if (index == 0) {
      if (progress < 0) {
        // 向左翻页时，current page 会向左移动
        left = progress * pageSize.width;
      } else {
        // 向右翻页时，current page 不移动
        left = 0;
      }
    } else if (index == 1) {
      left = 0;
    } else {
      if (progress < 0) {
        // 向左翻页时，previous page 不移动
        left = -pageSize.width;
      } else {
        // 向右翻页时，previous page 会向右移动
        left = progress * pageSize.width - pageSize.width;
      }
    }

    return Matrix4.translationValues(left, 0, 0);
  }
}
