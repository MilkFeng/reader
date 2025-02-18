import 'dart:async';

import 'package:flutter/material.dart';

import '../../../managers/settings/models.dart';
import '../../../managers/settings/settings_manager.dart';

class StyleState extends ChangeNotifier {
  late ThemeData _themeData;
  late StyleBundle _styleBundle;

  final Stylesheet _style = Stylesheet();
  final AppStyle _appStyle = AppStyle(padding: 16, backgroundColor: Colors.white);

  final SettingsManager _settingsManager = SettingsManager();

  bool isInitialized = false;

  Timer? _debounceTimer;

  Future<void> debouncedNotify() async {
    if (_debounceTimer != null) {
      _debounceTimer!.cancel();
      _debounceTimer = null;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 100), () {
      notifyListeners();
    });
  }

  Future<void> init(BuildContext context) async {
    isInitialized = false;

    _styleBundle = await _settingsManager.getStyleBundle() ??
        StyleBundle.defaultStyleBundle;

    _themeData = Theme.of(context);

    apply();

    isInitialized = true;
    notifyListeners();
  }

  void apply() {
    _style.clear();
    _styleBundle.applyToStyleSheet(_style, _themeData);
    _styleBundle.applyToAppStyle(_appStyle, _themeData);
  }

  Future<void> setStyleBundle(StyleBundle styleBundle) async {
    _styleBundle = styleBundle;
    apply();

    debouncedNotify();

    await _settingsManager.setStyleBundle(styleBundle);
  }

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    apply();
    debouncedNotify();
  }

  ThemeData get themeData => _themeData;
  StyleBundle get styleBundle => _styleBundle;
  AppStyle get appStyle => _appStyle;
  Stylesheet get style => _style;
}
