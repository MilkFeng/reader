
import 'package:flutter/material.dart';

import '../../../../managers/meta/models.dart';
import '../common/gesture_consumer.dart';
import 'transition/cover_reader_page_transition.dart';
import 'transition/reader_page_transition.dart';

class EpubViewerController extends ChangeNotifier {
  EpubViewerController({
    required this.onPageChanged,
    required PageLocation initialLocation,
    ReaderPageTransition? pageTransition,
  }) : _initialLocation = initialLocation {
    this.pageTransition = pageTransition ?? CoverReaderPageTransition();
  }

  GestureConsumer _gestureConsumer = GestureConsumer();
  final Function(PageLocation) onPageChanged;
  PageLocation _initialLocation;

  late ReaderPageTransition pageTransition;

  void registerGestureConsumer(GestureConsumer consumer) {
    _gestureConsumer = consumer;
  }

  void resetInitialLocation(PageLocation location) {
    _initialLocation = location;
    notifyListeners();
  }

  PageLocation get initialLocation => _initialLocation;
  GestureConsumer get gestureConsumer => _gestureConsumer;
}