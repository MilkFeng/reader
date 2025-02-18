import '../location.dart';
import '../navigation.dart';

class NavigationPointBundle {
  final String label;
  final List<String> contentHrefs;
  final List<NavigationPointBundle> children;

  NavigationPointBundle({
    required this.label,
    required this.contentHrefs,
    required this.children,
  });

  factory NavigationPointBundle.fromNavigationPoint(NavigationPoint point) {
    return NavigationPointBundle(
      label: point.label,
      contentHrefs: point.contentHrefs,
      children: point.children
          .map((e) => NavigationPointBundle.fromNavigationPoint(e))
          .toList(),
    );
  }

  NavigationPoint toNavigationPoint(PointLocation location) {
    final List<NavigationPoint> children = [];
    for (final (index, childPoint) in this.children.indexed) {
      final childLocation = location.child(index);
      children.add(childPoint.toNavigationPoint(childLocation));
    }
    return NavigationPoint(
      label: label,
      contentHrefs: contentHrefs,
      children: children,
      location: location,
    );
  }

  factory NavigationPointBundle.fromJson(Map<String, dynamic> json) {
    return NavigationPointBundle(
      label: json['label'],
      contentHrefs: List<String>.from(json['content_hrefs']),
      children: List<NavigationPointBundle>.from(
          json['children'].map((e) => NavigationPointBundle.fromJson(e))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'content_hrefs': contentHrefs,
      'children': children.map((e) => e.toJson()).toList(),
    };
  }
}

class NavigationBundle {
  final NavigationPointBundle rootPoint;

  NavigationBundle({
    required this.rootPoint,
  });

  factory NavigationBundle.fromNavigation(Navigation navigation) {
    return NavigationBundle(
      rootPoint:
          NavigationPointBundle.fromNavigationPoint(navigation.rootPoint),
    );
  }

  Navigation toNavigation() {
    return Navigation(
      rootPoint: rootPoint.toNavigationPoint(PointLocation.root),
    );
  }

  factory NavigationBundle.fromJson(Map<String, dynamic> json) {
    return NavigationBundle(
      rootPoint: NavigationPointBundle.fromJson(json['root_point']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'root_point': rootPoint.toJson(),
    };
  }
}
