import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../epub/epub.dart';
import '../../../../managers/meta/models.dart';
import '../../../../settings_state.dart';
import '../../../common/image.dart';
import '../../reader_screen_state.dart';

class TOCDrawerController extends ChangeNotifier {
  TOCDrawerController({
    required this.onNavigate,
    PageLocation? initialLocation,
  }) : _currentLocation = initialLocation;

  PageLocation? _currentLocation;

  PageLocation? get currentLocation => _currentLocation;

  set currentLocation(PageLocation? value) {
    _currentLocation = value;
    notifyListeners();
  }

  Function(NavigationPoint) onNavigate;
}

class TOCDrawer extends StatefulWidget {
  const TOCDrawer({super.key, required this.controller});

  final TOCDrawerController controller;

  @override
  State<TOCDrawer> createState() => _TOCDrawerState();
}

class _TOCDrawerState extends State<TOCDrawer> {
  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  TOCDrawerController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    final readerScreenState = context.read<ReaderScreenState>();

    final top = MediaQuery.of(context).padding.top;

    final settingsState = context.read<SettingsState>();
    final metadata = readerScreenState.metadata;
    final bookInfo = readerScreenState.bookInfo;
    final navigation = readerScreenState.navigation;

    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: top),
            child: ListTile(
              title: Text(metadata.titles.first),
              subtitle: Text(metadata.authors.join(', ')),
              leading: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                ),
                clipBehavior: Clip.antiAlias,
                child: bookInfo.coverRelativePath != null
                    ? CustomImageWidget.custom(
                        settingsState.rootPath!,
                        bookInfo.coverRelativePath!,
                      )
                    : Image.asset("assets/images/cover.png"),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Divider(height: 0),
          ),
          Expanded(
            child: _TOCWidget(
              navigation: navigation,
              onNavigate: controller.onNavigate,
              currentLocation: controller.currentLocation?.pointLocation,
            ),
          ),
        ],
      ),
    );
  }
}

class _TOCWidget extends StatefulWidget {
  const _TOCWidget({
    super.key,
    required this.navigation,
    required this.onNavigate,
    required this.currentLocation,
  });

  final Navigation navigation;

  final Function(NavigationPoint) onNavigate;
  final PointLocation? currentLocation;

  @override
  State<_TOCWidget> createState() => _TOCWidgetState();
}

class _TOCWidgetState extends State<_TOCWidget> {
  late final ScrollController scrollController;

  @override
  void initState() {
    super.initState();

    if (widget.currentLocation == null) {
      scrollController = ScrollController();
    } else {
      final offset = getOffset(widget.currentLocation!);
      scrollController = ScrollController(
        initialScrollOffset: offset,
      );
    }
  }

  @override
  void didUpdateWidget(covariant _TOCWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentLocation != widget.currentLocation) {
      setState(() {});
    }
  }

  double getOffset(PointLocation pointLocation) {
    final index =
        widget.navigation.allPointLocations.indexOf(pointLocation) - 1;
    return index * 48.0;
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Scrollbar(
        controller: scrollController,
        child: ListView.builder(
          controller: scrollController,
          padding: EdgeInsets.only(bottom: bottom),
          itemCount: widget.navigation.allPointLocations.length - 1,
          itemBuilder: (context, index) {
            final pointLocation =
                widget.navigation.allPointLocations[index + 1];
            final point = widget.navigation.getPointByLocation(pointLocation)!;
            final selected = pointLocation == widget.currentLocation;
            final title = point.label;
            return InkWell(
              onTap: () {
                widget.onNavigate(point);
              },
              child: Container(
                padding: EdgeInsets.only(
                  left: point.depth * 16,
                  right: 16.0,
                ),
                alignment: Alignment.centerLeft,
                height: 48.0,
                child: Text(
                  title,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    color: selected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
