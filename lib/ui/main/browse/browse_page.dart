import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/fs_utils.dart';
import '../../../../books_state.dart';
import '../../../settings_state.dart';
import '../../common/dialog.dart';
import 'breadcrumbs.dart';
import 'browse_page_state.dart';
import 'file_manager.dart';
import 'import_book_dialog.dart';

class BrowsePage extends StatefulWidget {
  const BrowsePage({super.key});

  static NavigationDestination get destination => NavigationDestination(
        selectedIcon: Icon(Icons.explore),
        icon: Icon(Icons.explore_outlined),
        label: '浏览',
      );

  @override
  State<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ChangeNotifierProxyProvider2<BooksState, SettingsState,
        BrowsePageState?>(
      create: (context) => null,
      update: (context, booksState, settingsState, oldExplorePageState) {
        if (oldExplorePageState == null ||
            oldExplorePageState.settingsState.rootPath !=
                settingsState.rootPath) {
          return BrowsePageState(
            booksState: booksState,
            settingsState: settingsState,
          )..openRootDirectory();
        } else {
          return oldExplorePageState
            ..booksState = booksState
            ..settingsState = settingsState;
        }
      },
      child: Consumer<BrowsePageState?>(
        builder: (context, explorePageState, _) {
          if (explorePageState == null) {
            return const SizedBox();
          }

          final PreferredSizeWidget appBar =
              explorePageState.selecting ? _SelectingAppBar() : _NormalAppBar();

          final Widget content;
          if (explorePageState.state == BrowsePageLoadState.error) {
            content = Center(child: Text('请先选择文件夹'));
          } else {
            content = FileManager();
          }

          final breadcrumbsHeight = Breadcrumbs.preferredHeight;

          return Column(
            children: [
              appBar,
              AnimatedContainer(
                height: explorePageState.selecting ? 0 : breadcrumbsHeight,
                duration: Duration(milliseconds: 200),
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(),
                child: Container(
                  height: breadcrumbsHeight,
                  color: explorePageState.selecting
                      ? Theme.of(context).colorScheme.surfaceContainer
                      : Theme.of(context).colorScheme.surface,
                  child: explorePageState.selecting ? null : Breadcrumbs(),
                ),
              ),
              Expanded(child: content),
            ],
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _SelectingAppBar extends StatefulWidget implements PreferredSizeWidget {
  const _SelectingAppBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  State<_SelectingAppBar> createState() => _SelectingAppBarState();
}

class _SelectingAppBarState extends State<_SelectingAppBar> {
  @override
  void initState() {
    super.initState();
  }

  void showImportDialog(BuildContext context) {
    final explorePageState = context.read<BrowsePageState>();
    showCustomDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return ImportBookDialog(explorePageState: explorePageState);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final explorePageState = context.read<BrowsePageState>();

    return Selector<BrowsePageState, Set<Entity>>(
      selector: (context, state) => state.selectedEntities,
      builder: (context, selectedEntities, _) {
        return AppBar(
          title: Row(children: [
            Text('已选择 '),
            AnimatedFlipCounter(
              duration: Duration(milliseconds: 200),
              value: selectedEntities.length,
            ),
          ]),
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              explorePageState.exitSelecting();
            },
          ),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          actions: [
            IconButton(
              icon: Icon(Icons.clear_all),
              onPressed: () {
                explorePageState.clearSelected();
              },
            ),
            IconButton(
              icon: Icon(Icons.select_all),
              onPressed: () {
                explorePageState.selectAll();
              },
            ),
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                // 弹出对话框
                showImportDialog(context);
              },
            ),
          ],
        );
      },
    );
  }
}

class _NormalAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _NormalAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final explorePageState = context.read<BrowsePageState>();

    return Selector<BrowsePageState, List<String>>(
      selector: (context, state) => state.currentDirectoryPathSegments,
      builder: (context, pathSegments, _) {
        final isRoot = pathSegments.length <= 1;
        final title = isRoot ? '浏览' : pathSegments.last;

        return AppBar(
          title: Text(title),
          leading: isRoot
              ? null
              : IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    explorePageState.goToParentDirectory();
                  },
                ),
          actions: [
            IconButton(
              icon: Icon(Icons.folder_open),
              onPressed: () async {
                final path = await FSUtils.pickFolder(
                    writePermission: false, persistablePermission: true);
                if (path != null) {
                  explorePageState.setRootDirectory(path);
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
