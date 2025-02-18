import 'package:flutter/material.dart';

import '../../../../common/fs_utils.dart';
import '../../../../books_state.dart';
import '../../../settings_state.dart';

enum BrowsePageLoadState {
  loading,
  loaded,
  error,
}

class BrowsePageState extends ChangeNotifier {
  List<Entity> entitiesStack = [];
  List<Entity> subEntities = [];
  BrowsePageLoadState state = BrowsePageLoadState.loading;

  bool selecting = false;
  Set<Entity> selectedEntities = {};

  final ScrollController scrollController = ScrollController();

  SettingsState settingsState;
  BooksState booksState;

  BrowsePageState({
    required this.settingsState,
    required this.booksState,
  });

  Future<void> openRootDirectory() async {
    state = BrowsePageLoadState.loading;
    notifyListeners();

    try {
      final rootPlatformPath = settingsState.rootPath!;
      await openDirectory(Entity(
        platformPath: rootPlatformPath,
        name: '根目录',
        isFile: false,
        relativePath: '',
      ));

      state = BrowsePageLoadState.loaded;
    } catch (e) {
      state = BrowsePageLoadState.error;
    }

    notifyListeners();
  }

  void filterImportedEntity() {
    selectedEntities.removeWhere(isImported);
    notifyListeners();
  }

  Future<void> setRootDirectory(String path) async {
    state = BrowsePageLoadState.loading;
    notifyListeners();

    try {
      await settingsState.setRootPath(path);
      await openRootDirectory();
    } catch (e) {
      state = BrowsePageLoadState.error;
    }

    notifyListeners();
  }

  Future<void> openDirectory(Entity entity) async {
    state = BrowsePageLoadState.loading;
    notifyListeners();

    try {
      final subEntities = await _listDirectory(entity);
      entitiesStack.add(entity);
      this.subEntities = subEntities;

      state = BrowsePageLoadState.loaded;
    } catch (e) {
      state = BrowsePageLoadState.error;
    }
    notifyListeners();
  }

  Future<void> goToDirectory(int index) async {
    state = BrowsePageLoadState.loading;
    notifyListeners();

    try {
      final parentEntity = entitiesStack[index];
      final subEntities = await _listDirectory(parentEntity);

      entitiesStack = entitiesStack.sublist(0, index + 1);
      this.subEntities = subEntities;

      state = BrowsePageLoadState.loaded;
    } catch (e) {
      state = BrowsePageLoadState.error;
    }
    notifyListeners();
  }

  Future<void> goToParentDirectory() async {
    await goToDirectory(entitiesStack.length - 2);
  }

  List<Entity> _filterSubEntities(Entity entity, List<Entity> entities) {
    return entities.where((e) {
      if (!e.isFile) {
        return true;
      } else {
        return isBook(e);
      }
    }).toList();
  }

  Future<List<Entity>> _listDirectory(Entity entity) async {
    final entities = await FSUtils.listDirectory(entity);
    entities.sort((a, b) {
      if (a.isFile && !b.isFile) {
        return 1;
      } else if (!a.isFile && b.isFile) {
        return -1;
      } else {
        return a.name.compareTo(b.name);
      }
    });
    return _filterSubEntities(entity, entities);
  }

  bool isBook(Entity entity) {
    if (entity.isFile) {
      final ext = entity.name.split('.').last;
      return ['epub'].contains(ext);
    }
    return false;
  }

  bool isRootDirectory() {
    return entitiesStack.length == 1;
  }

  bool empty() {
    return entitiesStack.isEmpty;
  }

  List<String> get currentDirectoryPathSegments {
    return entitiesStack.map((e) => e.name).toList();
  }

  String get currentDirectoryPath {
    if (isRootDirectory()) {
      return "";
    } else {
      return currentDirectoryPathSegments.join('/').substring(1);
    }
  }

  String getSubPath(Entity entity) {
    return '$currentDirectoryPath/${entity.name}';
  }

  void toggleSelect(Entity entity) {
    if (isImported(entity)) {
      selectedEntities.remove(entity);
      notifyListeners();
      return;
    }
    if (selectedEntities.contains(entity)) {
      selectedEntities.remove(entity);
    } else {
      selectedEntities.add(entity);
    }
    notifyListeners();
  }

  void enterSelecting() {
    selecting = true;
    selectedEntities.clear();
    notifyListeners();
  }

  void exitSelecting() {
    selecting = false;
    selectedEntities.clear();
    notifyListeners();
  }

  void clearSelected() {
    selectedEntities.clear();
    notifyListeners();
  }

  Future<void> importSelected() async {
    for (final entity in selectedEntities) {
      assert(entity.isFile);
      assert(!isImported(entity));
      await booksState.uploadBook(entity.relativePath);
    }
    clearSelected();

    notifyListeners();
  }

  void selectAll() {
    filterImportedEntity();
    for (final entity in subEntities) {
      if (entity.isFile && !isImported(entity)) {
        selectedEntities.add(entity);
      }
    }
    notifyListeners();
  }

  bool isImported(Entity entity) {
    return booksState.books.containsKey(entity.relativePath);
  }
}
