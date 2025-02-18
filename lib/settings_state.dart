import 'package:flutter/material.dart';

import 'common/fs_utils.dart';
import 'managers/meta/meta_manager.dart';
import 'managers/settings/settings_manager.dart';

class SettingsState extends ChangeNotifier {
  String? _rootPath;
  bool? _isInitialized;

  String? get rootPath => _rootPath;
  bool? get isInitialized => _isInitialized;

  final SettingsManager _settingsManager = SettingsManager();

  Future<void> init() async {
    _rootPath = await _settingsManager.getRootPath();
    _isInitialized = await _settingsManager.getInitialized();
    if (_rootPath == null) {
      await _settingsManager.setRootPath(_rootPath);
      _rootPath = '';
    }
    if (_isInitialized == null) {
      await _settingsManager.setIsInitialized(false);
      _isInitialized = false;
    }
    notifyListeners();
  }

  Future<void> setRootPath(String? path) async {
    await _settingsManager.setRootPath(path);
    _rootPath = path;
    notifyListeners();
  }

  Future<void> pickRootPath() async {
    final path = await FSUtils.pickFolder(writePermission: true);
    if (path == null) {
      return;
    }
    await setRootPath(path);
  }

  Future<void> setIsInitialized(bool value) async {
    await _settingsManager.setIsInitialized(value);
    _isInitialized = value;
    notifyListeners();
  }

  static const String metaRelativePath = "/${MetaManager.metaDirName}";

  Entity get rootEntity => Entity(
    platformPath: _rootPath!,
    name: "根目录",
    isFile: false,
    relativePath: "",
  );
}
