import 'package:quiver/core.dart';

import '../../../epub/epub.dart';

class PageLocation {
  final ContentLocation contentLocation;
  final int pageIndex;

  PageLocation({
    required this.contentLocation,
    required this.pageIndex,
  });

  @override
  String toString() => '$contentLocation#$pageIndex';

  @override
  bool operator ==(Object other) {
    if (other is PageLocation) {
      return contentLocation == other.contentLocation &&
          pageIndex == other.pageIndex;
    }
    return false;
  }

  @override
  int get hashCode => hash2(contentLocation.hashCode, pageIndex.hashCode);

  PointLocation get pointLocation => contentLocation.pointLocation;

  factory PageLocation.firstPageOf(ContentLocation contentLocation) {
    return PageLocation(
      contentLocation: contentLocation,
      pageIndex: 0,
    );
  }

  PageLocation copyWith({
    ContentLocation? contentLocation,
    int? pageIndex,
  }) {
    return PageLocation(
      contentLocation: contentLocation ?? this.contentLocation,
      pageIndex: pageIndex ?? this.pageIndex,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'position': contentLocation.pointLocation.position,
      'content_index': contentLocation.index,
      'page_index': pageIndex,
    };
  }

  factory PageLocation.fromJson(Map<String, dynamic> json) {
    return PageLocation(
      contentLocation: ContentLocation(
        pointLocation: PointLocation(
          position: List<int>.from(json['position']),
        ),
        index: json['content_index'],
      ),
      pageIndex: json['page_index'],
    );
  }
}

extension NavigationPaginationExt on Navigation {
  PageLocation? getNextPageLocation(PageLocation? pageLocation, int pageCount) {
    if (pageLocation == null) {
      return null;
    }

    if (pageLocation.pageIndex + 1 < pageCount) {
      return PageLocation(
        contentLocation: pageLocation.contentLocation,
        pageIndex: pageLocation.pageIndex + 1,
      );
    } else {
      final nextContentLocation =
          getNextContentLocation(pageLocation.contentLocation);
      if (nextContentLocation != null) {
        return PageLocation(
          contentLocation: nextContentLocation,
          pageIndex: 0,
        );
      }
    }
    return null;
  }

  PageLocation? getPreviousPageLocation(PageLocation? pageLocation) {
    if (pageLocation == null) {
      return null;
    }

    if (pageLocation.pageIndex > 0) {
      return PageLocation(
        contentLocation: pageLocation.contentLocation,
        pageIndex: pageLocation.pageIndex - 1,
      );
    } else {
      final previousContentLocation =
          getPreviousContentLocation(pageLocation.contentLocation);
      if (previousContentLocation != null) {
        return PageLocation(
          contentLocation: previousContentLocation,
          pageIndex: 100000000,
        );
      }
    }
    return null;
  }
}
