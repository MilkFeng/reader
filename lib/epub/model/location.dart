import 'dart:math';

import 'package:collection/collection.dart';
import 'package:quiver/core.dart';

const _listEquality = ListEquality();

class PointLocation implements Comparable<PointLocation> {
  final List<int> position;

  PointLocation({
    required this.position,
  });

  @override
  String toString() {
    return position.join('-');
  }

  String formatString() {
    return position.map((e) => e + 1).join('.');
  }

  @override
  bool operator ==(Object other) {
    if (other is PointLocation) {
      return _listEquality.equals(position, other.position);
    }
    return false;
  }

  @override
  int get hashCode => hashObjects(position);

  static final PointLocation root = PointLocation(position: []);

  PointLocation child(int index) {
    return PointLocation(position: [...position, index]);
  }

  bool get isRoot => position.isEmpty;

  PointLocation? get parent {
    if (isRoot) {
      return null;
    }
    return PointLocation(position: position.sublist(0, position.length - 1));
  }

  int get indexOfParent => position.last;

  PointLocation clone() {
    return PointLocation(position: [...position]);
  }

  int get depth => position.length;

  static final PointLocation invalid = PointLocation(position: [-1]);

  bool get isValid => position.isNotEmpty && position.first >= 0;

  @override
  int compareTo(PointLocation other) {
    for (var i = 0; i < min(position.length, other.position.length); i++) {
      final result = position[i].compareTo(other.position[i]);
      if (result != 0) {
        return result;
      }
    }
    return position.length.compareTo(other.position.length);
  }
}

class ContentLocation implements Comparable<ContentLocation> {
  final PointLocation pointLocation;
  final int index;

  ContentLocation({
    required this.pointLocation,
    required this.index,
  });

  @override
  String toString() {
    return '${pointLocation.toString()}/$index';
  }

  @override
  bool operator ==(Object other) {
    if (other is ContentLocation) {
      return pointLocation == other.pointLocation && index == other.index;
    }
    return false;
  }

  @override
  int get hashCode => hash2(pointLocation.hashCode, index.hashCode);

  ContentLocation copyWith({
    PointLocation? position,
    int? index,
  }) {
    return ContentLocation(
      pointLocation: position ?? pointLocation,
      index: index ?? this.index,
    );
  }

  ContentLocation clone() {
    return ContentLocation(
      pointLocation: pointLocation.clone(),
      index: index,
    );
  }

  @override
  int compareTo(ContentLocation other) {
    final result = pointLocation.compareTo(other.pointLocation);
    if (result != 0) {
      return result;
    }
    return index.compareTo(other.index);
  }
}
