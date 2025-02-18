import 'location.dart';

class NavigationPoint {
  final String label;
  final List<String> contentHrefs;
  final List<NavigationPoint> children;

  final PointLocation location;

  NavigationPoint({
    required this.label,
    required this.contentHrefs,
    required this.children,
    required this.location,
  });

  int get depth => location.depth;

  @override
  String toString() {
    return 'NavigationPoint{label: $label, contentHrefs: $contentHrefs, children: $children, location: $location}';
  }
}

/// 树形结构，每个节点包含若干个 Href 表示属于它的内容
class Navigation {
  final NavigationPoint rootPoint;

  late final Map<PointLocation, NavigationPoint> _pointLocationToPoint;
  late final Map<String, ContentLocation> _hrefToLocation;

  ContentLocation? _firstLocation;
  ContentLocation? _lastLocation;

  late final List<PointLocation> allPointLocations;

  Navigation({
    required this.rootPoint,
  }) {
    _pointLocationToPoint = {};
    _hrefToLocation = {};
    allPointLocations = [];
    _populatePoint(rootPoint);
  }

  ContentLocation get firstLocation => _firstLocation!;
  ContentLocation get lastLocation => _lastLocation!;

  NavigationPoint get firstPoint => getPointByLocation(firstLocation.pointLocation)!;
  NavigationPoint get lastPoint => getPointByLocation(lastLocation.pointLocation)!;

  void _populatePoint(NavigationPoint navigationPoint) {
    _pointLocationToPoint[navigationPoint.location] = navigationPoint;
    allPointLocations.add(navigationPoint.location);

    for (final (index, href) in navigationPoint.contentHrefs.indexed) {
      final location =
          ContentLocation(pointLocation: navigationPoint.location, index: index);
      _hrefToLocation[href] = location;

      _firstLocation ??= location;
      _lastLocation = location;
    }

    for (final child in navigationPoint.children) {
      _populatePoint(child);
    }
  }

  NavigationPoint? getPointByLocation(PointLocation location) {
    return _pointLocationToPoint[location];
  }

  NavigationPoint? parentOf(NavigationPoint point) {
    final parentLocation = point.location.parent;
    return parentLocation == null ? null : getPointByLocation(parentLocation);
  }

  String? getHrefByLocation(ContentLocation location) {
    final point = getPointByLocation(location.pointLocation);
    return point?.contentHrefs[location.index];
  }

  ContentLocation? getLocationByHref(String href) {
    return _hrefToLocation[href];
  }

  /// 获取指定位置的下一个位置
  PointLocation? getNextPointLocation(PointLocation location) {
    final point = getPointByLocation(location)!;

    // 如果有子节点，那么下一个位置就是第一个子节点的位置
    if (point.children.isNotEmpty) {
      return point.children.first.location;
    }

    // 否则，就是下一个兄弟节点的位置
    while (!location.isRoot) {
      final parentLoc = location.parent!;
      final indexOfParent = location.indexOfParent;
      final parentPoint = getPointByLocation(parentLoc)!;

      if (indexOfParent + 1 < parentPoint.children.length) {
        return parentPoint.children[indexOfParent + 1].location;
      }

      location = parentLoc;
    }

    return null;
  }

  /// 获取指定位置的上一个位置
  PointLocation? getPreviousPointLocation(PointLocation location) {
    if (location.isRoot) {
      return null;
    }

    final indexOfParent = location.indexOfParent;
    if (indexOfParent > 0) {
      final parentLoc = location.parent!;
      final parentPoint = getPointByLocation(parentLoc)!;
      return parentPoint.children[indexOfParent - 1].location;
    }

    return location.parent;
  }

  /// 按照遍历顺序获取第一个内容位置
  ContentLocation? getFirstContentLocation(
    PointLocation location, {
    bool includeSelf = true,
  }) {
    PointLocation? currentLocation =
        includeSelf ? location : getNextPointLocation(location);

    while (currentLocation != null) {
      final point = getPointByLocation(currentLocation)!;

      if (point.contentHrefs.isNotEmpty) {
        return ContentLocation(pointLocation: currentLocation, index: 0);
      }

      currentLocation = getNextPointLocation(currentLocation);
    }

    return null;
  }

  /// 按照遍历顺序获取最后一个内容位置
  ContentLocation? getLastContentLocation(
    PointLocation location, {
    bool includeSelf = true,
  }) {
    PointLocation? currentLocation =
        includeSelf ? location : getPreviousPointLocation(location);

    while (currentLocation != null) {
      final point = getPointByLocation(currentLocation)!;

      if (point.contentHrefs.isNotEmpty) {
        return ContentLocation(
            pointLocation: currentLocation, index: point.contentHrefs.length - 1);
      }

      currentLocation = getPreviousPointLocation(currentLocation);
    }

    return null;
  }

  /// 按照遍历顺序获取下一个内容位置
  ContentLocation? getNextContentLocation(ContentLocation location) {
    final point = getPointByLocation(location.pointLocation)!;

    if (location.index + 1 < point.contentHrefs.length) {
      return ContentLocation(
          pointLocation: location.pointLocation, index: location.index + 1);
    }

    return getFirstContentLocation(location.pointLocation, includeSelf: false);
  }

  /// 按照遍历顺序获取上一个内容位置
  ContentLocation? getPreviousContentLocation(ContentLocation location) {
    if (location.index > 0) {
      return ContentLocation(
          pointLocation: location.pointLocation, index: location.index - 1);
    }

    return getLastContentLocation(location.pointLocation, includeSelf: false);
  }
}
