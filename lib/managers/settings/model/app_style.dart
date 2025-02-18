import 'package:flutter/material.dart';

import 'style_bundle.dart';

class AppStyle {
  double padding;
  Color backgroundColor;

  AppStyle({
    required this.padding,
    required this.backgroundColor,
  });
}

extension AppStyleApply on StyleBundle {
  void applyToAppStyle(AppStyle style, ThemeData? themeData) {
    style.padding = padding;

    if (useThemeColorSchema) {
      final colorSchema = themeData?.readerColorSchema ?? ColorSchema.defaultColorSchema;
      style.backgroundColor = colorSchema.backgroundColor;
    } else {
      style.backgroundColor = colorSchemas[selectedColorSchemaIndex].backgroundColor;
    }
  }
}
