import 'dart:convert';

import 'models.dart';

import 'prefs.dart';

class SettingsManager {
  // ===========================================================
  static const String rootPathKey = 'root_path';
  static const String isInitializedKey = 'is_initialized';

  Future<String?> getRootPath() async {
    return await Prefs.get<String>(rootPathKey);
  }

  Future<void> setRootPath(String? path) async {
    await Prefs.set(rootPathKey, path);
  }

  Future<bool?> getInitialized() async {
    return await Prefs.get<bool>(isInitializedKey);
  }

  Future<void> setIsInitialized(bool value) async {
    await Prefs.set(isInitializedKey, value);
  }

  // ===========================================================
  static const String styleBundleKey = 'style_bundle';

  Future<StyleBundle?> getStyleBundle() async {
    final styleBundleString = await Prefs.get<String>(styleBundleKey);
    if (styleBundleString == null) {
      return null;
    }

    try {
      return StyleBundle.fromJson(jsonDecode(styleBundleString));
    } catch (e) {
      return null;
    }
  }

  Future<void> setStyleBundle(StyleBundle styleBundle) async {
    await Prefs.set(styleBundleKey, jsonEncode(styleBundle.toJson()));
  }
}
