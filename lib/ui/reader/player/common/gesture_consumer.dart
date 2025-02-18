import 'package:flutter/material.dart';

bool _emptyConsumer(dynamic _) => false;
bool _emptyConsumerNoArg() => false;

class GestureConsumer {
  final bool Function(DragStartDetails) consumeHorizontalDragStart;
  final bool Function(DragUpdateDetails) consumeHorizontalDragUpdate;
  final bool Function(DragEndDetails) consumeHorizontalDragEnd;
  final bool Function(DragDownDetails) consumeHorizontalDragDown;
  final bool Function() consumeHorizontalDragCancel;

  final bool Function(TapUpDetails) consumeTapUp;
  final bool Function(TapDownDetails) consumeTapDown;

  GestureConsumer({
    this.consumeHorizontalDragStart = _emptyConsumer,
    this.consumeHorizontalDragUpdate = _emptyConsumer,
    this.consumeHorizontalDragEnd = _emptyConsumer,
    this.consumeHorizontalDragDown = _emptyConsumer,
    this.consumeHorizontalDragCancel = _emptyConsumerNoArg,
    this.consumeTapUp = _emptyConsumer,
    this.consumeTapDown = _emptyConsumer,
  });
}
