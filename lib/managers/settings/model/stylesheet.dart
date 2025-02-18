import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'style_bundle.dart';
import 'style_section.dart';

enum StyleSectionType {
  all,
  p,
  h1,
  h2,
  h3,
  h4,
  h5,
  h6,
  a,
  span,
}

final _styleSectionTypeSelectors = [
  '*',
  'p',
  'h1',
  'h2',
  'h3',
  'h4',
  'h5',
  'h6',
  'a',
  'span',
];

final _mapEquality = MapEquality<StyleSectionType, StyleSection>();

class Stylesheet {
  late final Map<StyleSectionType, StyleSection> _sections;

  Map<StyleSectionType, StyleSection> get sections => _sections;

  Stylesheet() {
    _sections = {
      for (final type in StyleSectionType.values)
        type: StyleSection(_styleSectionTypeSelectors[type.index]),
    };
  }

  static Stylesheet empty = Stylesheet();

  StyleSection operator [](StyleSectionType type) {
    return _sections[type]!;
  }

  void operator []=(StyleSectionType type, StyleSection section) {
    _sections[type] = section;
  }

  String toCss() {
    final buffer = StringBuffer();
    for (final section in _sections.values) {
      section.writeCss(buffer);
    }
    return buffer.toString();
  }

  void writeCss(StringBuffer buffer) {
    for (final section in _sections.values) {
      section.writeCss(buffer);
    }
  }

  void clear() {
    for (final section in _sections.values) {
      section.clear();
    }
  }

  Stylesheet copy() {
    final sections = Stylesheet();
    sections._sections.addAll(_sections);
    return sections;
  }

  @override
  bool operator ==(Object other) {
    if (other is! Stylesheet) {
      return false;
    }
    return _mapEquality.equals(_sections, other._sections);
  }

  @override
  int get hashCode => _mapEquality.hash(_sections);

  StyleSection get all => _sections[StyleSectionType.all]!;
  StyleSection get p => _sections[StyleSectionType.p]!;
  StyleSection get h1 => _sections[StyleSectionType.h1]!;
  StyleSection get h2 => _sections[StyleSectionType.h2]!;
  StyleSection get h3 => _sections[StyleSectionType.h3]!;
  StyleSection get h4 => _sections[StyleSectionType.h4]!;
  StyleSection get h5 => _sections[StyleSectionType.h5]!;
  StyleSection get h6 => _sections[StyleSectionType.h6]!;
  StyleSection get a => _sections[StyleSectionType.a]!;
  StyleSection get span => _sections[StyleSectionType.span]!;
}

extension StylesheetApply on StyleBundle {
  void applyToStyleSheet(Stylesheet style, ThemeData? themeData) {
    if (useCustomParagraphStyle) {
      _applyFontSizeTo(style, fontSize);
      _applyLetterSpacingTo(style, letterSpacing);
    }


    if (!useThemeColorSchema) {
      _applyColorSchemaTo(style, colorSchemas[selectedColorSchemaIndex]);
    } else {
      final colorScheme = themeData?.readerColorSchema ?? ColorSchema.defaultColorSchema;
      _applyColorSchemaTo(style, colorScheme);
    }
  }

  void _applyFontSizeTo(Stylesheet style, double fontSize) {
    style.p.fontSize = fontSize;
    style.a.fontSize = fontSize;
    style.span.fontSize = fontSize;
    style.h1.fontSize = fontSize * 2;
    style.h2.fontSize = fontSize * 1.5;
    style.h3.fontSize = fontSize * 1.17;
    style.h4.fontSize = fontSize;
    style.h5.fontSize = fontSize * 0.83;
    style.h6.fontSize = fontSize * 0.67;
  }

  void _applyLetterSpacingTo(Stylesheet style, double letterSpacing) {
    style.all.letterSpacing = letterSpacing;
  }

  void _applyColorSchemaTo(Stylesheet style, ColorSchema colorSchema) {
    style.all.color = colorSchema.textColor;
  }
}
