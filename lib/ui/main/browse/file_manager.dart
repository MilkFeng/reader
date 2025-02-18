import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'browse_page_state.dart';
import 'file_tile.dart';

class FileManager extends StatelessWidget {
  const FileManager({super.key});

  Widget buildList(BuildContext context) {
    final explorePageState = context.watch<BrowsePageState>();

    return ListView.builder(
      primary: false,
      controller: explorePageState.scrollController,
      padding: const EdgeInsets.all(0),
      itemCount: explorePageState.subEntities.length,
      itemBuilder: (context, index) {
        final entity = explorePageState.subEntities[index];
        final imported = explorePageState.isImported(entity);

        return FileTile(
          entity: entity,
          onClick: (entity) {
            if (entity.isFile) {
              if (explorePageState.selecting) {
                // 如果是选择模式
                explorePageState.toggleSelect(entity);

                // 如果当前没有选中的文件，那么退出选择模式
                if (explorePageState.selectedEntities.isEmpty) {
                  explorePageState.exitSelecting();
                }
              } else {
                // 如果不是选择模式
                if (imported) {
                  // 如果已经导入，什么都不做
                } else {
                  // 进入选择模式，选中当前文件
                  explorePageState.enterSelecting();
                  explorePageState.toggleSelect(entity);
                }
              }
            } else {
              explorePageState.openDirectory(entity);
            }
          },
          imported: imported,
          selecting: explorePageState.selecting,
          selected: explorePageState.selectedEntities.contains(entity),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final explorePageState = context.watch<BrowsePageState>();
    final isRoot = explorePageState.entitiesStack.isEmpty ||
        explorePageState.entitiesStack.length == 1;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Builder(builder: (context) {
        if (explorePageState.state == BrowsePageLoadState.error) {
          return Center(child: Text('加载失败'));
        } else {
          final body = buildList(context);
          final scrollBar = MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: Scrollbar(
              child: body,
            ),
          );
          if (isRoot && !explorePageState.selecting) {
            return scrollBar;
          } else {
            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (explorePageState.selecting) {
                  explorePageState.exitSelecting();
                } else {
                  explorePageState.goToParentDirectory();
                }
              },
              child: scrollBar,
            );
          }
        }
      }),
    );
  }
}
