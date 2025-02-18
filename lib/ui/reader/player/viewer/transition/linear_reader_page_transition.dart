import 'package:flutter/material.dart';

import 'reader_page_transition.dart';

class LinearReaderPageTransition extends ReaderPageTransition {
  @override
  Matrix4 calculateTransform(double progress, int index, Size pageSize) {
    final left = (index + progress) * pageSize.width;

    return Matrix4.translationValues(left, 0, 0);
  }
}
