import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:quiver/core.dart';

class ColorSchema {
  final Color backgroundColor;
  final Color textColor;

  ColorSchema({
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ColorSchema &&
        other.backgroundColor == backgroundColor &&
        other.textColor == textColor;
  }

  @override
  int get hashCode => hash2(backgroundColor, textColor);

  ColorSchema copyWith({
    Color? backgroundColor,
    Color? textColor,
  }) {
    return ColorSchema(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
    );
  }

  factory ColorSchema.fromJson(Map<String, dynamic> json) {
    return ColorSchema(
      backgroundColor: Color(json['background_color']),
      textColor: Color(json['text_color']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'background_color': backgroundColor.toARGB32(),
      'text_color': textColor.toARGB32(),
    };
  }

  @override
  String toString() {
    return 'ColorSchema{backgroundColor: $backgroundColor, textColor: $textColor}';
  }

  static ColorSchema get defaultColorSchema => ColorSchema(
        backgroundColor: Color(0xFFFFFFFF),
        textColor: Color(0xFF000000),
      );
}

extension MediaQueryDataColorSchemaExt on ThemeData {
  ColorSchema get readerColorSchema {
    final textColor = colorScheme.onSurface;
    final backgroundColor = colorScheme.surface;
    return ColorSchema(
      backgroundColor: backgroundColor,
      textColor: textColor,
    );
  }
}

final _listEquality = ListEquality<ColorSchema>();

class StyleBundle {
  final bool useCustomParagraphStyle;
  final double fontSize;
  final double letterSpacing;

  final bool useThemeColorSchema;
  final List<ColorSchema> colorSchemas;
  final int selectedColorSchemaIndex;

  final double padding;

  StyleBundle({
    required this.useCustomParagraphStyle,
    required this.fontSize,
    required this.letterSpacing,
    required this.useThemeColorSchema,
    required this.colorSchemas,
    required this.selectedColorSchemaIndex,
    required this.padding,
  });

  StyleBundle copyWith({
    bool? useCustomParagraphStyle,
    double? fontSize,
    double? letterSpacing,
    bool? useThemeColorSchema,
    List<ColorSchema>? colorSchemas,
    int? selectedColorSchemaIndex,
    double? padding,
  }) {
    return StyleBundle(
      useCustomParagraphStyle:
          useCustomParagraphStyle ?? this.useCustomParagraphStyle,
      fontSize: fontSize ?? this.fontSize,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      useThemeColorSchema: useThemeColorSchema ?? this.useThemeColorSchema,
      colorSchemas: colorSchemas ?? this.colorSchemas,
      selectedColorSchemaIndex:
          selectedColorSchemaIndex ?? this.selectedColorSchemaIndex,
      padding: padding ?? this.padding,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StyleBundle &&
        other.useCustomParagraphStyle == useCustomParagraphStyle &&
        other.fontSize == fontSize &&
        other.letterSpacing == letterSpacing &&
        _listEquality.equals(other.colorSchemas, colorSchemas) &&
        other.selectedColorSchemaIndex == selectedColorSchemaIndex;
  }

  @override
  int get hashCode => hashObjects([
        useCustomParagraphStyle,
        fontSize,
        letterSpacing,
        useThemeColorSchema,
        colorSchemas,
        selectedColorSchemaIndex,
        padding,
      ]);

  factory StyleBundle.fromJson(Map<String, dynamic> json) {
    return StyleBundle(
      useCustomParagraphStyle: json['use_custom_paragraph_style'],
      fontSize: json['font_size'],
      letterSpacing: json['letter_spacing'],
      useThemeColorSchema: json['use_theme_color_schema'],
      colorSchemas: List<ColorSchema>.from(
          json['color_schemas'].map((x) => ColorSchema.fromJson(x))),
      selectedColorSchemaIndex: json['selected_color_schema_index'],
      padding: json['padding'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'use_custom_paragraph_style': useCustomParagraphStyle,
      'font_size': fontSize,
      'letter_spacing': letterSpacing,
      'use_theme_color_schema': useThemeColorSchema,
      'color_schemas': colorSchemas.map((x) => x.toJson()).toList(),
      'selected_color_schema_index': selectedColorSchemaIndex,
      'padding': padding,
    };
  }

  static StyleBundle get defaultStyleBundle => StyleBundle(
        useCustomParagraphStyle: false,
        fontSize: 16,
        letterSpacing: 0,
        useThemeColorSchema: true,
        colorSchemas: [ColorSchema.defaultColorSchema],
        selectedColorSchemaIndex: 0,
        padding: 16,
      );
}
